//
//  HOImputationAccount.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation
import SwiftUI
/// Risponde alla domanda; Per Cosa? per quale attività effettuiamo l'operazione
enum HOImputationAccount:String,CaseIterable { // imputazione diretta
    // dare i ricavi // avere i costi

    case pernottamento
    
    case lavanderia
    case pulizia
    case accoglienza
    case colazione
   // case portale
    case marketing
    
    case transfer
   // case meal = "pasti"
    case experience
    case noleggio
    case parcheggio
    
    case boutique
    case minibar
    // conti intermedi da ribaltare
   // case warehouse = "magazzino" // finale
   // case fondoAmmortamenti = "f.do ammortamento" // finale
    // conti imputazione finale
  //  case vat = "iva" // finale
  //  case cityTax = "tassa di soggiorno" // finale
   // case tributi
    
    case cityTax
   // case vat
    case ota
    
    
    case diversi
    
    case mainUnit // finale diretto e/o indiretto
    case subUnit // label // finale diretto e/o indiretto
  //  case pernottamento // ribaltamento ultimo
    
    /// gli account vanno ordinati in ordine alfabetico. L'index sepra il case diversi per poterlo sottrarre all'ordine alfabetico ed elencarlo per ultimo
    func getOrderIndex() -> Int {
        
        switch self {
            
        case .diversi: return 1
            
        default: return 0
            
            
        }
    }
    
    func getSubCategory() -> [HOSubsImputationAccount] {
        
        switch self {
        case .pernottamento:
            return [.booking,.airbnb,.direct]
        case .pulizia:
            return [.programmata,.ordinaria,.straordinaria]
        case .marketing:
            return [.ads,.sitoWeb,.agenzia]
        case .transfer:
            return [.aeroporto,.fuoriPorta]
       // case .meal:
         //   return [.pranzo,.cena]
        case .noleggio:
            return [.auto,.moto,.bici,.monopattino]
        default: return []
        }
        
    } // deprecabile ?? non in uso
}

extension HOImputationAccount:HOProAccountDoubleEntry {

    static let typeCode: HODoubleEntryAccountIndex = .imputationAccount
    
    static func getCase(from idCode: String) throws -> HOImputationAccount {
        
        let caseIndex = idCode.dropFirst(2)
        
        for eachCase in Self.allCases {
            
            let index = eachCase.getCaseIndex()
            if index == caseIndex { return eachCase }
            else { continue }
            
        }
        
        throw HOCustomError.erroreGenerico(problem: "idCase conto imputazione non esistente", reason: nil, solution: nil)
    }
    
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
      //  case .meal: return "08"
        case .experience: return "09"
        case .noleggio: return "010"
        case .boutique: return "011"
        case .minibar: return "012"
    
       // case .warehouse: return "013"
       // case .fondoAmmortamenti: return "014"
            
        //case .vat: return "013"
        case .cityTax: return "016"
        case .ota: return "014"
       // case .tributi: return "015"
        case .diversi: return "015"
        case .mainUnit: return "017"
        case .subUnit: return "018"
            
        case .parcheggio: return "019"
           
        }
        
    } // deprecata in futuro
    
    func getIDCode() -> String {
        return Self.typeCode.rawValue + self.getCaseIndex()
       // let rawValue = self.rawValue.replacingOccurrences(of: " ", with: "")
       // return Self.typeCode.rawValue + rawValue
    }
    
    func getAlgebricSign(from sign: HOAccWritingPosition) -> HOAccWritingSign {
        
        switch sign {
        case .dare:
            return .plus
        case .avere:
            return .minus
        }
    }
    
}

extension HOImputationAccount:HOProWritingDownLoadFilter {
    
    func getRowLabel() -> String {
        return self.rawValue
    }
    
    func getColorAssociated() -> Color {
        return Color.yellow
    }
    
    func getImageAssociated() -> String {
        return "cursorarrow.click.2"
    }
}


