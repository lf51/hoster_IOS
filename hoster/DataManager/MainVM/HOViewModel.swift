//
//  HosterViewModel.swift
//  hoster
//
//  Created by Calogero Friscia on 06/03/24.
//

import Foundation
import Combine
import SwiftUI
import MyPackView
import MyFilterPack

final class HOViewModel:ObservableObject {
    
    let authData:HOAuthData
 
    private(set) var dbManager:HOCloudDataManager
    @Published var db:HOCloudData
    
    @Published var loadStatus:[HOLoadingStatus]
    
    @Published var logMessage:HOSystemMessage?
    @Published var popMessage:HOSystemMessage?
    
    @Published var showAlert: Bool = false
    @Published private(set) var alertMessage: AlertModel? {didSet {showAlert = true}}
    
    @Published var homePath = NavigationPath()
    @Published var reservationsPath = NavigationPath()
    @Published var operationsPath = NavigationPath()
    
    @Published var currentPathSelection:HODestinationPath = .home
    @Published var resetScroll:Bool = false
    var showSpecificModel:String?
    
    var cancellables = Set<AnyCancellable>()
    
    init(authData:HOAuthData) {
        
       // self.isLoading = true
        let userUid = authData.uid
        self.authData = authData
        
        self.db = HOCloudData(userAuthUid: userUid)
        self.dbManager = HOCloudDataManager(userAuthUID: userUid )
      // self.isLoading = []
        self.loadStatus = []
        // Subscriber Train
        addLoadingSubscriber() // chiuso per test
        
        addUserDataSubscriber() // chiuso per test
        addWsDataSubscriber() // chiuso per test
        addWsUnitSubscriber() // chiuso per test
        addWsBooksSubscriber() // chiuso per test
        addWsOperationsSubscriber() // chiuso per test
        
        spinSubscriberTrain(userUID: userUid) // chiuso per test
      //  self.db.currentWorkSpace = WorkSpaceModel() // aperto per test
        print("[INIT]_End ViewModel Init")
        
    }
    
    deinit {
        print("[DEINIT]_ViewModel deInit")
    }
    
}

extension HOViewModel {
    
    var viewCase:HOViewCases {
        
        if let _ = self.db.currentWorkSpace { .main }
        else { .setWorkSpace }
        
    }
    var mainLoadingCase:HOLoadingCase? {
        guard !loadStatus.isEmpty else { return nil }
        
        if loadStatus.allSatisfy({
            $0.loadCase == .inBackground
        }) { return .inBackground }
        else { return .inFullScreen }
    }
}
/// fetch data
extension HOViewModel {
    
    private func spinSubscriberTrain(userUID:String)  {
        
        Task {
            
            do {
            
               try await self.dbManager.fetchAndListenDocumentData(documentPath: userUID, syncro:\.userData)
                
            } catch let error {
                
              //  self.setLoading(to: .end) {
                
                self.callOnMainQueque {
                    
                    let message = HOSystemMessage(
                        vector:.log,
                        title: "Errore",
                        body: .custom("Configurare \(error.localizedDescription)"))
                    
                    self.sendSystemMessage(message: message)
                }
                   
               // }
            }
        }
        
    }
}

/// managingLoading
extension HOViewModel {
    
   /* private func setLoading(to status:LoadingSetStatus,extraOnMain:@escaping() -> Void = { }  ) {
        
        DispatchQueue.main.async {
            switch status {
            case .start:
                self.isLoading = true
            case .end:
                self.isLoading = nil
            }
            extraOnMain()
        }
    }
    
    enum LoadingSetStatus {
        case start,end
    } */
    
     func callOnMainQueque(action:@escaping() -> Void) {
        
        DispatchQueue.main.async {
            action()
        }
        
    }
    
}

extension HOViewModel {
    
