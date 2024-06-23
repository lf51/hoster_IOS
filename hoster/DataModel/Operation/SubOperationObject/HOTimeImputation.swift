//
//  HOTimeImputation.swift
//  hoster
//
//  Created by Calogero Friscia on 17/05/24.
//

import Foundation

/// Contiene il mese e l'anno di imputazione a cui imputare effettivamente l'operazione. Può ovviamente differire dalla data di regolamento. 
struct HOTimeImputation:Codable,Equatable {
    
    var mese:Int?
    var anno:Int?
    var ammortamento:Int?
  
    /// equivale a 1 diviso gli anni di ammortamento
    var coefficienteAmmortamento:Double? { self.getCoefficenteAmmortamento() }

}

/// ammortamento logic
extension HOTimeImputation {
    
    private func getCoefficenteAmmortamento() -> Double? {
        
        guard let ammortamento else { return nil }
        
        let step_0:Double = 1/Double(ammortamento)
        return step_0
    }
    
    func getYearsAmmortamento() -> [Int] {
        
        guard let anno,
              let ammortamento else { return [] }
        
        var years:[Int] = []
        
        while years.count != ammortamento {
            
            let year = (years.last ?? anno) + 1
            years.append(year)
            
        }
        
        return years
    }
}

/// string property formatted
extension HOTimeImputation {
    
    var cfcAmmortamentoString:String? {
        
        guard let coefficienteAmmortamento else { return nil }
        
        let value = coefficienteAmmortamento.formatted(.percent)
        
        return "Coefficiente Ammortamento \(value)"
        
        
    }
    
    var monthString: String? {
        
        guard let mese,
        mese > 0 else { return nil }
        
        let allMonth = Locale.current.calendar.standaloneMonthSymbols
        return allMonth[mese - 1]
        
        
    }
    
}

extension HOTimeImputation {
    
    func getQuotaAmmortamento(from importo:Double?) -> String {
        
        guard let importo,
        let ammortamento else { return "0.0"}
        
        let quota_0 = importo / Double(ammortamento)
        
        let quota = quota_0.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
        return quota
    }
    
    func getImputationDescription(_ importo:Double?,stringValue:String?) -> String {
        // l'anno deve esserci sempre
        guard let anno,
        let importo,
        let stringValue else { return "error_invalid value" }
        
        // imputazione pluriennale
        
        if let ammortamento,
           let monthString {
            
            let years = self.getYearsAmmortamento()
            let quota = self.getQuotaAmmortamento(from: importo)
            
            return "L'importo di \(stringValue) è ammortizzato in \(ammortamento) annualità \(years.description) da \(quota). Dal \(monthString) del \(anno) al \(monthString) del \(anno + ammortamento)"
        
        }
        // ammortamento nil
        // imputazione nel mese per l'anno
        else if let monthString {
            
            return "L'importo di \(stringValue) è imputato al solo mese di \(monthString) del \(anno)"
            
        }
        // mese e ammortamento nil
        // imputazione per l'anno
        else {
            
            return "L'importo di \(stringValue) è imputato in parti uguali a ciascun mese dell'anno \(anno)"
        }

    }
    
    
}
