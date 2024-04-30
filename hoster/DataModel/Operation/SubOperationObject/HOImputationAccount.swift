//
//  HOImputationAccount.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation

enum HOImputationAccount:CaseIterable,HOProAccountDoubleEntry { // imputazione diretta
    // dare i ricavi // avere i costi
    static let mainIDCode: String = "SP"
    
    case pernottamento
    case lavanderia
    case pulizia
    case accoglienza
    case colazione
   // case portale
    case marketing
    
    case transfer
    case meal
    case experience
    case noleggio
    
    case boutique
    case minibar
    
    case parcheggio
    
    case warehouse // finale
    case fondoAmmortamenti // finale
    
    case vat // finale
    case cityTax // finale
    
    case mainUnit // finale diretto e/o indiretto
    case subUnit // label // finale diretto e/o indiretto
  //  case pernottamento // ribaltamento ultimo
    
    func getCaseIndex() -> String {
        
        switch self {
            // 00 il custom + la label
        case .pernottamento: return "01"
            
        case .lavanderia: return "02"
        case .pulizia: return "03"
        case .accoglienza: return "04"
        case .colazione: return "05"
    
        case .marketing: return "06"
            
        case .transfer: return "07"
        case .meal: return "08"
        case .experience: return "09"
        case .noleggio: return "010"
        case .boutique: return "011"
        case .minibar: return "012"
    
        case .warehouse: return "013"
        case .fondoAmmortamenti: return "014"
            
        case .vat: return "015"
        case .cityTax: return "016"
        case .mainUnit: return "017"
        case .subUnit: return "018"
            
        case .parcheggio: return "019"
           
        }
        
    }
    
    func getIDCode() -> String {
        return Self.mainIDCode + self.getCaseIndex()
    }
    
    func getAlgebricSign(from sign: HOAccWritingPosition) -> HOAccWritingSign {
        
        switch sign {
        case .dare:
            return .plus
        case .avere:
            return .minus
        }
    }
    
    func getSubCategory() -> [HOImputationSubs] {
        
        switch self {
        case .pernottamento:
            return [.booking,.airbnb,.direct]
        case .pulizia:
            return [.programmata,.ordinaria,.straordinaria]
        case .marketing:
            return [.ads,.sitoWeb,.agenzia]
        case .transfer:
            return [.aeroporto,.fuoriPorta]
        case .meal:
            return [.pranzo,.cena]
        case .noleggio:
            return [.auto,.moto,.bici,.monopattino]
        default: return []
        }
        
    }
}