    func eraseAllUserData() {
        
        // implementare extension su firebaseConsole
        // costo 0.01 al mese anche se non si utilizza
        // implementare a fine corsa
    }
    
    
    func firstRegOnFirebaseAfterAuth(first workSpace:WorkSpaceModel) {
        
        let userDataModel = {
           
            var current = self.db.currentUser
            current.wsFocusUnitRef = workSpace.wsData.uid
            return current
            
        }()
        
        do {
            
           // self.setLoading(to: .start)
            
            let userForBatch = HODataForPublishing(
                collectionRef: self.dbManager.userData.mainTree,
                model: userDataModel)
            
            let wsForBatch = HODataForPublishing(
                collectionRef: self.dbManager.workSpaceData.mainTree,
                model: workSpace.wsData)
            
            let subUnitTree = self.dbManager.workSpaceData.mainTree?.document(workSpace.wsData.uid).collection(HOCollectionTreePath.allUnits.rawValue)
            
            let unitsForBatch:[HODataForPublishing] = workSpace.wsUnit.all.map({
                
                HODataForPublishing(collectionRef: subUnitTree, model: $0)
                
            })
            
            /*try self.dbManager.batchMultiObject(
                user: userForBatch,
                wsData: wsForBatch,
                wsUnits: unitsForBatch)*/
            try self.dbManager.batchMultiObject(
                object_A: userForBatch,
                object_B: wsForBatch,
                objects_C: unitsForBatch)
            
            
        } catch let error {

            let systMessage = HOSystemMessage(
                vector:.log,
                title: "[Registration_Fail]",
                body: .custom(error.localizedDescription))
            
            self.sendSystemMessage(message: systMessage)
   
        }
 
    }
}

extension HOViewModel {
    
    func publishSingleField<Item:Codable&HOProStarterPack,Syncro:HOProSyncroManager>(
        from itemData:Item,
        syncroDataPath:KeyPath<HOCloudDataManager,Syncro>,
        valuePath:[String:Any]) {
        
        let docRef = self.dbManager[keyPath: syncroDataPath].mainTree?.document(itemData.uid)
        
        let singleValuePublishing = HOSingleValuePublishig(docReference: docRef, path: valuePath)
        
            do {
                
                try self.dbManager.setSingleField(from: singleValuePublishing)
                
                self.callOnMainQueque {
                    
                    self.sendSystemMessage(message: HOSystemMessage(vector: .log, title: "Success", body: HOSystemBodyMessage.custom("Salvataggio dati riuscito")))
                }
                
            } catch let error {
                
                sendAlertMessage(alert: AlertModel(title: "Errore Salvataggio", message: error.localizedDescription))
                
                
            }
            
    }
    
    
    func plublishBatchTwiceObject<A:Codable&HOProStarterPack,C:Codable&HOProStarterPack,SyncA:HOProSyncroManager,SyncC:HOProSyncroManager>(
        object_A:(A,KeyPath<HOCloudDataManager,SyncA>)?,
        objects_C:([C],KeyPath<HOCloudDataManager,SyncC>)?,
        refreshVMPath:HODestinationPath? = nil) {
        
            var dataObjectA:HODataForPublishing<A>?
            var dataObjectC:[HODataForPublishing<C>]?
            
            if let object_A {
                
                let item = object_A.0
                let path = object_A.1
                
                let collRef = self.dbManager[keyPath: path].mainTree
                
                dataObjectA = HODataForPublishing(collectionRef: collRef, model: item)
            }
            
            if let objects_C {
                
                let items = objects_C.0
                let path = objects_C.1
                
                let ref = self.dbManager[keyPath: path].mainTree
                
                dataObjectC = items.map({
                    return HODataForPublishing(collectionRef: ref, model: $0)
                })
                
            }
            
            do {
                
                try dbManager.batchTwiceObject(object_A: dataObjectA, objects_C: dataObjectC)
                
                self.callOnMainQueque {
                    self.refreshPath(destinationPath: refreshVMPath)
                    
                    self.sendSystemMessage(message: HOSystemMessage(vector: .log, title: "Success", body: HOSystemBodyMessage.custom("Salvataggio dati riuscito")))
                }
                
            } catch let error {
                
                sendAlertMessage(alert: AlertModel(title: "Errore Salvataggio", message: error.localizedDescription))
                
            }
             
    }
    
