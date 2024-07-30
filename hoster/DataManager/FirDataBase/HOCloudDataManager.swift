//
//  UserManager.swift
//  hoster
//
//  Created by Calogero Friscia on 28/02/24.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreInternal

public final class HOCloudDataManager {
    
    private let db_base = Firestore.firestore()
    
    private(set) var userData:HOSyncroDocumentManager<HOUserDataModel>
    private(set) var workSpaceData:HOSyncroDocumentManager<WorkSpaceData>
    private(set) var workSpaceUnits:HOSyncroCollectionManager<HOUnitModel>
    
    private(set) var workSpaceReservations: HOSyncroCollectionManager<HOReservation>
    
    private(set) var workSpaceOperations:HOSyncroCollectionManager<HOOperationUnit>
    
    private(set) var loadingPublisher = PassthroughSubject<HOLoadingStatus?,Error>()
    
    let localEncoder:Firestore.Encoder = {
        
        let localEncode = Firestore.Encoder()
        localEncode.keyEncodingStrategy = .convertToSnakeCase
        return localEncode
    }()
    
    let localDecoder:Firestore.Decoder = {
        
        var localDecode = Firestore.Decoder()
        localDecode.keyDecodingStrategy = .convertFromSnakeCase
        return localDecode
        
    }()
    
    public init(userAuthUID:String) {
        
        let userTree = self.db_base.collection(HOCollectionTreePath.main.rawValue)
        self.userData = HOSyncroDocumentManager(mainTree: userTree)
        
        let wsTree = userTree.document(userAuthUID).collection(HOCollectionTreePath.workspace.rawValue)
        self.workSpaceData = HOSyncroDocumentManager(mainTree: wsTree)
        
        self.workSpaceUnits = HOSyncroCollectionManager()
        self.workSpaceReservations = HOSyncroCollectionManager()
    
        self.workSpaceOperations = HOSyncroCollectionManager()
        
    }
    
}

/// Managing Batch
extension HOCloudDataManager {
    
    func publishInBatch<Item:Codable&HOProStarterPack>(object:[HODataForPublishing<Item>]?) throws {
        
        let batch = self.db_base.batch()
        
        guard let object else {
            
            throw HOCustomError.erroreGenerico(problem: "Saving Fail", reason: "Non vi sono oggetti validi per il salvataggio", solution: "riprovare")
        }
        
        try self.publishDocumentsBatch(from: object, in: batch)
       
        Task {
            try await batch.commit()
        }
    }
    
    func batchMultiObject<A:Codable&HOProStarterPack,B:Codable&HOProStarterPack,C:Codable&HOProStarterPack>(
        object_A:HODataForPublishing<A>?,
        object_B:HODataForPublishing<B>?,
        objects_C:[HODataForPublishing<C>]?) throws {
        
        let batch = self.db_base.batch()
            //self.loadingPublisher.send(true)
        
            if let object_A {
                
               try self.publishSingleDocumentBatch(
                    from: object_A,
                    in: batch)
                
            }
            
            if let object_B {
                
                try self.publishSingleDocumentBatch(
                    from: object_B,
                    in: batch)
            }
            
            if let objects_C {
                
                try self.publishDocumentsBatch(
                    from: objects_C,
                    in: batch)
            }
            
            Task {
                try await batch.commit()
               // self.loadingPublisher.send(nil)
            }
    }
    
    func batchTwiceObject<A:Codable&HOProStarterPack,C:Codable&HOProStarterPack>(
        object_A:HODataForPublishing<A>?,
        objects_C:[HODataForPublishing<C>]?) throws {
        
        let batch = self.db_base.batch()
            //self.loadingPublisher.send(true)
        
            if let object_A {
                
               try self.publishSingleDocumentBatch(
                    from: object_A,
                    in: batch)
                
            }

            if let objects_C {
                
                try self.publishDocumentsBatch(
                    from: objects_C,
                    in: batch)
            }
            
            Task {
                try await batch.commit()
               // self.loadingPublisher.send(nil)
            }
    }
    
    /*func batchMultiObject(
        user:HODataForPublishing<HOUserDataModel>?,
        wsData:HODataForPublishing<WorkSpaceData>?,
        wsUnits:[HODataForPublishing<HOUnitModel>]?) throws {
        
        let batch = self.db_base.batch()
            //self.loadingPublisher.send(true)
        
            if let user {
                
               try self.publishSingleDocumentBatch(
                    from: user,
                    in: batch)
                
            }
            
            if let wsData {
                
                try self.publishSingleDocumentBatch(
                    from: wsData,
                    in: batch)
            }
            
            if let wsUnits {
                
                try self.publishDocumentsBatch(
                    from: wsUnits,
                    in: batch)
            }
            
            Task {
                try await batch.commit()
               // self.loadingPublisher.send(nil)
            }
    }*/ // backup per update a generic
    
