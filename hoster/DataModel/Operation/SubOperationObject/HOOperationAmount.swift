//
//  HOOperationAmount.swift
//  hoster
//
//  Created by Calogero Friscia on 28/04/24.
//

import Foundation

enum HOAmountCategory:String,CaseIterable {
    
    case piece = "prezzo unità"
    case pack = "prezzo totale"
    
}

enum HOAmountUnitMisure:String {
    
    case standard = "q"
    case unit = "pz"
    case kw = "kWh"
    case mc
    case hour = "hh"
    case month = "mm"
    case year = "yy"
    
    func getExtendedRawValue() -> String {
        
        switch self {
        case .standard:
            return "quantità"
        case .unit:
            return "unità"
        case .kw:
            return "kilowatt"
        case .mc:
            return "metro cubo"
        case .hour:
            return "ora"
        case .month:
            return "mensilità"
        case .year:
            return "annualità"
        }
        
        
    }
    
    
}

struct HOOperationAmount:Equatable,Hashable,Codable {
    
    var quantity:Double?
    var pricePerUnit:Double?
    
    var imponibile:Double? {
        
        get { self.getImponibile() }
        set { self.setImponibile(newValue: newValue) }
    }
}
/// string property formatted
extension HOOperationAmount {
    
    var localCurrencyCode:String {
        
        return Locale.current.currency?.identifier ?? "USD"
    }
    
    var quantityStringValue:String? {
        
        guard let quantity else { return nil }
        
        let string = String(format:"%.1f", quantity)
        
        return "\(string)"
        
    }
    
    var pricePerUnitStringValue:String? {
        
        guard let pricePerUnit else { return nil }

        let value = pricePerUnit.formatted(.currency(code:localCurrencyCode))
        return "pmc: \(value)"
        
    }
    
    var imponibileStringValue:String? {
        
        guard let imponibile else { return nil }

        let value = imponibile.formatted(.currency(code: localCurrencyCode))
        return value
        
        
    }
    
}
/// get set imponibile
extension HOOperationAmount {
    
    private func getImponibile() -> Double {
        
        guard let quantity,
              let pricePerUnit else { return 0 }
        
        return quantity * pricePerUnit
        
    }
    
    mutating private func setImponibile(newValue:Double?) {
        
        guard let newValue else {
            
            self.quantity = nil
            self.pricePerUnit = nil
            return 
        }
        
        let q = quantity ?? 1
        
        self.quantity = q
        self.pricePerUnit = newValue / q
       

    }
}
