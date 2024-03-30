//
//  UnitModel.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

struct HOUnitModel:HOProStarterPack, Hashable {
    
    let uid: String
    let typeValue:Int
    
    var label:String
    var pax:Int?
    
    var bedAvaible:[HOBedUnit.HOBedType]?
    var calendario:Calendar?
  
    /// label = "" • pax = nil
    init(type:UnitType) {
        self.uid = UUID().uuidString
        self.typeValue = type.rawValue
        self.label = ""
        self.pax = nil
        self.bedAvaible = nil
    }
    
}

/// computed
extension HOUnitModel {
    
    var unitType:UnitType {
        get { UnitType(rawValue: typeValue) ?? .main }
      // set { self.typeValue = newValue.rawValue }
    }
    
    
}

//extension HOUnitModel:Codable { }

extension HOUnitModel:HOProCDCPack {
    
    static var typeCode:HOTypeCDCcode = .unitModel
    static var costsAggregationLabel: [HOCostAggregationLabel] = []
    
    func getCostKPath(from imputation: HOUnitModelCostImputation) -> KeyPath<HOUnitModel, Int?>? {
        return \.pax
    }
    
    
    
    enum HOUnitModelCostImputation:HOProObjectCostImputation {
        
        static var allCases: [HOUnitModelCostImputation] = []
        
        
        
        
        func getCostLabel() -> String {
            return ""
        }
        
        func getAsUnitOfMeasure() -> String {
            return ""
        }
        
    }
    
}