   private func publishDocumentsBatch<Item:Codable&HOProStarterPack>(from items:[HODataForPublishing<Item>],in batch:WriteBatch) throws {
               
        for element in items {
            
            if let mainRef = element.collectionRef {
                
                let doc = mainRef.document(element.model.uid)
                
                try batch.setData(
                    from: element.model,
                    forDocument: doc,
                    merge: true, 
                    encoder: localEncoder)
            }

        }
    }
    
   private func publishSingleDocumentBatch<Item:Codable&HOProStarterPack>(from item:HODataForPublishing<Item>,in batch:WriteBatch) throws {
        
        if let mainRef = item.collectionRef  {
            
            let doc = mainRef.document(item.model.uid)
            
            try batch.setData(
                from: item.model,
                forDocument: doc,
                merge: true,
                encoder: localEncoder)
        }
        
    }
}

/// Managing Data
extension HOCloudDataManager {
    
    func publishDocumentData<Item:Codable&HOProStarterPack>(from itemData:HODataForPublishing<Item>) throws {
        
        guard let collectionRef = itemData.collectionRef else { return }
        
        let document = collectionRef.document(itemData.model.uid)
        
          try document.setData(
            from: itemData.model,
            merge: true,
            encoder: localEncoder)
        
    }
    
    func setSingleField(from element:HOSingleValuePublishig) throws {
        
        guard let docReference = element.docReference else {
            throw HOCustomError.erroreGenerico()
        }
         
        docReference
          //  .setValue(nil, forKey: "schedule_cache")
            .setData(element.path, merge: true)
    
    } // verificare encoding.04.07.24 non in uso
    
    
 
    
}
/// Managing Delete
extension HOCloudDataManager {
    
    func deleteAllData() throws {
        
        // implementare extension su firebaseConsole
        // costo 0.01 al mese anche se non si utilizza
        // implementare a fine corsa
        
    }
    
    func deleteDocData<Item:Codable&HOProStarterPack>(of itemData:HODataForPublishing<Item>) async throws {
        
        guard let collectionRef = itemData.collectionRef else { return }
        
        let document = collectionRef.document(itemData.model.uid)
        
        try await document.delete()
        
    }
    
    func deleteBatchTwiceObject<A:Codable&HOProStarterPack,B:Codable&HOProStarterPack>(
        object_A:HODataForPublishing<A>?,
        objects_B:[HODataForPublishing<B>]?) throws {
        
        let batch = self.db_base.batch()
            //self.loadingPublisher.send(true)
        
            if let object_A {
                
               deleteSingleDocumentBatch(from: object_A, in: batch)
                
            }

            if let objects_B {
                
                for eachDoc in objects_B {
                    
                    deleteSingleDocumentBatch(from: eachDoc, in: batch)
                }
            }
            
            Task {
                try await batch.commit()
            }
    }
    
    private func deleteSingleDocumentBatch<Item:Codable&HOProStarterPack>(from item:HODataForPublishing<Item>,in batch:WriteBatch) {
         
         if let mainRef = item.collectionRef  {
             
             let doc = mainRef.document(item.model.uid)
             
              batch.deleteDocument(doc)
         }
         
     }
}

///Managing WorkSpace
extension HOCloudDataManager {
    
    func fetchAndListenWorkSpaceModel(wsFocusUID:String) throws {
        
        // rimuoviamo i listener per azzerare i fetch dopo il primo
        print("[CALL]_fetchAndListenWorkSpaceUnit_for:\(wsFocusUID)")
        self.workSpaceData.listener?.remove()
        self.workSpaceUnits.listener?.remove()
        
        self.workSpaceReservations.listener?.remove()
        self.workSpaceOperations.listener?.remove()
        
        Task {
            // fetch WorkSpaceUnit
            
            try await fetchAndListenDocumentData(documentPath: wsFocusUID, syncro: \.workSpaceData)

            // set path subCollection
            let docPath = self.workSpaceData.mainTree?.document(wsFocusUID)
            
            let unitsCollRef = docPath?.collection(HOCollectionTreePath.allUnits.rawValue)
            self.workSpaceUnits.setMainTree(to: unitsCollRef)
            
            let booksCollRef = docPath?.collection(HOCollectionTreePath.allReservations.rawValue)
            self.workSpaceReservations.setMainTree(to: booksCollRef)
            
            let optCollRef = docPath?.collection(HOCollectionTreePath.allOperations.rawValue)
            self.workSpaceOperations.setMainTree(to: optCollRef)
            // mettiamo un listener sull'intera collection
            try await fetchAndListenCollection(syncro: \.workSpaceUnits)
            try await fetchAndListenCollection(syncro: \.workSpaceReservations)
            try await fetchAndListenCollection(syncro: \.workSpaceOperations)
            
        }
        
    }
}
/// Fetching Data
extension HOCloudDataManager {