    func publishBatch<Item:Codable&HOProStarterPack,Syncro:HOProSyncroManager>(
        from itemData:Item?...,
        syncroDataPath:KeyPath<HOCloudDataManager,Syncro>,
        refreshVMPath:HODestinationPath? = nil) {
        
            let collRef = self.dbManager[keyPath: syncroDataPath].mainTree
            
            let dataForPublishing:[HODataForPublishing<Item>] = itemData.compactMap({
                guard let value = $0 else { return nil }
                return HODataForPublishing(collectionRef: collRef, model: value)
            })
            
            do {
                
                try self.dbManager.publishInBatch(object: dataForPublishing)
                
                self.callOnMainQueque {
                    self.refreshPath(destinationPath: refreshVMPath)
                }
                
            } catch let error {
                
                print("[PublishInBatch_Error]_\(error.localizedDescription)")
            }
            
    }
    
    func publishData<Item:Codable&HOProStarterPack,Syncro:HOProSyncroManager>(from itemData:Item,syncroDataPath:KeyPath<HOCloudDataManager,Syncro>,refreshVMPath:HODestinationPath? = nil) {
        
        let collRef = self.dbManager[keyPath: syncroDataPath].mainTree
        
        let data = HODataForPublishing(collectionRef:collRef, model: itemData)
        
        do {
            
            try self.dbManager.publishDocumentData(from: data)
            
            self.callOnMainQueque {
                self.refreshPath(destinationPath: refreshVMPath)
            }
            
        } catch let error {
            
            print("[Publish_Error]_\(error.localizedDescription)")
        }
        
    }
    
   
}

/// logica delete document
extension HOViewModel {
    
    func deleteBatchTwiceObject<A:Codable&HOProStarterPack,B:Codable&HOProStarterPack,SyncA:HOProSyncroManager,SyncB:HOProSyncroManager>(
        object_A:(A,KeyPath<HOCloudDataManager,SyncA>)?,
        objects_B:([B],KeyPath<HOCloudDataManager,SyncB>)?,
        refreshVMPath:HODestinationPath? = nil) {
        
            var dataObjectA:HODataForPublishing<A>?
            var dataObjectB:[HODataForPublishing<B>]?
            
            var docCount:Int = 0
            
            if let object_A {
                
                let item = object_A.0
                let path = object_A.1
                
                let collRef = self.dbManager[keyPath: path].mainTree
                
                dataObjectA = HODataForPublishing(collectionRef: collRef, model: item)
                
                docCount += 1
            }
            
            if let objects_B {
                
                let items = objects_B.0
                let path = objects_B.1
                
                let ref = self.dbManager[keyPath: path].mainTree
                
                dataObjectB = items.map({
                    return HODataForPublishing(collectionRef: ref, model: $0)
                })
                
                docCount += items.count
            }
            
            do {
                
                try dbManager.deleteBatchTwiceObject(object_A: dataObjectA, objects_B: dataObjectB)
                
                self.callOnMainQueque {
                    
                    self.refreshPath(destinationPath: refreshVMPath)
                    
                    self.sendSystemMessage(message: HOSystemMessage(vector: .log, title: "Success", body: HOSystemBodyMessage.custom("\(docCount) Documenti eliminati correttamente")))
                }
                
            } catch let error {
                
                sendAlertMessage(alert: AlertModel(title: "OOPs!", message: error.localizedDescription))
                
            }
             
    }
    
