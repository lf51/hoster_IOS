//
//  HOCheckIn.swift
//  hoster
//
//  Created by Calogero Friscia on 22/03/24.
//

import Foundation

struct HOReservation:HOProStarterPack {
    
    let uid:String
    
    var refUnit:String?
    var dataArrivo:Date?
    var guestName:String?
    var pax:Int?
    var notti:Int?
    var disposizione:[HOBedUnit]?
    var paxEsentiCityTax:Int?
    var grossIncome:Double?
    var note:String?
    
    init() {
        self.uid = UUID().uuidString
    }
}

extension HOReservation {
    
    var pernottamenti:Int? { (self.pax ?? 0) * (self.notti ?? 0) }
    var pernottamentiEsenti:Int? { (self.paxEsentiCityTax ?? 0) * (self.notti ?? 0) }
    var pernottamentiTassati:Int? { (self.pernottamenti ?? 0) - (self.pernottamentiEsenti ?? 0) }
    var checkOut:Date? { self.dataArrivo?.advanced(by: Double(self.notti ?? 0))}
    
}

extension HOReservation:HOProCDCPack {

    static var typeCode: HOTypeCDCcode = .reservation
    
    static var costsAggregationLabel:[HOCostAggregationLabel] = [.pulizia,.lavanderia,.welcome,.colazione]
    
    func getCostKPath(from imputation:HOCostImputation) -> KeyPath<Self,Int?>? {
        
        switch imputation {
        case .reservationItSelf: return nil // deve equivalere a 1
        case .pax: return \.pax
        case .notti: return \.notti
        case .pernottamenti: return \.pernottamenti
       // case .bedUnit: return nil
        }
        
    }
    
    
    enum HOCostImputation:String,HOProObjectCostImputation {
        
        static var allCases:[HOCostImputation] = [.reservationItSelf,.pax,.notti,.pernottamenti]
        
        case reservationItSelf = "001"
        case pax = "002"
        case notti = "003"
        case pernottamenti = "004"
      //  case bedUnit = "005"
        
        func getAsUnitOfMeasure() -> String {
            
            switch self {
            case .reservationItSelf: return "reservation"
            case .pax: return "pax"
            case .notti: return "notte"
            case .pernottamenti: return "pernottamento"
          //  case .bedUnit: return "letto"
            }
            
            
        }
        
        func getCostLabel() -> String {
            
            switch self {
            case .reservationItSelf:
                return "costo a prenotazione"
            case .pax:
                return "costo a persona"
            case .notti:
                return "costo a notte"
            case .pernottamenti:
                return "costo a pernottamento"
            }
        }
    }
    
    
}


