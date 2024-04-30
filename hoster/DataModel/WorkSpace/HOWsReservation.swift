//
//  WorkSpaceReservation.swift
//  hoster
//
//  Created by Calogero Friscia on 22/03/24.
//

import Foundation

struct HOWsReservations:HOProStarterPack {
   
    let uid:String
    
    var all:[HOReservation]
    
    init(focusUid:String,allReservation:[HOReservation] = []) {
        
        self.uid = focusUid
        self.all = allReservation
    }
}


