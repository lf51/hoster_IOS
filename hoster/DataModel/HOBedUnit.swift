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

extension HOBedUnit:Codable { }

enum HOBedType:Codable {
    
    static var allCases: [HOBedType] = [.single,.double,.king,.singlePlusHalf]
    
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

