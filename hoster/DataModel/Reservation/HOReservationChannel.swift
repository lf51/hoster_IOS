//
//  HOReservationChannel.swift
//  hoster
//
//  Created by Calogero Friscia on 20/07/24.
//

import Foundation
import MyFilterPack
/// L'utente può creare i suoi canali OTA che saranno salvati nel workspaceData
struct HOOTAChannel:Hashable,Codable {
    
    static func == (lhs:HOOTAChannel,rhs:HOOTAChannel) -> Bool {
        lhs.label == rhs.label
        
    }
    
    let label:String?
    /// valore nominale della percentuale di commissione
    var commissionValue:Double?
    
    /// Trattasi del commissionValue diviso 100
    var commissionPercent:Double { self.getCommissionPercent() }
    
    private func getCommissionPercent() -> Double {
        
        guard let commissionValue else { return 0 }
        
        return commissionValue / 100
        
    }
    
}

extension HOOTAChannel:Property_FPC {
    func simpleDescription() -> String {
        return label ?? "no ota"
    }
    
    func returnTypeCase() -> HOOTAChannel {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        // per ordine di grandezza
        guard let label else { return 0 }
        
        let count = label.count
       
        return count
    }

}


enum HOOTADefaultCase:String,CaseIterable {
    
    static var allCases:[HOOTADefaultCase] = [.booking,.airbnb,.expedia,.direct]
    
    case booking
    case airbnb
    case expedia
    case direct
    
    static func getDefaultOTAChannel() -> [HOOTAChannel] {
        
        let values:[HOOTAChannel] = self.allCases.map({
            
            HOOTAChannel(
                label: $0.getLabelValue(),
                commissionValue: $0.getDefaultOTACommissionPercent())
        })
        
        return values
    }
    
    func getLabelValue() -> String {
        
        switch self {
        case .booking:
            return "booking.com"
        case .airbnb,.expedia,.direct:
            return self.rawValue
     
        }
    }

    func getDefaultOTACommissionPercent() -> Double? {
        
        switch self {
        case .booking:
            return 18
        case .airbnb:
            return 3
        case .expedia:
            return 10
        case .direct:
            return nil
        }
        
    }
    
}
