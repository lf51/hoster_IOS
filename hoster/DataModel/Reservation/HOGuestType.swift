//
//  HOGuestType.swift
//  hoster
//
//  Created by Calogero Friscia on 06/04/24.
//

import Foundation
import MyFilterPack

enum HOGuestType:Int,CaseIterable {
    
    case single = 0
    case couple
    case group
    case family
    case familyWithChild
    
    func stringValue() -> String {
        
        switch self {
        case .single:
            return "single"
        case .couple:
            return "couple"
        case .group:
            return "group"
        case .family:
            return "family"
        case .familyWithChild:
            return "+ child"
        }
    }
    
    func getPaxRange() -> ClosedRange<Int> {
        
        switch self {
        case .single:
            return 1...1
        case .couple:
            return 2...2
        case .group:
            return 2...20
        case .family,.familyWithChild:
            return 3...20
        }
    }
    
    func getPaxLimit() -> (value:Int,limit:HOGuestTypeLimits) {
        
        switch self {
        case .single:
            return (1,.exact)
        case .couple:
            return (2,.exact)
        case .group:
            return (2,.minimum)
        case .family,.familyWithChild:
            return (3,.minimum)
        
        }
        
    }
    
    enum HOGuestTypeLimits {
        
        case exact
        case minimum
        
    }
    
}

extension HOGuestType:Codable { }

extension HOGuestType:Property_FPC {
    
    func simpleDescription() -> String {
        return self.stringValue()
    }
    
    func returnTypeCase() -> HOGuestType {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        return self.rawValue
    }
    
    
}
