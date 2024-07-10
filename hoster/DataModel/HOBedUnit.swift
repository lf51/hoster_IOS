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

extension HOBedUnit:Equatable { }

enum HOBedType:String,Codable {
    
    static var allCases: [HOBedType] = [.single,.double,.king,.singlePlusHalf,.culletta]
    
    case single
    case double
    case king
    case singlePlusHalf
    case culletta
    
    // divanoletto
    // brandina
    
    func getAsUnitOfMeasure() -> String {
        return "bed"
    }
    
    func getStringValue() -> String {
        
        switch self {
        case .single:
            return "singolo"
        case .double:
            return "matrimoniale"
        case .king:
            return "king size"
        case .singlePlusHalf:
            return "una piazza e mezzo"
        case .culletta:
            return "culletta"
        }
        
        
    }
    
    func getMaxCapability() -> Int {
        
        switch self {
        case .single,.singlePlusHalf,.culletta:
            return 1
        case .double,.king:
            return 2
       
        }
        
    }
}