    func deleteDocData<Item:Codable&HOProStarterPack,Syncro:HOProSyncroManager>(of itemData:Item,syncroDataPath:KeyPath<HOCloudDataManager,Syncro>,refreshVMPath:HODestinationPath? = nil) {
        
        let collRef = self.dbManager[keyPath: syncroDataPath].mainTree
        
        let data = HODataForPublishing(collectionRef:collRef, model: itemData)
        
        Task {
            
            do {
                
                try await self.dbManager.deleteDocData(of: data)
                
                self.callOnMainQueque {
                    
                    self.refreshPath(destinationPath: refreshVMPath)
                    
                    self.sendSystemMessage(message: HOSystemMessage(vector: .log, title: "Success", body: HOSystemBodyMessage.custom("Documento eliminato correttamente")))
                }
                
                
            } catch let error {
                
                sendAlertMessage(alert: AlertModel(title: "OOPS!", message: error.localizedDescription))
                
                
            }
            
        }
        
    }
    
}

extension HOViewModel:VM_FPC {
    
    func ricercaFiltra<M:Object_FPC>(containerPath: WritableKeyPath<HOViewModel, [M]>, coreFilter: CoreFilter<M>) -> [M] where HOViewModel == M.VM {
        
        let container = self[keyPath: containerPath]
        // filtrare
        // ordinare
        // result
        
        return container
    }
    
    
}

extension HOViewModel {
    
    /// Aggiunge una destinaziona al Path. Utile per aggiungere View tramite Bottone
    func addToThePath(destinationPath:HODestinationPath, destinationView:HODestinationView) {
        
        switch destinationPath {
            
        case .home:
            self.homePath.append(destinationView)
        case .reservations:
            self.reservationsPath.append(destinationView)
        case .operations:
            self.operationsPath.append(destinationView)
      
        }
        
    }
    
    /// azzera il path di riferimento Passato
    func refreshPath(destinationPath: HODestinationPath?) {
        
        guard let destinationPath else { return }
        
        let path = destinationPath.vmPathAssociato()
        
        self[keyPath: path].removeLast()

    }
    
    /// Azzera il path di riferimento e chiama il reset dello Scroll
    func refreshPathAndScroll() -> Void {

        self.showSpecificModel = nil
        let path = self.currentPathSelection.vmPathAssociato()
        
        if self[keyPath: path].isEmpty { self.resetScroll.toggle() }
        else { self[keyPath: path] = NavigationPath() }

    }
}

/// workspace get data from
extension HOViewModel {
    
    func getSubs() -> [HOUnitModel]? {
        
        guard let ws = self.db.currentWorkSpace,
              let subs = ws.wsUnit.subs else { return nil }
        
        return subs.sorted(by: {$0.label < $1.label})
        
    }
    
}
///Info Message
extension HOViewModel {
    
    func sendSystemMessage(message:HOSystemMessage) {
        
        switch message.vector {
            
        case .log: self.logMessage = message
        case .pop: self.popMessage = message
            
        }

    }
    
    func sendAlertMessage(alert:AlertModel) {
        
       // self.alertMessage = alert
        self.callOnMainQueque {
            self.alertMessage = alert
        }
    }
    
}

/// retrieve wsData information
extension HOViewModel {
    
    func getCostiTransazione() -> Double {
        
        guard let ws = self.db.currentWorkSpace,
              let ota = ws.wsData.costiTransazione else {
            return WorkSpaceData.defaultValue.costiTransazione!
        }
        
        return ota
        
    }
    
    func getOTAChannels() -> [HOOTAChannel] {
        
        guard let ws = self.db.currentWorkSpace,
              let ota = ws.wsData.otaChannels else {
            return WorkSpaceData.defaultValue.otaChannels!
        }
        
        return ota 
        
    }
    
    func getCityTaxPerPerson() -> Double {
        
        guard let ws = self.db.currentWorkSpace,
              let cityTax = ws.wsData.cityTaxPerPerson else {
            return WorkSpaceData.defaultValue.cityTaxPerPerson!
        }
        
        return cityTax
        
    }
    
