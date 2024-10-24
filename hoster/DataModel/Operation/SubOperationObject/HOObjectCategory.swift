//
//  HOOperationTypeObject.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation
import SwiftUI
import MyFilterPack

/// Risponde alla domanca: Cosa? Oggetto dell'operazione
enum HOObjectCategory:String,CaseIterable {
    // dare i costi // avere i ricavi

    case merci = "merce"
    case servizi = "servizio"
    case mod = "mano d'opera"
   // case stipendi
    
    case utenze = "utenza"
   // case canoni
    case abbonamentiQuoteCanoni = "abbonamento/quota/canone"
    
    case tassePatrimoniali = "tassa patrimoniale"
   // case cityTax = "tassa di soggiorno"
    case imposte // non ha sub e serve per imputare cityTax e Iva
    
   // case vat
   // case costiTransazione = "Costo di Transazione"
    case commissioni
    case tip = "mancia"
    
    case ads = "pubblicità"
   // case costiPluriennali = "bene ammortizzabile" //beniStrumentali // opere di ristrutturazione // beni immateriali
    
    // ammortizzabili
    
    case edifici
    case costruzioniLeggere = "costruzione leggera"
    case arredi = "mobili e arredi"
    case biancheria
    case attrezzatura
    case impiantiGenerici = "impianto generico"
    case impiantiSpecifici = "impianto specifico"
    case elettronica
    case veicoli
    
    case manutenzione // ordinaria // straordinaria
   // case quote
    case altro // potremmo associare label

    /// il valore dei mesi di advancing ( il mese di partenza è da considerarsi incluso)
    func getDefaultMonthAdvancedAssociated() -> Int? {
        
        switch self {
    
        case .utenze:
            return 2 // ese: bimestre
        case .tassePatrimoniali,.ads,.manutenzione:
            return nil//12
        case .edifici,.costruzioniLeggere,.arredi,.biancheria,.attrezzatura,.impiantiGenerici,.impiantiSpecifici,.elettronica,.veicoli:
            
            if let amm = self.getAnniAmmortamento() {
                
                return amm * 12
            } else { return 24 /* un valore di default che porta cmq il period a pluriennale, in teoria non dovrebbe accadere */ }
            
        default: return 1
 
        }
        
        
    }
    
    func getPeriodsAssociated() -> [HOMonthImputation.HOMIPeriod]? {
        
        let standard:[HOMonthImputation.HOMIPeriod] = [.mensile,.bimestre,.trimestre,.quadrimestre,.semestre,.annuale,.intero]
        
        switch self {

        case .tassePatrimoniali,.ads,.manutenzione:
            return [.intero]
        case .edifici,.costruzioniLeggere,.arredi,.biancheria,.attrezzatura,.impiantiGenerici,.impiantiSpecifici,.elettronica,.veicoli:
            
            return [.pluriennale]
           // fallthrough
        default: return standard
 
        }
        
        
    }
    
    func getUnitMisureAssociated() -> HOAmountUnitMisure? {
        
        switch self {
       
        case .mod:
            return .hour

        case .commissioni,.tip,.ads,.edifici:
            return .standard
       
        case .arredi,.biancheria:
            return .unit
   
        default: return nil
        }
        
    }
    
    
    func getAnniAmmortamento() -> Int? {
        
        switch self {
      
        case .edifici:
            return 30 // original coefficent 3%
        case .costruzioniLeggere,.arredi,.impiantiGenerici,.impiantiSpecifici:
            return 10 // original coefficent 10&10 - 8&12
        case .biancheria:
            return 2 // original coefficent 40%
        case .attrezzatura,.veicoli:
            return 4 // original coefficent 25%
        case .elettronica:
            return 5 // original coefficent 20%
     
        default: return nil
        }

    }
    
    func getSubRelatedObject(throw type: HOOperationType?) -> [HOObjectSubCategory]? {
        
        switch self {

        case .merci:
            return [.food,.beverage,.altro]
        case .servizi:

                switch type {
                case .acquisto:
                    return [.esterno]
                case .resoPassivo:
                    return [.interno]
                case .vendita:
                    return [.interno,.esterno]
                default: return nil
                }

        case .utenze:
            return [.acqua,.gas,.luce]

        case .abbonamentiQuoteCanoni:
            return [.streaming,.payTv,.internet,.affitto,.associazione,.sitoWeb,.speseCondominiali,.altro]
        case .tassePatrimoniali:
            return [.imu,.tari]
        case .imposte:
            return [.cityTax,.vat]
        case .commissioni:
            return [.agenzia,.bancarie]
        case .edifici:
            return nil
        case .costruzioniLeggere:
            return [.tettoia,.baracca,.altro]
        case .arredi:
            return nil
        case .biancheria:
            return nil
        case .attrezzatura:
            return [.stoviglie,.posate,.piccoliElettrodomestici,.altro]
        case .impiantiGenerici:
            return [.riscaldamento,.condizionamento]
        case .impiantiSpecifici:
            return [.igienici,.cucina,.grandiElettrodomestici,.ascensore,.telefonico,.citofonico,.wifi,.altro]
        case .elettronica:
            return [.computer,.domotica,.altro]
        case .veicoli:
            return [.autovettura,.motoveicolo,.bicicletta,.monopattino,.altro]
     
        case .manutenzione:
            return [.ordinaria,.straordinaria]
      
        default: return nil
        }
    }
}

extension HOObjectCategory: HOProWritingDownLoadFilter {
    
    func getRowLabel() -> String {
        return self.rawValue
    }
    
    func getImageAssociated() -> String {
        return "list.bullet.clipboard"
    }
    
    func getColorAssociated() -> Color {
        return Color.seaTurtle_3
    }
}

extension HOObjectCategory: Property_FPC {
    func simpleDescription() -> String {
        return self.rawValue
    }
    
    func returnTypeCase() -> HOObjectCategory {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        return 0 
    }
    
    
}

extension HOObjectCategory:Comparable {
    static func < (lhs: HOObjectCategory, rhs: HOObjectCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