    /// Piazza un listener su un documento recuperando la collezione di riferimento dal SyncroDataManager passato
    /// - Parameters:
    ///   - documentPath: id del documento
    ///   - tree: SyncroDataManager di riferimento
    func fetchAndListenDocumentData<Item:Codable>(documentPath:String,syncro tree:KeyPath<HOCloudDataManager,HOSyncroDocumentManager<Item>>) async throws {

        guard let collectionRef = self[keyPath: tree].mainTree else {
            
            throw HOCustomError.mainRefCorrotto
             }
        
        let document = collectionRef.document(documentPath)
        
        self[keyPath: tree].listener = document
            .addSnapshotListener {[weak self] querySnapshot, errror in
                print("[START]_fetchAndListenDocumentData for \(Item.self)")
                
                var loadingStatus = HOLoadingStatus(
                    loadCase: .inFullScreen,
                    description: "Fetching document: \(Item.self)")
                
                self?.loadingPublisher.send(loadingStatus)
                
                guard let self else {
                    print("[WEAK_SELF]")
                    self?[keyPath: tree].publisher.send(nil)
                    
                    loadingStatus.nullStatus()
                    self?.loadingPublisher.send(loadingStatus)
                    return }
                
                guard let document = querySnapshot else {
                    print("[DOCUMENT is NIL]")
                    self[keyPath: tree].publisher.send(nil)
                    loadingStatus.nullStatus()
                    self.loadingPublisher.send(loadingStatus)
                    return
                }
            
                let itemData = try? document.data(as: Item.self,decoder:self.localDecoder )
                
                guard let itemData else {
                    print("[ItemData is NIL]")
                    self[keyPath: tree].publisher.send(nil)
                    loadingStatus.nullStatus()
                    self.loadingPublisher.send(loadingStatus)
                    return
                }
                
                print("[END]_fetchAndListenDocumentData for \(Item.self)")
                self[keyPath: tree].publisher.send(itemData)
                loadingStatus.nullStatus()
                self.loadingPublisher.send(loadingStatus)
              
               
            }
    }
    
    private func fetchAndListenCollection<Item:Codable>(syncro tree:KeyPath<HOCloudDataManager,HOSyncroCollectionManager<Item>>) async throws {
    
        guard let collection = self[keyPath: tree].mainTree else {
    
            throw HOCustomError.mainRefCorrotto
        }
        
        self[keyPath: tree].listener = collection.addSnapshotListener(includeMetadataChanges: false, listener: { [weak self] querySnap, error in
            print("[START]_fetchAndListenCollection_for:\(Item.self)")
            
            var loadingStatus = HOLoadingStatus(
                loadCase: .inFullScreen,
                description: "Fetching collection: \(Item.self)")
            
            self?.loadingPublisher.send(loadingStatus)
            
            guard let self,
                  let querySnap else {
                
                self?[keyPath:tree].publisher.send((nil,nil))
                
                loadingStatus.nullStatus()
                self?.loadingPublisher.send(loadingStatus)
               // self?[keyPath: tree].publisher.send(completion: .failure(URLError(.badURL)))
                return
                
            }

           // let source = querySnap.metadata.isFromCache
           // let pending = querySnap.metadata.hasPendingWrites
            
           /* guard !pending else {
                print("[PENDING]_cambiamenti locali. In attesa di snap dal server")
                return
            }*/
            
            let document = querySnap.documents
            
            guard !document.isEmpty else {
                
                self[keyPath: tree].publisher.send((nil,nil))
                loadingStatus.nullStatus()
                self.loadingPublisher.send(loadingStatus)
               // self[keyPath: tree].publisher.send(completion: .failure(URLError(.badURL)))
                return
            }
            
            let doc = collection.parent?.documentID
            
            let allUnit:[Item] = document.compactMap { snap -> Item? in
                
                let item = try? snap.data(as: Item.self,decoder: self.localDecoder)
                return item
            }

            print("[END]_fetchAndListenCollection_for:\(Item.self)")
            self[keyPath: tree].publisher.send((doc,allUnit))
            loadingStatus.nullStatus()
            self.loadingPublisher.send(loadingStatus)
            
           // self[keyPath: tree].publisher.send(completion: .finished)
            
           /* for doc in document {
                
                let item = try? doc.data(as: Item.self)
                self[keyPath: tree].publisher.send(item)
            }
            self[keyPath: tree].publisher.send(completion: .finished) */
        })
        
    }

}
