//
//  HONastrinoAccount.swift
//  hoster
//
//  Created by Calogero Friscia on 25/04/24.
//

import Foundation
/// Oggetto per riclassificare un'operazione. Abbiamo il segno (plus minus) le info della scrittura, e l'amount
struct HOAccWritingRiclassificato {
    
    var info:HOWritingObject?
    
    var sign:HOAccWritingSign?
    var amount:HOOperationAmount?
   // var amount:Double?
   // var quantity:Double?
   
}
/// Nastrino con una label del conto ( conto di imputazione o conto di categoria) e un array di Scritture Contabili Riclassificate
struct HONastrinoAccount {
    
    var label:String?
    var all:[HOAccWritingRiclassificato]?
    
}

/// logica sulle quantità
extension HONastrinoAccount {
    
    var qPlus:Double { getQ(from: \.allPlus) }
    var qMinus:Double { getQ(from: \.allMinus) }
    var qTotal:Double { qPlus - qMinus }
    
    var average:Double {
        
        let value = totalResult / qTotal
        if value.isNaN { return 0 }
        else { return value }
    }
    
    private func getQ(from kp:KeyPath<Self,[HOAccWritingRiclassificato]>) -> Double {
        
        let all = self[keyPath: kp]
        
        let quantity = all.compactMap({$0.amount?.quantity})
        
        let result = quantity.reduce(0, +)
        
        return result
        
    }
    
}

extension HONastrinoAccount {
    
    /// Tutte le scritture riclassificate e compattate per segno plus
    var allPlus:[HOAccWritingRiclassificato] { self.allFiltered(by: .plus) }
    /// Tutte le scritture riclassificate e compattate per segno minus
    var allMinus:[HOAccWritingRiclassificato] { self.allFiltered(by: .minus) }
    
    private func allFiltered(by sign:HOAccWritingSign) -> [HOAccWritingRiclassificato] {
        
        guard let all else { return [] }
        
        return all.filter({ $0.sign == sign })
        
    }
}

/// total and plus minus amount aggregate
extension HONastrinoAccount {
    
    /// risultato netto (plus meno minus ) del conto
    var totalResult:Double { plusResult - minusResult }
    
    /// Somma scritture plus
    var plusResult:Double { self.getAggregate(from: \.allPlus) }
    /// somma scritture minus
    var minusResult:Double { self.getAggregate(from: \.allMinus )}
    
    /// ATTENZIONE gli amount sono assoluti quindi vanno sommati per segno
    private func getAggregate(from kp:KeyPath<Self,[HOAccWritingRiclassificato]>) -> Double {
        
        let all = self[keyPath: kp]
        
        guard !all.isEmpty else { return 0 }
        
        let reduceTo = all.reduce(into: 0.0) { partialResult, deSpecif in
                
            partialResult += (deSpecif.amount?.imponibile ?? 0)
                
        }
        
        return reduceTo
    }

    
}

/// logica intorno oggetto (info) del nastrino
extension HONastrinoAccount {
    
    /// Contiene tutti i nastrini riclassificati raggruppati in un dizionario dove la chiave è il WritingObject e il valore è un array di tuple (segno e amount)
    var allObjectDictionaryAggregation:[HOWritingObject:[(HOAccWritingSign,HOOperationAmount)]] { self.getObjectDictAggregation() } // forse deprecabile
    
    private func getObjectDictAggregation() -> [HOWritingObject:[(HOAccWritingSign,HOOperationAmount)]]  {
        
        guard let all else { return [:] }
        
        var aggregateObject:[HOWritingObject:[(HOAccWritingSign,HOOperationAmount)]] = [:]
        
        let allObject = all.compactMap({$0.info})
        
        for eachObject in allObject {
            
            let allFiltered = all.filter({$0.info == eachObject})
            
            let x:[(HOAccWritingSign,HOOperationAmount)] = allFiltered.compactMap({
                
                if let sign = $0.sign,
                   let amount = $0.amount {
                    return (sign,amount)
                } else { return nil }
               
            })
            aggregateObject.updateValue(x, forKey: eachObject)
        }
        
        return aggregateObject
    } // forse deprecabile
    
    /// Array di writing object con amount a saldo. La quantià sarà il saldo fra quella entrata e quella in uscita, il prezzo per unità sarà il prezzo medio o delle quantità in etrata o delle quantità in uscita a seconda del saldo quantità
    var getObjectWithPartialAmount:[HOWritingObject]? {
        self.getWritingObjectWithPatialAmount()
        
    }
    