    func getIvaSubject() -> Bool {
        
        guard let ws = self.db.currentWorkSpace,
              let ivaSub = ws.wsData.ivaSubject else {
            return WorkSpaceData.defaultValue.ivaSubject!
        }
        
        return ivaSub
    }
    
    func getMaxNightIn() -> Int {
        
        guard let ws = self.db.currentWorkSpace,
              let maxIn = ws.wsData.maxNightIn else {
            return WorkSpaceData.defaultValue.maxNightIn!
        }
        
        return maxIn 
        
    }
    
    func getBedTypeIn() -> [HOBedType] {
        
        guard let ws = self.db.currentWorkSpace,
              let bedType = ws.wsData.bedTypeIn else {
            return WorkSpaceData.defaultValue.bedTypeIn!
        }
        
        return bedType
    }
    
    func getCheckInTime() -> DateComponents {
        
        guard let ws = self.db.currentWorkSpace,
              let checkInTime = ws.wsData.checkInTime else {
            
            return WorkSpaceData.defaultValue.checkInTime!
        }
        
        return checkInTime
    }
    
}

extension HOViewModel {
    
    func getUnitModel(from uid:String) -> HOUnitModel? {
        
        guard let ws = self.db.currentWorkSpace else { return nil }
        
        let first = ws.wsUnit.all.first(where: {$0.uid == uid})
        return first
        
    }
    
    func getOperation(from uidRefs:[String]) -> [HOOperationUnit]? {
        
        guard let ws = self.db.currentWorkSpace else { return nil }
        
        let associated = ws.wsOperations.all.filter({uidRefs.contains($0.uid)})
        guard !associated.isEmpty else { return nil }
        
        return associated
    }
}

let buy1:HOOperationUnit = {
    
    var x = HOOperationUnit()
    x.writing = HOWritingAccount(
        type: .acquisto,
        dare: nil,
        avere: "AA02",
        oggetto: HOWritingObject(
            category: .merci,
            subCategory: .food,
            specification: "Colazione Continentale"))
    
    x.amount = HOOperationAmount(quantity:10, pricePerUnit: 1.5)
    
    return x
}()



// chiusa AREA TEST CORRENTE

let testUnit:HOUnitModel = {
    var curr = HOUnitModel(type: .main)
    curr.label = "Casa mea"
    //curr.pax = 3
    return curr
}()

let testUnit2:HOUnitModel = {
    var curr = HOUnitModel(type: .sub)
    curr.label = "Camera due"
    curr.pax = 3
    return curr
}()

let testUnit1:HOUnitModel = {
    var curr = HOUnitModel(type: .sub)
    curr.label = "Camera Uno"
    curr.pax = 5
    return curr
}()

let reservation:HOReservation = {
    
    var current:HOReservation = HOReservation()
    
    current.guestName = "Lillo Friscia"
    current.refUnit = testUnit1.uid
    current.labelPortale = "booking.com"
    current.guestType = .couple
    current.notti = 7
    current.pax = 2
    current.dataArrivo = Date()
    current.disposizione = [HOBedUnit(bedType: .double, number: 1)]
    
    return current
}()

let testWorkSpace:WorkSpaceModel = {
    
    var ws = WorkSpaceModel()
    ws.wsOperations.all = [buy1]
    ws.wsReservations.all = [reservation]
    ws.wsUnit.all = [testUnit,testUnit1,testUnit2]
    return ws
}()


var testViewModel:HOViewModel = {
    
    var vm = HOViewModel(authData: HOAuthData())
   // var ws = WorkSpaceModel()
   // var wd = WorkSpaceData(focusUid: "ujo")
   // ws.wsOperations.all = [buy1]
    
   // ws.wsUnit.all = [unit]
    vm.db.currentWorkSpace = WorkSpaceModel()
    vm.db.currentWorkSpace! = testWorkSpace
   
    return vm
}()  // test per Preview // da eliminare


