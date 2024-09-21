//
//  HOReservationStatus.swift
//  hoster
//
//  Created by Calogero Friscia on 30/07/24.
//

import Foundation
import SwiftUI
import MyFilterPack

enum HOReservationPayamentStatus:Int,CaseIterable {
    
    case inPagamento = 0
    case payed
    case partiallyPayed
    case cancelled
    
    func getDescriptionAssociated(to noShow:Int?) -> String {
        
        switch self {

        case .payed:
           
            if let _ = noShow {
                return "l'ospite non si è presentato o ha cancellato e non ha diritto ad un rimborso"
            }
            else { 
                return "la prenotazione risulta usufruita e pagata"
            }
        case .partiallyPayed:
            
            if let _ = noShow {
                return "l'ospite non si è presentato o ha cancellato e ha diritto ad un rimborso parziale"
            } else {
                
                return "la prenotazione risulta usufruita ma l'ospite ha diritto ad un rimborso parziale"
            }
            
        default: return "" // in teoria non si dovebbe verificare in quanto lo stato di noShow è bloccato quando si è in pagamento o cancellato
        }
        
        
    }
    
    func getStringValue() -> String {
        
        switch self {
        case .inPagamento:
            return "in pagamento"
        case .cancelled:
            return "cancellata"
        case .payed:
            return "pagata"
        case .partiallyPayed:
            return "rimborso parziale"
        }
        
    }
    
    func getImageAssociated() -> String {
        
        switch self {
        case .inPagamento:
            return "ellipsis.circle.fill"
        case .payed:
            return "dollarsign.circle.fill"
        case .partiallyPayed:
            return "scissors.circle.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
    
    func getColorAssociated() -> Color {
        
        switch self {
        case .inPagamento:
            return Color.yellow
        case .payed:
            return Color.green
        case .partiallyPayed:
            return Color.orange
        case .cancelled:
            return Color.faluRed_p52
        }
    }
    
    func getTapDescription() -> String {
        
        switch self {
        case .inPagamento:
            return "in arrivo"
        case .payed:
            return "effettuato"
        case .partiallyPayed:
            return "parzialmente rimborsato"
        case .cancelled:
            return "cancellato"
        }
        
    }
}

extension HOReservationPayamentStatus:Codable { }

extension HOReservationPayamentStatus:Property_FPC {
    
    func simpleDescription() -> String {
        self.getStringValue()
    }
    
    func returnTypeCase() -> HOReservationPayamentStatus {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        return self.rawValue
    }
    
    
}


enum HOReservationSchedule:Int,CaseIterable {
    
   // static var allCases: [HOReservationSchedule] = [.inCorso,.inArrivo,.completata,.noShow]
    
    case noShow = 0
    case inArrivo
    case inCorso
    case completata
   
    func getDescriptionAssociated(to statoPagamento:HOReservationPayamentStatus) -> String {
        
        switch self {
        case .noShow:
            switch statoPagamento {
            case .inPagamento:
                return "Error" // una combo che non si dovrebbe verificare
            case .payed:
                return "Prenotazione cancellata senza rimborso"
            case .partiallyPayed:
                return "Prenotazione cancellata con rimborso parziale"
            case .cancelled:
                return "Prenotazione cancellata con rimborso totale"
            }
        case .inArrivo,.inCorso,.completata:
            
            let descr = self.getStringValue()
            
            switch statoPagamento {
            case .inPagamento:
                return "Prenotazione \(descr) in pagamento"
            case .payed:
                return "Prenotazione \(descr) pagata"
            case .partiallyPayed:
                return "Prenotazione \(descr) con rimborso parziale"
            case .cancelled:
                return "Prenotazione \(descr) senza pagamento" //una combo che non dovrebbe verificarsi
            }
        }
        
        
    }
    
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
    
    func getColorAssociated() -> Color {
        
        switch self {
        case .inArrivo:
            return Color.yellow
        case .inCorso:
            return Color.orange
        case .completata:
            return Color.green
        case .noShow:
            return Color.faluRed_p52
        }
    }
    
    func getTapDescription() -> String {
        
        switch self {
        case .inArrivo:
            return "in arrivo"
        case .inCorso:
            return "in corso"
        case .completata:
            return "concluso"
        case .noShow:
            return "annullato"
        }
        
    }
    
}

extension HOReservationSchedule:Property_FPC_Mappable {
    
    var id: String { self.createId() }
    
    func imageAssociated() -> String {
      
        switch self {
        case .noShow:
            return "eye.slash.fill"
        case .inArrivo:
            return "deskclock"
        case .inCorso:
            return "key.fill"
        case .completata:
            return "archivebox.fill"
        }
        
    }
    
    func simpleDescription() -> String {
        switch self {
        case .noShow:
            return "No Show"
        case .inArrivo:
            return "Next Check-in"
        case .inCorso:
            return "Soggiorno in corso"
        case .completata:
            return "Checked-out"
        }
    }
    
    func returnTypeCase() -> HOReservationSchedule {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        
        switch self {
        case .noShow:
            return 3
        case .inArrivo:
            return 1
        case .inCorso:
            return 0
        case .completata:
            return 2
        }
    }

   private func createId() -> String {
       
       self.rawValue.description
       
    }
}

enum HOMonthObject:Property_FPC {
   
    static var calendar = Locale.current.calendar
    
    static var allCases = calendar.monthSymbols.map({HOMonthObject.month($0)})
    
    case month(_:String)
    
    /// ritorna il valore associato che è il monthSymbol del calendario locale
    func simpleDescription() -> String {
       
        switch self {
        case .month(let value):
            return value
        }
    }
    
    func returnTypeCase() -> HOMonthObject {
        return self
    }
    
    func orderAndStorageValue() -> Int {

        let indice = Self.allCases.firstIndex(of: self) as Int?
        
        return indice ?? 99

    }
    
    
}

/*
/// oggetto di servizio per mappare le reservation by month
struct HOReservationMonthIn:Property_FPC_Mappable {
    
    private static var calendar:Calendar { Locale.current.calendar }
    
    static var allMonth:[HOReservationMonthIn] { Self.getAllMonthIn() }
    
    var id: String { self.simpleDescription() }
   
    var month:String
    
    private static func getAllMonthIn() -> [HOReservationMonthIn] {
        
        let allMonth = Self.calendar.monthSymbols.map({HOReservationMonthIn(month: $0)})
        
        return allMonth
    }
    
    func imageAssociated() -> String {
        return "calendar.circle"
    }
    
    func simpleDescription() -> String {
        return month
    }
    
    func returnTypeCase() -> HOReservationMonthIn {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        Self.calendar.monthSymbols.firstIndex(of: self.month) ?? 99
    }
    
    
}
*/
