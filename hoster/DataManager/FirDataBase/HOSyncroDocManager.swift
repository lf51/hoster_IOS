//
//  HOSyncroDocumentManager.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import Combine
import FirebaseFirestoreInternal

final class HOSyncroDocumentManager<Item:Codable> {
    
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
