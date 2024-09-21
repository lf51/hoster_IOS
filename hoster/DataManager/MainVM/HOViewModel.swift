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
    
    @Published var yyFetchData:Int
    
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
        self.yyFetchData = Locale.current.calendar.component(.year, from: Date())
      // self.isLoading = []
        self.loadStatus = []
        // Subscriber Train
        addLoadingSubscriber() // chiuso per test
        
        addUserDataSubscriber() // chiuso per test
        addWsDataSubscriber() // chiuso per test
        addWsUnitSubscriber() // chiuso per test
        addWsBooksSubscriber() // chiuso per test
        addWsOperationsSubscriber() // chiuso per test
        addYYSubscriber()
        
        spinSubscriberTrain(userUID: userUid) // chiuso per test
      //  self.db.currentWorkSpace = WorkSpaceModel() // aperto per test
        print("[INIT]_End ViewModel Init")
        
    }
    
    deinit {
        print("[DEINIT]_ViewModel deInit")
    }
    
    
    
}
/// Locale computed information
extension HOViewModel {
    // dati dal Locale
    var localCalendar:Calendar { Locale.current.calendar }
    
    var localCalendarMMSymbol:[String] { localCalendar.monthSymbols }
    var localCalendarWDSymbol:[String] { localCalendar.shortWeekdaySymbols }
    var localCurrencyID:String { Locale.current.currency?.identifier ?? "USD"}
    // dati correnti
    var currentYY:Int { localCalendar.component(.year, from: Date()) }
    var currentMMOrdinal:Int { localCalendar.component(.month, from: Date()) }
    var currentDDOrdinal:Int { localCalendar.component(.day, from: Date()) }
    
    var localCurrencySymbol:String {
        Locale.current.currencySymbol ?? "$"
    }
    
    /// valore stringa del mese ricavato dal suo ordinale. 1 == gennaio
    func getMMSymbol(from ordinal:Int) -> String {
               
     let index = ordinal - 1
     guard index >= 0 else { return "error" }
        
     let value = localCalendarMMSymbol[index]
     return value
        

   }
    /// valore srtringa del giorno ricavato dal suo ordinale. 1 == sunday
    func getDDSymbol(from ordinal:Int) -> String {
        
        let index = ordinal - 1
        guard index >= 0 else { return "error" }
           
        let value = localCalendarWDSymbol[index]
        return value
        
    }
    /// tupla contenente il numero di giorni in un mese, e l'ordinale del primo giorno del mese.
    private func getMMDays(from monthOrdinal:Int) -> (ddIn:Int,firstWD:Int) {
        
        let baseDate = DateComponents(calendar: localCalendar, year: currentYY, month: 1, day: 1).date ?? Date()
        
        let specularDate = localCalendar.date(bySetting: .month, value: monthOrdinal, of: baseDate) ?? Date()
        
        let days = localCalendar.range(of: .day, in: .month, for: specularDate)?.count ?? 0
        
        let firstWeekDay = localCalendar.component(.weekday, from: specularDate)
       
        return (days,firstWeekDay)
        
    }
    /// prende lo start day del mese e il numero di dd nel mese e li raggruppa in un dizionario, dove la chiave è l'ordinale del week day , e i valori sono i giorni del mese corrispondenti. Ex: 1(aka Sunday): 2,9,16,23,30
    func getDDGrouped(from monthOrdinal:Int) -> [Int:[Int]] {
        // 1 == sunday 7 == suturday
        let ddIn = getMMDays(from: monthOrdinal)
        
        let dayInMonth = ddIn.ddIn
        var firstDDInMonth = ddIn.firstWD
        
        let wdCount = self.localCalendarWDSymbol.count
        
        var capsule:[Int:[Int]] = [:]
        
        for wd in 1...wdCount {
            
            let module = firstDDInMonth % wdCount
            let key = module != 0 ? module : wdCount
           // let keyString = self.getDDSymbol(from: key)
            
            var ddIn:[Int] = []
            var current:Int = wd
            
            while current <= dayInMonth {
                
                ddIn.append(current)
                current += wdCount
                
            }
            
            if ddIn.count < 5 {
                // aggiunge uno zero che poi nasconderemo per avere i vuoti nella griglia
                if key < wd { ddIn.insert(0, at: 0) }
                else { ddIn.append(0) }
                
            }
            
           else if ddIn.count == 5 {

                if key < wd { ddIn.insert(0, at: 0) }
               // else { ddIn.append(0) }
                
            }
            
            firstDDInMonth += 1
            capsule[key] = ddIn
           
        }
            
        return capsule
    }
    
}
/// entry view logic
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
/// first In logic
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
/// firebase save logic
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
        let containerFiltrato = container.filter {
         
            $0.propertyCompare(coreFilter: coreFilter, readOnlyVM: self)
        }
        // ordinare
        
        let containerOrdinato = containerFiltrato.sorted {
            M.sortModelInstance(lhs: $0, rhs: $1, condition:coreFilter.sortConditions , readOnlyVM: self) }
        // result
        
        return containerOrdinato
    }
    
    
}
/// path logic
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
    
    func getUserName() -> String {
        
        if let user = self.authData.userName {
            return user
        }
        else if let mail = self.authData.email {
            return mail
        }
        else { return "no userName" }
    }
    
    func getPaxMax() -> Int {
        
        guard let ws = self.db.currentWorkSpace else { return 0 }
        
        return ws.paxMax
    }
    
    func getWSLabel() -> String {
        
        guard let ws = self.db.currentWorkSpace else {
            return "Home"
        }
        
        return ws.wsLabel
        
    }
    
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
    
    func getDbStorageYY() -> [Int]? {
        
        let t = currentYY//calendar.component(.year, from: Date())
        let t1 = t - 1
        
        guard let _ = self.db.currentUser.isPremium else {
            // per gli utenti non premium occorre performare la cancellazione dei dati oltre il secondo anno
            
            return [t,t1]
            
        }
       
        // premium user ha accesso ad un database più esteso, direi max 5 compreso quello corrente
        
        let t2 = t - 2
        let t3 = t - 3
        let t4 = t - 4
        
        return [t,t1,t2,t3,t4]
    }
    
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
    
    func getCheckOutTime() -> DateComponents {
        
        guard let ws = self.db.currentWorkSpace,
              let checkOutTime = ws.wsData.checkOutTime else {
            
            return WorkSpaceData.defaultValue.checkOutTime!
        }

        return checkOutTime
        
    }
    
}
/// retrieve information
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
    
    func getOccupancyFor(month:Int?, unitRef:String?) -> [(in:Date,out:Date)]? {
        /// da implementare le unità
        guard let reservations = self.getReservations(month: month, unitRef: unitRef,notConsiderCheckOut: false) else { return nil }
        
        let allDates:[(Date,Date)] = reservations.compactMap({
            guard let checkIn = $0.dataArrivo else { return nil }
            let checkOut = $0.checkOut
            return (checkIn,checkOut)
        })
        return allDates
    }
    
    func getReservations(month:Int?,unitRef:String?,notConsiderCheckOut:Bool = true) -> [HOReservation]? {
        /// da implementare le unità
        guard let ws = self.db.currentWorkSpace else { return nil }
        
        let reservations = ws.wsReservations.getAllFiltered(for: self.yyFetchData, month: month,unitRef: nil,notConsiderCheckOut: notConsiderCheckOut)
        
        return reservations
    }
    
    
    func getReservationInfo(month:Int?,sub:String?) -> (count:Int,grossAmount:Double,totaleNotti:Int,totaleGuest:Int)? {
        
        guard let ws = self.db.currentWorkSpace else { return nil }
        
        let reservationInfo = ws.wsReservations.getInformation(for: self.yyFetchData,month: month,sub: sub)

        let operationModelAssociated = self.getOperation(from: reservationInfo.optAssociatedRef) ?? []
        
        let optFiltered = operationModelAssociated.filter({
            
            $0.writing?.imputationAccount == .pernottamento
        })
        
        let totalAmount = optFiltered.reduce(into: 0) { partialResult, operation in
            
            partialResult += (operation.amount?.imponibile ?? 0)
        }
        
        
        return (reservationInfo.count,totalAmount,reservationInfo.totalNight,reservationInfo.totalGuest)
        
    }
    
    func getWarehouseInfo() -> (gross:Double,buy:Double,consumo:Double) { return (125,200,75) }
    
    func getEconomicResult(from optRef:[String]) -> Double {
        
        guard let opts = self.getOperation(from: optRef) else { return 0.0 }
        
        let positive = opts.filter({$0.writing?.type?.getEconomicSign() == .plus })
        
        let negative = opts.filter({$0.writing?.type?.getEconomicSign() == .minus })
        
        
        let totalPositive = positive.reduce(into: 0) { partialResult, operation in
            
            partialResult += (operation.amount?.imponibile ?? 0)
        }
        
        let totalNegative = negative.reduce(into: 0) { partialResult, operation in
            
            partialResult += (operation.amount?.imponibile ?? 0)
        }
        
        return totalPositive - totalNegative
    }
}

