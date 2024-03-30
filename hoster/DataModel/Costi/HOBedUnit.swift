//
//  HOBedUnit.swift
//  hoster
//
//  Created by Calogero Friscia on 24/03/24.
//

import Foundation

struct HOBedUnit {
    
    var bedType:HOBedType?
    var number:Int?
    
}

extension HOBedUnit:HOProCDCPack {
    
    static var typeCode: HOTypeCDCcode = .bedUnit
    static var costsAggregationLabel: [HOCostAggregationLabel] = [.lavanderia]
    
    func getCostKPath(from imputation: HOBedType) -> KeyPath<HOBedUnit, Int?>? {
        
        guard let bedType else { return nil }
        
        guard bedType == imputation else { return nil }
        
        return \.number
    }
    
    enum HOBedType:HOProObjectCostImputation {
        
        static var allCases: [HOBedUnit.HOBedType] = [.single,.double,.king,.singlePlusHalf]

        case single
        case double
        case king
        case singlePlusHalf
     
        func getAsUnitOfMeasure() -> String {
            return "bed"
        }
        
        func getCostLabel() -> String {
            
            switch self {
            case .single:
                return "letto singolo"
            case .double:
                return "letto matrimoniale"
            case .king:
                return "letto king size"
            case .singlePlusHalf:
                return "letto una piazza e mezzo"
            }
            
            
        }
    }
    
}