    private func getWritingObjectWithPatialAmount() -> [HOWritingObject]? {
        
        guard let all else { return nil }
        
        var noZeroObject:[HOWritingObject] = []
        
        let allObject = all.compactMap({$0.info})
        
        let removeObjectDuplicated = Set(allObject)
        let allObjectCleaned = Array(removeObjectDuplicated)
        
        for eachObject in allObjectCleaned {
            
            let allFiltered = all.filter({$0.info == eachObject})
            
            let allFilteredPlus = allFiltered.filter({$0.sign == .plus})
            let allPlusAmount = allFilteredPlus.compactMap({$0.amount})
            
            let allFilteredMinus = allFiltered.filter({$0.sign == .minus})
            let allMinusAmount = allFilteredMinus.compactMap({$0.amount})
            
            
            let reduceAmountPlus:HOOperationAmount = self.getQandPMC(from: allPlusAmount)
            let reduceAmountMinus:HOOperationAmount = self.getQandPMC(from: allMinusAmount)
 
            let result:HOOperationAmount = {
                
                guard let qPlus = reduceAmountPlus.quantity,
                      let qMinus = reduceAmountMinus.quantity else { return HOOperationAmount()}
                
                let qResult = qPlus - qMinus
                
                guard let pPlus = reduceAmountPlus.pricePerUnit,
                      let pMinus = reduceAmountMinus.pricePerUnit else {
                    return HOOperationAmount(quantity: qResult, pricePerUnit: nil)
                }
                
                if qResult > 0 {
                    
                    return HOOperationAmount(quantity: qResult,pricePerUnit: pPlus)
                    
                } else if qResult < 0 {
                    
                    return HOOperationAmount(quantity: qResult, pricePerUnit: pMinus)
                    
                } else {
                    return HOOperationAmount(quantity: 0,pricePerUnit: 0)
                }
                
                
            }()
            
            var new = eachObject
            new.setPartialAmount(newValue: result)
            noZeroObject.append(new)
            
        } // chiusa for in
        
        guard !noZeroObject.isEmpty else { return nil }
        
        return noZeroObject
    }
    
    /// Riduce un insieme di operationAmount in un unico HOOperation amount con la quantità totale e il prezzo medio di carico
    private func getQandPMC(from amounts:[HOOperationAmount]) -> HOOperationAmount {
        
        var totalQ:Double = 0
        var numeratorePMC:Double = 0
        
        for eachAmount in amounts {
            
            if let q = eachAmount.quantity,
               let p = eachAmount.pricePerUnit {
                
                let ponderazione = q * p
                
                numeratorePMC += ponderazione
                totalQ += q
                
            } else { continue }
            
        }
        
        let pmc = numeratorePMC / totalQ
        
        return HOOperationAmount(quantity: totalQ, pricePerUnit: pmc)
        
    }
    
   /* private func getWritingObjectResult(in path:KeyPath<HOOperationAmount,Double?>) -> [(HOWritingObject,Double)]? {
        
        guard let all else { return nil }
        
        var noZeroObject:[(HOWritingObject,Double)] = []
        
        let allObject = all.compactMap({$0.info})
        let removeObjectDuplicated = Set(allObject)
        let allObjectCleaned = Array(removeObjectDuplicated)
        
        for eachObject in allObjectCleaned {
            
            let allFiltered = all.filter({$0.info == eachObject})
            
            let allFilteredPlus = allFiltered.filter({$0.sign == .plus})
            let allFilteredMinus = allFiltered.filter({$0.sign == .minus})
            
            let reducePlus = allFilteredPlus.reduce(into: 0.0) { partialResult, element in
                
                partialResult += element.amount?[keyPath: path] ?? 0
                    
            }
            
            let reduceMinus = allFilteredMinus.reduce(into: 0.0) { partialResult, element in
                    
                partialResult += element.amount?[keyPath: path] ?? 0

            }
            
            let result = reducePlus - reduceMinus
            let x = (eachObject,result)
            
            noZeroObject.append(x)
            
        } // chiusa for in
        
        guard !noZeroObject.isEmpty else { return nil }
        
        return noZeroObject
    }*/ // backup
    
    
}


extension HONastrinoAccount {
    // 27.04 Temporaneo da sviluppare in ottica di avere per ogni categoria plus minus e sub total. Per ogni sottocategoria di ciascuna categoria il medesimo, e per ogni specifica all'interno di ogni sottoCategoria di ciascuna categoria il medesimo
    var allCategoryIn:[String] { self.getAllInfo(mappedBy: \.category) }
    var allSubsIn:[String] { self.getAllInfo(mappedBy: \.subCategory) }
    var allSpecificIn:[String] { self.getAllInfo(mappedBy: \.specification) }
    
    private func getAllInfo(mappedBy kp:KeyPath<HOWritingObject,String?> ) -> [String] {
     
        guard let all else { return [] }
        
        let values = all.compactMap({$0.info?[keyPath: kp]})
        let cleaned = Set(values)
        return  Array(cleaned)
        
    } // verificare utilità
    
    // ok
    var allObjectInNoPartialAmount:[HOWritingObject]? { self.getAllObjectNoPartialAmount() }
    
    private func getAllObjectNoPartialAmount() -> [HOWritingObject]? {
        
        guard let all else { return nil }
        
        let obcMap = all.compactMap({$0.info})
        
        guard !obcMap.isEmpty else { return nil }
        
        let cleanedByDuplicate = Set(obcMap)
        
        return Array(cleanedByDuplicate)
        
    }
    
}

