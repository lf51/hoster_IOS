//
//  HONastrinoAccount.swift
//  hoster
//
//  Created by Calogero Friscia on 25/04/24.
//

import Foundation

struct HOAccWritingRiclassificato {
    
    var sign:HOAccWritingSign?
    var info:HOAccWritingInfo?

    var amount:Double?
   
}

struct HONastrinoAccount {
    
    var label:String?
    var all:[HOAccWritingRiclassificato]?
    
}

extension HONastrinoAccount {
    
    var allPlus:[HOAccWritingRiclassificato] { self.allFiltered(by: .plus) }
    var allMinus:[HOAccWritingRiclassificato] { self.allFiltered(by: .minus) }
    
    private func allFiltered(by sign:HOAccWritingSign) -> [HOAccWritingRiclassificato] {
        
        guard let all else { return [] }
        
        return all.filter({ $0.sign == sign })
        
    }
}

/// total and plus minus amount aggregate
extension HONastrinoAccount {
    
    var totalResult:Double { plusResult - minusResult }
    
    var plusResult:Double { self.getAggregate(from: \.allPlus) }
    var minusResult:Double { self.getAggregate(from: \.allMinus )}
    
    /// ATTENZIONE gli amount sono assoluti quindi vanno sommati per segno
    private func getAggregate(from kp:KeyPath<Self,[HOAccWritingRiclassificato]>) -> Double {
        
        let all = self[keyPath: kp]
        
        guard !all.isEmpty else { return 0 }
        
        let reduceTo = all.reduce(into: 0.0) { partialResult, deSpecif in
                
                partialResult += (deSpecif.amount ?? 0)
                
        }
        
        return reduceTo
    }

    
}

extension HONastrinoAccount {
    // 27.04 Temporaneo da sviluppare in ottica di avere per ogni categoria plus minus e sub total. Per ogni sottocategoria di ciascuna categoria il medesimo, e per ogni specifica all'interno di ogni sottoCategoria di ciascuna categoria il medesimo
    var allCategoryIn:[String] { self.getAllInfo(mappedBy: \.category) }
    var allSubsIn:[String] { self.getAllInfo(mappedBy: \.subCategory) }
    var allSpecificIn:[String] { self.getAllInfo(mappedBy: \.specification) }
    
    private func getAllInfo(mappedBy kp:KeyPath<HOAccWritingInfo,String?> ) -> [String] {
     
        guard let all else { return [] }
        
        let values = all.compactMap({$0.info?[keyPath: kp]})
        let cleaned = Set(values)
        return  Array(cleaned)
        
    }
    
}

