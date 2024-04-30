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

    var refUnit:String?
    var refOperations:[String]? // operazioni associate // vendita servizio pernottamento, vendita servizio colazione transfer etc. Associabili in fase di creazione attraverso un default che possiamo fare impostare all'utente, con i servizi inclusi nella reservation, e possiamo associare in seguito ad esempio per il sopravvenire di regali e mance.
    
    var dataArrivo:Date?
    var guestName:String?
    var guestType:HOGuestType?
    var pax:Int?
    var notti:Int?
    var disposizione:[HOBedUnit]?
    
    var pernottamentiEsentiCityTax:Int? // ??
    
    var note:String?
    
    init() {
        self.uid = UUID().uuidString
    }
}

extension HOReservation:Hashable {
    
    static func == (lhs: HOReservation, rhs: HOReservation) -> Bool {
        lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
    
    
}

extension HOReservation {
    
    var pernottamenti:Int? { (self.pax ?? 0) * (self.notti ?? 0) }
    var pernottamentiTassati:Int? { (self.pernottamenti ?? 0) - (self.pernottamentiEsentiCityTax ?? 0) }
    var checkOut:Date? { self.dataArrivo?.advanced(by: Double(self.notti ?? 0))}
    
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
        
        var unitRef:String?
        static func reportChange(old: HOReservation.FilterProperty, new: HOReservation.FilterProperty) -> Int {
            
            return 0
            
        }
        
        
        
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
