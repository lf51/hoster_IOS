//
//  HOSyncroDocumentManager.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import Combine
import FirebaseFirestoreInternal

protocol HOProSyncroManager {
    
    var mainTree:CollectionReference? { get }
    
    func setMainTree(to newValue:CollectionReference?)
}

final class HOSyncroDocumentManager<Item:Codable>:HOProSyncroManager {
    
    private(set) var mainTree:CollectionReference?
    
    var listener:ListenerRegistration?
    var publisher = PassthroughSubject<Item?,Error>()
    
    init(mainTree:CollectionReference? = nil) {
        self.mainTree = mainTree
    }

    func setMainTree(to newValue:CollectionReference?) {
        
        self.mainTree = newValue
    }
}

final class HOSyncroCollectionManager<Item:Codable>:HOProSyncroManager {
    
    private(set) var mainTree:CollectionReference?
    
    var listener:ListenerRegistration?
    var publisher = PassthroughSubject<(String?,[Item]?),Error>()
    
    init(mainTree:CollectionReference? = nil) {
        self.mainTree = mainTree
    }

    func setMainTree(to newValue:CollectionReference?) {
        
        self.mainTree = newValue
    }
}
