//
//  UnitModel.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

struct UnitModel:HOProStarterPack, Hashable {
    
    let uid: String
    var typeValue:Int
    
    var label:String
    /// deve equivalere al pax max del workspace per entrambi i type
    var pax:Int?
    
    var unitType:UnitType {
        get { UnitType(rawValue: typeValue) ?? .main }
        set { self.typeValue = newValue.rawValue }
    }
    
    /// label = "" • pax = nil
    init(type:UnitType) {
        self.uid = UUID().uuidString
        self.typeValue = type.rawValue
        self.label = ""
        self.pax = nil
    }
    
}

extension UnitModel:Codable { }
