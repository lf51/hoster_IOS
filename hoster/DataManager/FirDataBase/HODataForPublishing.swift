//
//  HODataForPublishing.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import FirebaseFirestoreInternal

struct HODataForPublishing<Item:Codable&HOProStarterPack> {
    
    let collectionRef:CollectionReference?
    let model:Item
    
}

struct HOSingleValuePublishig {
    
    let docReference:DocumentReference?
    let path:[String:Any]
}

struct HOSingleValueDelete {
    
    let docReference:DocumentReference?
    let fields:[String]
}
