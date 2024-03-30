//
//  HOCostLabel.swift
//  hoster
//
//  Created by Calogero Friscia on 23/03/24.
//

import Foundation

enum HOCostAggregationLabel {
    
   /* static let labelsPortale:[HOCostLabel] = [.commissioni,.costiTransizione]
    static let labelsCheckIn:[HOCostLabel] = [.pulizia,.lavanderia,.welcome,.colazione]
    static let labelsTasse:[HOCostLabel] = [.cityTax,.imu,.tari,.iva]
    static let labelUtenze:[HOCostLabel] = [.internet,.luce,.gas,.acqua]
    static let labelRappresentanza:[HOCostLabel] = [.sitoWeb] */
    
    case pulizia
    case lavanderia
    case welcome
    case colazione
    // portali
    case commissioni
    case costiTransizione
    // tasse
    case cityTax
    case imu
    case tari
    case iva
    // utenze
    case internet
    case luce
    case gas
    case acqua
    // rappresentanza
    case sitoWeb
    // generica
    case custom(_:String)
    
    
    func setCustomCase(label:String) /*throws -> HOCostLabel*/ {
        
       // dobbiamo evitare la creazione di case Custom con stessa label di case di sistema
        
        
    }
    
    func costCaseRawValue() -> String {
        
        switch self {
            
        case .pulizia:  return "pulizia"
        case .lavanderia: return "lavanderia"
        case .welcome: return "welcome"
        case .colazione: return "colazione"
        case .commissioni: return "commissioni"
        case .costiTransizione: return "costi transizione"
        case .cityTax: return "city tax"
        case .imu: return "imu"
        case .tari: return "tari"
        case .iva: return "iva"
        case .internet: return "internet"
        case .luce: return "luce"
        case .gas: return "gas"
        case .acqua: return "acqua"
        case .sitoWeb: return "sito web"
            
        case .custom(let label):
            return label
        }
    }
    
    func costCase(from rawValue:String) -> HOCostAggregationLabel {
        
        switch rawValue {
            
        case "pulizia": return .pulizia
        case "lavanderia": return .lavanderia
        case "welcome": return .welcome
        case "colazione": return .colazione
        
        case "commissioni": return .commissioni
        case "costi transizione": return .costiTransizione
        case "city tax": return .cityTax
        case "imu": return .imu
        case "tari": return .tari
        case "iva": return .iva
        case "internet": return .internet
        case "luce": return .luce
        case "gas": return .gas
        case "acqua": return .acqua
        case "sito web": return .sitoWeb
                        
        default: return .custom(rawValue)
            
        }
        
        
    }
    
}
