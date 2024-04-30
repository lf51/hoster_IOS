//
//  HOOperationTypeObject.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation

enum HOOperationTypeObject:CaseIterable,HOProAccountDoubleEntry {
    // dare i costi // avere i ricavi
    static let mainIDCode: String = "CE"
    
    case merci
    case servizi
    
    case mod
    case stipendi
    
    case utenze
    case canoni
    case abbonamenti
    
    case tributi
   // case vat
    case costiTransazione
    case commissioni
    case tip
    
    case costiPluriennali //beniStrumentali // opere di ristrutturazione // beni immateriali
    case manutenzione // ordinaria // straordinaria
    case quote
    case diversi // potremmo associare label

    
    func getCaseIndex() -> String {
        
        switch self {
        case .merci: return "01"
        case .servizi: return "02"
        case .mod: return "03"
        case .stipendi: return "04"
        case .utenze: return "05"
        case .canoni: return "06"
        case .abbonamenti: return "07"
        case .tributi: return "08"
        case .costiTransazione: return "09"
        case .commissioni: return "010"
        case .tip: return "011"
        case .costiPluriennali: return "012"
        case .manutenzione: return "013"
        case .quote: return "014"
            
        case .diversi: return "00"
            
        }
    }
    
    func getIDCode() -> String {
        return Self.mainIDCode + self.getCaseIndex()
    }
    
    func getAlgebricSign(from sign: HOAccWritingPosition) -> HOAccWritingSign {
        
        switch sign {
        case .dare:
            return .minus
        case .avere:
            return .plus
        }
    }
    
    func getSubsCategories() -> [HOTypeObjectSubs] {
        
        switch self {
        case .quote:
            return [.speseCondominiali]
        case .merci:
            return [.food,.beverage]
        case .utenze:
            return [.acqua,.gas,.luce]
        case .canoni:
            return [.affitto,.associazione,.sitoWeb]
        case .abbonamenti:
            return [.streaming,.payTv,.internet]
        case .tributi:
            return [.imu,.tari]
        case .costiPluriennali:
            return [.elettrodomestici,.arredi,.opereMurarie,.software,.hardware,.veicoli,.ads]
        case .manutenzione:
            return [.ordinaria,.straordinaria]
            
        default: return []
        }
        
        
    }
    
}
