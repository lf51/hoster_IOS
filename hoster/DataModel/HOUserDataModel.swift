//
//  UserDataModel.swift
//  hoster
//
//  Created by Calogero Friscia on 28/02/24.
//

import SwiftUI

/// oggetto di servizio per salvare i riferimenti delle proprietà dello User
struct HOUserDataModel:HOProStarterPack {
    
    let uid:String
    var isPremium:Bool?
    
    var wsFocusUnitRef:String?
        
}
     
extension HOUserDataModel:Decodable {
    
    enum CodingKeys:String,CodingKey {
        
        case uid
        case isPremium = "is_premium"
        case focusWorkSpace = "ws_focus_ref"
        
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try container.decode(String.self, forKey: .uid)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.wsFocusUnitRef = try container.decodeIfPresent(String.self, forKey: .focusWorkSpace)
    }
}

extension HOUserDataModel:Encodable {
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.wsFocusUnitRef, forKey: .focusWorkSpace)
        
    }
}
