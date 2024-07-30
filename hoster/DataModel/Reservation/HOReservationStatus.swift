//
//  HOReservationStatus.swift
//  hoster
//
//  Created by Calogero Friscia on 30/07/24.
//

import Foundation

enum HOReservationPayamentStatus:Int {
    
    case inPagamento = 0
    case cancelled
    case payed
    
    func getStringValue() -> String {
        
        switch self {
        case .inPagamento:
            return "in pagamento"
        case .cancelled:
            return "cancellata"
        case .payed:
            return "pagata"
        }
        
    }
}

extension HOReservationPayamentStatus:Codable { }


enum HOReservationSchedule {
    
    case inArrivo
    case inCorso
    case completata
    case noShow
    
    func getStringValue() -> String {
        
        switch self {
        case .inArrivo:
            return "in arrivo"
        case .inCorso:
            return "in corso"
        case .completata:
            return "conclusa"
        case .noShow:
            return "no show"
        }
        
    }
    
}
