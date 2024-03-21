//
//  WorkSpaceType.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

enum WorkSpaceType:CaseIterable,Hashable {
    
    static var allCases: [WorkSpaceType] = [.wholeUnit,.withSub]
    
    case wholeUnit // un'unità intera deve ospitare almeno una persona
    case withSub // un'unità con sub deve averne almeno una (sub)
    
    func rawValue() -> String {
        
        switch self {
        case .wholeUnit:
            return "Unità intera"
        case .withSub:
            return "Unità con sub"
        }
        
    }
    
    func systemImage() -> String {
        
        switch self {
        case .wholeUnit:
            return "house.fill"
        case .withSub:
            return "building.2"
       
        }
        
    }
    
    func rawDescription() -> String {
        
        switch self {
        case .wholeUnit:
            return "Unità affittata per intero. Esempio: appartamento casa vacanze ecc.."
        case .withSub:
            return "Unità affittata per singole sub unità. Esempio: affittacamere, bed&breakfast ecc..."
        }
        
    }
    
    func rawAddDataDescription() -> (label:String,image:String,genereSingolare:String,generePlurale:String) {
        
        switch self {
        case .wholeUnit:
            
            return ("pax","person.fill","person","persons")
            
        case .withSub:
            return ("sub","building.fill","sub","subs")
        }
        
    }
    
}
