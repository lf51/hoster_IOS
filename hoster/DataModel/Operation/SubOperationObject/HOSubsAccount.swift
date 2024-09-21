//
//  HOTypeObjectSubs.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation
import SwiftUI
import MyFilterPack

enum HOObjectSubCategory:String,CaseIterable {
    
    // merci
    case food
    case beverage
    
    // servizi
    case interno
    case esterno
    
    // utenze
    case luce
    case acqua
    case gas
    
    // canone
    case affitto
    case sitoWeb = "sito web"
    case associazione
    
    // abbonamenti
    case streaming
    case payTv = "pay tv"
    case internet
    
    // tributi
    case imu
    case tari
    
    // imposte
    case vat
    case cityTax = "tassa di soggiorno"
    // costiPluriennali
  //  case edifici
    
  //  case costruzioniLeggere = "costruzioni leggere"
    case tettoia
    case baracca // plus altro
  //  case arredi = "mobili e arredi"
    
  //  case biancheria
  //  case attrezzatura
    case stoviglie
    case posate
    case piccoliElettrodomestici = "piccolo elettrodomestico" // plus altro
  //  case impiantiGenerici = "impianto generici"
    case riscaldamento
    case condizionamento

  //  case impiantiSpecifici = "impianto specifici"
    case igienici = "igienico"
    case cucina
    case grandiElettrodomestici = "grande elettrodomestico"
    case ascensore
    case telefonico
    case citofonico
    case wifi = "wifi extender"
    case purificatoreAria = "purificatore aria"
    case purificatoreAcqua = "purificatore acqua"
  //  case elettronica
    case computer
    case domotica
  //  case veicoli
    case autovettura
    case motoveicolo
    case bicicletta
    case monopattino // plus altro
    
   /* case elettrodomestici = "elettrodomestico"
    
    case opereMurarie = "opere murarie"
    case software
    case hardware */
    
  //  case ads = "pubblicità"// pubblicità
    
    // commissioni
    case agenzia
    case bancarie
    
    // manutenzione
    case ordinaria
    case straordinaria
    
    // quote
    case speseCondominiali = "condominio"
    
    case altro /*= "generico"*/ // potremmo associare label
   // case similare
    
}

extension HOObjectSubCategory {
    
    func getUnitMisureAssociated() -> HOAmountUnitMisure {
        
        switch self {
        case .food,.beverage,.stoviglie,.posate:
            return .unit
      
        case .luce:
            return .kw
        case .acqua,.gas:
            return .mc
     
        case .affitto,.streaming,.payTv,.internet,.speseCondominiali:
            return .month
        case .sitoWeb,.associazione,.imu,.tari:
            return .year
      
        case .agenzia,.vat,.bancarie:
            return .percent
        case .cityTax:
            return .pernottamenti
        default: return .standard

        }
        
        
    }
    
}

extension HOObjectSubCategory:HOProWritingDownLoadFilter {
    
    func getRowLabel() -> String {
        self.rawValue
    }
    
    func getImageAssociated() -> String {
        return "list.bullet"
    }
    
    func getColorAssociated() -> Color {
        Color.seaTurtle_2
    }
}

enum HOSubsImputationAccount { // probabile deprecazione
    
    // pernottamento
    case booking
    case airbnb
    case direct
    
    // meal
   // case pranzo
   // case cena
    
    // pulizia
    case programmata
    case ordinaria
    case straordinaria
    
    // marketing
    case ads
    case sitoWeb
    case agenzia
    
    // noleggio
    case auto
    case moto
    case bici
    case monopattino
    
    // transfer
    case aeroporto
    case fuoriPorta
}

extension HOObjectSubCategory: Property_FPC {
    
    func simpleDescription() -> String {
        return self.rawValue
    }
    
    func returnTypeCase() -> HOObjectSubCategory {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        return 0
    }
    
    
    
    
}
