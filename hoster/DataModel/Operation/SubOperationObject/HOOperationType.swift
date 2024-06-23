//
//  HOOperationType.swift
//  hoster
//
//  Created by Calogero Friscia on 20/06/24.
//

import Foundation
import SwiftUI

enum HOOperationType:String,CaseIterable,Codable {
    
    case acquisto
    case pagamento
    case consumo
    case resoPassivo = "reso passivo" // a nostro sfavore
    
    case ammortamento
    
    case vendita
    case resoAttivo = "reso attivo" // a nostro favore
    case regalie
        
}

/// destricption logic
extension HOOperationType {
    
    func getGergalDescription() -> String {
        
        switch self {
        case .acquisto:
            return "acquistabile"
        case .pagamento:
            return "pagabile"
        case .consumo:
            return "consumabile"
        case .resoPassivo:
            return "rimborsabile"
        case .ammortamento:
            return "ammortizzabile"
        case .vendita:
            return "vendibile"
        case .resoAttivo:
            return "restituibile"
        case .regalie:
            return "regalabile"
        }
        
    }
    
    func getDescriptionValue() -> String {
        
        switch self {
       
        case .resoPassivo:
            return "rimborso per vendita"
        case .resoAttivo:
            return "rimborso da acquisto"
     
        default: return self.rawValue
        }
        
        
    }
    
    func getPrepositionAssociated() -> String {
        
        switch self {
        case .acquisto,.pagamento,.consumo,.ammortamento,.regalie,.resoAttivo:
            return "per"
       
        case .resoPassivo,.vendita:
            return "da"
    
        }
        
    }
}

extension HOOperationType:HOProWritingDownLoadFilter {
 
    func getRowLabel() -> String {
        self.rawValue
    }
    
    func getImageAssociated() -> String {
        switch self {
        case .acquisto,.pagamento,.consumo,.ammortamento,.resoPassivo:
            return "minus.circle"
       
        case .vendita,.resoAttivo,.regalie:
            return "plus.circle"
        }
    }
    
    func getColorAssociated() -> Color {
       
        switch self {
        case .acquisto,.pagamento,.consumo,.ammortamento,.resoPassivo:
            return Color.faluRed_p52
       
        case .vendita,.resoAttivo,.regalie:
            return Color.green
        }
        
    }
}

/// imputation logic
extension HOOperationType {
    
    func getImputation(throw area:HOAreaAccount) -> [HOImputationAccount]? {
        
        let optEnableToImputation = area.getOPTWhereImputationIsEnabled()
        
        guard optEnableToImputation.contains(self) else { return nil }
        
        return derivedImputationAccountAssociated(to: area )
        
       /* switch area {
        case .scorte:
            
            
            
            switch self {
            case .acquisto,.resoAttivo:
                return nil
            
            case .consumo:
                return derivedImputationAccountAssociated(to: area )
            default: return nil
            }
        case .corrente:
            switch self {
            case .acquisto,.pagamento,.resoPassivo,.vendita,.regalie:
                return derivedImputationAccountAssociated(to: area )
            
            default: return nil
            }
        case .tributi:
            switch self {
            case .pagamento:
                return derivedImputationAccountAssociated(to: area )
            default: return nil
            }
        case .pluriennale:
            switch self {
            case .acquisto:
                return nil
            case .ammortamento:
                return derivedImputationAccountAssociated(to: area )
            default: return nil
            }
        }*/

    }
    
    func getImputation(throw category:HOObjectCategory) -> [HOImputationAccount]? {
        
        switch category {
        case .merci:
            
            switch self {
            case .acquisto,.resoAttivo,.consumo,.vendita,.resoPassivo:
                return derivedImputationAccountAssociated(to: category)
            
            default: return nil
            }
            
        case .servizi:
            switch self {
            case .acquisto,.vendita,.resoAttivo,.resoPassivo:
                return derivedImputationAccountAssociated(to: category)
            default: return nil
            }
        case .mod:
            switch self {
            
            case .pagamento:
                return [.accoglienza,.pulizia,.lavanderia,.diversi]
            default: return nil
            }
        case .utenze:
            switch self {
            
            case .pagamento,.resoAttivo:
                return derivedImputationAccountAssociated(to: category)
            default: return nil
            }
        case .abbonamentiQuoteCanoni,.tassePatrimoniali:
            switch self {
            
            case .pagamento:
                return derivedImputationAccountAssociated(to: category)
            default: return nil
            }
 
        case .tip:
            switch self {
          
            case .regalie:
                return [.accoglienza,.colazione,.experience,.pulizia,.transfer,.diversi]
            default: return nil
            }
        case .ads:
            switch self {
            case .acquisto:
                return [.diversi]
            default: return nil
                
            }
        case .edifici:
            switch self {
            case .acquisto:
                return nil
            case .ammortamento:
                return [.parcheggio,.diversi]
            default: return nil
           
            }
        case .arredi:
            switch self {
            case .acquisto:
                return nil
            case .ammortamento:
                return [.colazione,.boutique,.diversi]
            default: return nil
           
            }
        case .biancheria:
            switch self {
            case .acquisto:
                return nil
            case .ammortamento:
                return [.diversi]
            default: return nil
           
            }
        case .attrezzatura,.impiantiGenerici,.impiantiSpecifici,.elettronica,.veicoli,.costruzioniLeggere:
            switch self {
            case .acquisto:
                return nil
            case .ammortamento:
                return derivedImputationAccountAssociated(to: category)
            default: return nil
           
            }
       
        case .manutenzione:
            switch self {
          
            case .pagamento:
                return derivedImputationAccountAssociated(to: category)
            default: return nil
           
            }
        case .altro,.costiTransazione,.commissioni:
            switch self {
           
            case .pagamento:
                return [.diversi]

            default: return nil
            }
        }
        
    }
    
