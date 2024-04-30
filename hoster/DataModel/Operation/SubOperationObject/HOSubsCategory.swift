//
//  HOTypeObjectSubs.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation

enum HOTypeObjectSubs {
    
    // merci
    case food
    case beverage
    
    // utenze
    case luce
    case acqua
    case gas
    
    // canone
    case affitto
    case sitoWeb
    case associazione
    
    // abbonamenti
    case streaming
    case payTv
    case internet
    
    // tributi
    case imu
    case tari
    
    // costiPluriennali
    case elettrodomestici
    case arredi
    case opereMurarie
    case software
    case hardware
    case veicoli
    case ads // pubblicità
    
    // manutenzione
    case ordinaria
    case straordinaria
    
    // quote
    case speseCondominiali
    
    case altro // potremmo associare label
}

enum HOImputationSubs {
    
    // pernottamento
    case booking
    case airbnb
    case direct
    
    // meal
    case pranzo
    case cena
    
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
