//
//  HOOperationAmount.swift
//  hoster
//
//  Created by Calogero Friscia on 28/04/24.
//

import Foundation

struct HOOperationAmount {
    
    var unitMeasure:String? { return nil } // derivata da altr info // HOOperationUnitMeasure
    var quantity:Double?
    var pricePerUnit:Double?
}

extension HOOperationAmount {
    
    var imponibile:Double {
        
        get { self.getImponibile() }
        set { self.setImponibile(newValue: newValue) }
    }
    
    private func getImponibile() -> Double {
        
        guard let quantity,
              let pricePerUnit else { return 0 }
        
        return quantity * pricePerUnit
        
    }
    
    mutating private func setImponibile(newValue:Double) {
        
        let q = quantity ?? 1
        
        self.quantity = q
        self.pricePerUnit = newValue / q
        
    }
}
