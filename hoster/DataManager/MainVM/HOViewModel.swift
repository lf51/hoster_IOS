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
    
    func eraseAllUserData() {
        
        // implementare extension su firebaseConsole
        // costo 0.01 al mese anche se non si utilizza
        // implementare a fine corsa
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
    
    func getSubs() -> [HOUnitModel] {
        
        guard let ws = self.db.currentWorkSpace,
              let subs = ws.wsUnit.subs else { return [] }
        
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
        
        self.alertMessage = alert
    }
    
}

/// retrieve wsData information
extension HOViewModel {
    
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

var testViewModel:HOViewModel = {
    
    var vm = HOViewModel(authData: HOAuthData())
    var ws = WorkSpaceModel()
    ws.wsOperations.all = [buy1]
    vm.db.currentWorkSpace? = ws
    return vm
}()  // test per Preview // da eliminare


