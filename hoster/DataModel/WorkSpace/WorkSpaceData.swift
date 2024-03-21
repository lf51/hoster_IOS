//
//  WorkSpaceData.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

/// Contiene i dati del workSpace. Il body del documento su Firebase
struct WorkSpaceData:HOProStarterPack,Codable {
    
    let uid: String
    
    init(focusUid:String) {
        self.uid = focusUid
    }
}
