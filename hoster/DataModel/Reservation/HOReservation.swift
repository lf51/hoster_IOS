//
//  HOCheckIn.swift
//  hoster
//
//  Created by Calogero Friscia on 22/03/24.
//

import Foundation
import MyFilterPack

struct HOReservation:HOProStarterPack {
    
    let uid:String

    var refUnit:String? //
    var refOperations:[String]? // operazioni associate // vendita servizio pernottamento, vendita servizio colazione transfer etc. Associabili in fase di creazione attraverso un default che possiamo fare impostare all'utente, con i servizi inclusi nella reservation, e possiamo associare in seguito ad esempio per il sopravvenire di regali e mance.
    
    var dataArrivo:Date? //
    var guestName:String? //
    var guestType:HOGuestType? //
    var pax:Int? //
    var notti:Int? //
    var disposizione:[HOBedUnit]? //
    
    var pernottamentiEsentiCityTax:Int? // ??
    
    var note:String? //
    
    init() {
        self.uid = UUID().uuidString
    }
}

/// validation Logic
extension HOReservation {
    
    func isBedDispoCoerentToPax() -> Bool {
        
        guard let pax,
              let disposizione,
              !disposizione.isEmpty else { return false }
        
        let maxPaxFromDispo:Int = {
            
            var max:Int = 0
            
            for eachBed in disposizione {
                
                let maxPax = eachBed.bedType?.getMaxCapability() ?? 0
                
                let value = maxPax * (eachBed.number ?? 0)
                max += value
            }
            
            return max
            
        }()
        
        return pax <= maxPaxFromDispo
 
    }
    
    func isBedDispoCoerentToPaxThrowing() throws -> Bool {
        
        guard let pax,
              let disposizione,
              !disposizione.isEmpty else {
            
            throw HOCustomError.erroreGenerico(problem: "Disposizione letti e/o pax incompleta", reason: nil, solution: nil)
            
        }
        
        let maxPaxFromDispo:Int = {
            
            var max:Int = 0
            
            for eachBed in disposizione {
                
                let maxPax = eachBed.bedType?.getMaxCapability() ?? 0
                
                let value = maxPax * (eachBed.number ?? 0)
                max += value
            }
            
            return max
            
        }()
        
        return pax <= maxPaxFromDispo
 
    }
}

extension HOReservation:Hashable {
    
    static func == (lhs: HOReservation, rhs: HOReservation) -> Bool {
        lhs.uid == rhs.uid &&
        lhs.guestType == rhs.guestType &&
        lhs.guestName == rhs.guestName &&
        lhs.pax == rhs.pax &&
        lhs.dataArrivo == rhs.dataArrivo &&
        lhs.notti == rhs.notti &&
        lhs.disposizione == rhs.disposizione &&
        lhs.note == rhs.note
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.uid)
    }
    
    
}

/// logica pernottamento
extension HOReservation {
    
    var pernottamenti:Int { getPernottamenti() }
    var pernottamentiTassati:Int? { (self.pernottamenti) - (self.pernottamentiEsentiCityTax ?? 0) } // forse inutile
    var checkOut:Date { getCheckOut() }
    
    private func getPernottamenti() -> Int {
        
        guard let pax,
              let notti else { return 0 }
        
        return pax * notti
    }
    
    private func getCheckOut() -> Date {
        
        guard let dataArrivo else {
            
            let out = Date().addingTimeInterval(86400) // + one day
            return out }
        
        guard let notti else {
            
            let out = dataArrivo.addingTimeInterval(86400)
            return out
        }
        
        let nightInterval = TimeInterval(86400 * notti)
        
        return dataArrivo.addingTimeInterval(nightInterval)
            
    }
    
}

extension HOReservation:Codable { }

extension HOReservation:Object_FPC {
  
    typealias VM = HOViewModel
    var id: String { self.uid }
  
    static func sortModelInstance(lhs: HOReservation, rhs: HOReservation, condition: SortCondition?, readOnlyVM: HOViewModel) -> Bool {
        
        switch condition {
        case .dataArrivo:
            return true
        case nil:
            return false
        }
        
    }
    
    func stringResearch(string: String, readOnlyVM: HOViewModel?) -> Bool {
        return true
    }
    
    func propertyCompare(coreFilter: MyFilterPack.CoreFilter<HOReservation>, readOnlyVM: HOViewModel) -> Bool {
        return true
    }
    
    struct FilterProperty:SubFilterObject_FPC {
        
        static func reportChange(old: HOReservation.FilterProperty, new: HOReservation.FilterProperty) -> Int {
            
            return 0
            
        }
        
        var unitRef:String?
      
    
    }
    
    enum SortCondition:SubSortObject_FPC {
        
        static var defaultValue: HOReservation.SortCondition = .dataArrivo
        
        case dataArrivo
        
        func simpleDescription() -> String {
            return "no ready"
        }
        
        func imageAssociated() -> String {
            return "circle"
        }
        
    }
   
}

extension HOReservation:HOProFocusField {
    
    enum FocusField:Int,Hashable {
        
        case refUnit = 0
        
        case arrivo
        case guest
        case guestType
        
        case pax
        case notti
        case disposizione
        
        case pernottEsenti
        case note
        
    }
}

extension HOReservation:HOProNoteField { }

/// logica descrizion
extension HOReservation {
    
    var labelModCompile:String { getLabelModCompile() }
     
    private func getLabelModCompile() -> String {
         
        guard let guestName else {
            
            return "Nuova Prenotazione"
        }
        
        return guestName
         
         
     }
}