// area test

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

let buy2:HOOperationUnit = {
    
    var x = HOOperationUnit()
    x.writing = HOWritingAccount(
        type: .vendita,
        dare: nil,
        avere: "AA02",
        oggetto: HOWritingObject(
            category: .servizi,
            subCategory: .interno,
            specification: "Lillo Friscia"))
    
    x.amount = HOOperationAmount(quantity:7, pricePerUnit: 71.5)
    
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
    
    current.guestName = "Calogero Lillo Friscia"
    current.refUnit = testUnit1.uid
    current.labelPortale = "booking.com"
    current.guestType = .couple
    current.notti = 7
    current.pax = 2
    current.dataArrivo = Date()
    current.disposizione = [HOBedUnit(bedType: .double, number: 1)]
    current.refOperations = [buy1.uid,buy2.uid]
    return current
}()

let reservation1:HOReservation = {

    var current:HOReservation = HOReservation()
    
    current.guestName = "Giuseppe Friscia"
    current.refUnit = testUnit1.uid
    current.labelPortale = "booking.com"
    current.guestType = .couple
    current.notti = 3
    current.pax = 2
    current.dataArrivo = Locale.current.calendar.date(byAdding: DateComponents(year:-1,month: 1,day: 2), to: Date())
    current.disposizione = [HOBedUnit(bedType: .double, number: 1)]
    
    return current
}()

let reservation2:HOReservation = {
    
    var current:HOReservation = HOReservation()
    
    current.guestName = "Caterina Dulcimascolo"
    current.refUnit = testUnit2.uid
    current.labelPortale = "booking.com"
    current.guestType = .couple
    current.notti = 5
    current.pax = 3
    current.dataArrivo = Date().addingTimeInterval(2592000)
    current.disposizione = [HOBedUnit(bedType: .double, number: 1),HOBedUnit(bedType: .single, number: 1)]
    
    return current
}()

let testWorkSpace:WorkSpaceModel = {
    
    var ws = WorkSpaceModel()
    ws.wsOperations.all = [buy1,buy2]
    ws.wsReservations.all = [reservation,reservation1,reservation2]
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


