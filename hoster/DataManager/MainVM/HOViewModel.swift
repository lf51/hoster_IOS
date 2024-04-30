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
    
    @Published var logMessage:String? // sviluppare
    @Published var popMessage:String? // sviluppare
    @Published var alertMessage:AlertModel? // sviluppare
    
    @Published var showAlert: Bool = false
    @Published var alertItem: AlertModel? {didSet {showAlert = true}} // deprecare
    
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
        addLoadingSubscriber()
        
        addUserDataSubscriber()
        addWsDataSubscriber()
        addWsUnitSubscriber()
        addWsBooksSubscriber()
        
        spinSubscriberTrain(userUID: userUid)
        
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
                    self.logMessage = "Configurare\(error.localizedDescription)"
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
            
            try self.dbManager.batchMultiObject(
                user: userForBatch,
                wsData: wsForBatch,
                wsUnits: unitsForBatch)
            
            
        } catch let error {
            
           // self.setLoading(to: .end)
            self.logMessage = "[Registration_Fail]_\(error.localizedDescription)"
            
            
        }
 
    }
}

extension HOViewModel {
    
    func eraseAllUserData() {
        
        // implementare extension su firebaseConsole
        // costo 0.01 al mese anche se non si utilizza
        // implementare a fine corsa
    }
    
    func publishData<Item:Codable&HOProStarterPack>(from itemData:Item,syncroDataPath:KeyPath<HOCloudDataManager,HOSyncroDocumentManager<Item>>) {
        
        let collRef = self.dbManager[keyPath: syncroDataPath].mainTree
        
        let data = HODataForPublishing(collectionRef:collRef, model: itemData)
        
        do {
            
            try self.dbManager.publishDocumentData(from: data)
            
        } catch let error {
            
            
            print("[Publish_Error]_\(error.localizedDescription)")
        }
        
    }
}

extension HOViewModel {
    
    /// Azzera il path di riferimento e chiama il reset dello Scroll
    func refreshPathAndScroll() -> Void {

        self.showSpecificModel = nil
        let path = self.currentPathSelection.vmPathAssociato()
        
        if self[keyPath: path].isEmpty { self.resetScroll.toggle() }
        else { self[keyPath: path] = NavigationPath() }

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
}
