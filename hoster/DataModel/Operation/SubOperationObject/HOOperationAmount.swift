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
    case percent = "%"
    case night = "nt"
    case pernottamenti = "pnt"
    case pax = "px"
    case currency
    
    var localCurrencyCode:String {
        return Locale.current.currency?.identifier ?? "USD"
    }
    var localCurrencySymbol:String {
        
        return Locale.current.currencySymbol ?? "$"
    }
    
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
        case .percent:
            return "percent"
        case .night:
            return "notti"
        case .pernottamenti:
            return "pernottamenti"
        case .pax:
            return "persone"
        case .currency:
            return localCurrencyCode
        }
        
        
    }
    
    func getUnitAssociatedNormalized(transform unit:Double) -> Double {
        
        switch self {
            
        case .percent: return unit * 100
        default: return unit
            
        }
        
    }
    
    
}

extension HOAmountUnitMisure:FormatStyle {
    
    typealias FormatInput = Double
    typealias FormatOutput = String
    
    func format(_ value: Double) -> String {
        
        return "\(value)" + " " + self.getRawSymbol()
        
    }
    
    func getRawSymbol() -> String {
        
        switch self {
            
        case .currency:
            return localCurrencySymbol
        default:
            return self.rawValue
        }
        
    }
}

struct HOOperationAmount:Equatable,Hashable {
    
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
        
       /* guard let quantity else { return nil }
        
        let string = String(format:"%.2f", quantity)
        
        return "\(string)" */
        
        self.getQuantityStringValue()
        
    }
    
    var pricePerUnitStringValue:String? {
        
        guard let pricePerUnit else { return nil }

        let value = pricePerUnit.formatted(.currency(code:localCurrencyCode))
        return value
        
    }
    
    var imponibileStringValue:String? {
        
        guard let imponibile else { return nil }

        let value = imponibile.formatted(.currency(code: localCurrencyCode))
        return value
        
        
    }
    
    func getQuantityStringValue(coerent toUnitMeasure:HOAmountUnitMisure? = nil) -> String? {
        
        guard let quantity else { return nil }
 
        guard let toUnitMeasure else {
            
            let string = String(format:"%.1f", quantity)
            
            return string
        }
        
        let normalizeQuantity = toUnitMeasure.getUnitAssociatedNormalized(transform: quantity)
        
        let string2 = String(format:"%.1f", normalizeQuantity)
        
        return string2
        
        
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

extension HOOperationAmount:Codable { }