    func getImputation(throw subCategory:HOObjectSubCategory?) -> [HOImputationAccount]? {
        
        guard let subCategory else { return nil }
        
        switch subCategory {
        case .food,.beverage:
            
            switch self {
            case .acquisto,.resoAttivo:
                return [.colazione,.accoglienza,.boutique,.minibar]
            case .consumo:
                return [.colazione,.accoglienza,.boutique,.minibar,.diversi]
          
            case .resoPassivo,.vendita:
                return [.boutique,.minibar]
         
            default: return nil
            }
            
        case .interno:
            switch self {

            case .vendita,.resoPassivo:
                return [.colazione,.lavanderia,.experience,.noleggio,.parcheggio,.pulizia,.transfer,.diversi]
                
            default: return nil
         
            }
        case .esterno:
            switch self {
            case .acquisto,.vendita:
                return [.colazione,.lavanderia,.experience,.noleggio,.parcheggio,.pulizia,.transfer,.diversi]

            default: return nil
            }
        case .luce,.acqua,.gas:
            switch self {
            
            case .pagamento,.resoAttivo:
                return [.diversi]
                
            default: return nil
            }
       
        case .affitto,.sitoWeb,.associazione,.streaming,.payTv,.internet,.imu,.tari,.speseCondominiali:
            switch self {
           
            case .pagamento:
                return [.diversi]
            default: return nil
            }
       
        case .tettoia,.baracca:
            switch self {
            
            case .ammortamento:
                return [.parcheggio,.noleggio,.diversi]
            default: return nil
            }
        
        case .stoviglie,.posate,.cucina:
            switch self {
            case .ammortamento:
                return [.colazione]
            default: return nil
            }
        case .piccoliElettrodomestici:
            switch self {
            case .ammortamento:
                return [.colazione,.minibar,.diversi]
            default: return nil
            }
        case .riscaldamento,.condizionamento,.igienici,.ascensore,.telefonico,.citofonico,.wifi,.computer,.domotica,.purificatoreAria:
            switch self {
            case .ammortamento:
                return [.diversi]
            default: return nil
            }
       
        case .grandiElettrodomestici:
            switch self {
            case .ammortamento:
                return [.colazione,.lavanderia,.pulizia,.diversi]
            default: return nil
            }
        
        case .purificatoreAcqua:
            switch self {
            case .ammortamento:
                return [.colazione,.diversi]
            default: return nil
            }
       
        case .autovettura:
            switch self {
            case .ammortamento:
                return [.transfer,.noleggio,.diversi]
            default: return nil
            }
        case .motoveicolo,.bicicletta,.monopattino:
            switch self {
            case .ammortamento:
                return [.noleggio,.diversi]
            default: return nil
            }

        case .ordinaria,.straordinaria:
            switch self {
          
            case .pagamento:
                return [.lavanderia,.pulizia,.diversi]
            default: return nil
            }
    
        case .altro:
            
            switch self {
            case .acquisto:
                return [.lavanderia,.pulizia,.boutique,.diversi]
            case .pagamento:
                return [.diversi]
            case .consumo:
                return [.lavanderia,.pulizia,.boutique,.diversi]
            case .resoPassivo:
                return [.boutique]
            case .ammortamento:
                return [.colazione,.lavanderia,.pulizia,.minibar,.parcheggio,.noleggio,.diversi]
            case .vendita:
                return [.boutique]
            case .resoAttivo:
                return [.boutique]
            case .regalie:
                return nil
            }
            
        }
    }
    
    private func derivedImputationAccountAssociated(to area:HOAreaAccount) -> [HOImputationAccount]? {
          
        guard let categoryAssociated = area.getSubRelatedObject(throw: self) else { return nil }
          
          let imputation = categoryAssociated.compactMap({
              
              self.getImputation(throw:$0)
              
              })
          let flat = imputation.flatMap({$0})
          let cleanDuplicate = Set(flat)
         
          return Array(cleanDuplicate)

      }
      
    private func derivedImputationAccountAssociated(to category:HOObjectCategory) -> [HOImputationAccount]? {
        
        guard let subsAssociated = category.getSubRelatedObject(throw: self) else { return nil }
        
        let imputation = subsAssociated.compactMap({
            
            self.getImputation(throw:$0)
            
            })
        let flat = imputation.flatMap({$0})
        let cleanDuplicate = Set(flat)
        
        return Array(cleanDuplicate)

    }
    
}
