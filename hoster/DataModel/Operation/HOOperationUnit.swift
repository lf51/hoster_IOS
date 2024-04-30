//
//  HOCostUnit.swift
//  hoster
//
//  Created by Calogero Friscia on 23/03/24.
//

import Foundation

enum HOTimeImputation {
    
    case annuale(_ anno:Int)
    case mensile(_ mese:Int)
    case pluriennale(_ periodoAmmortamento:Int)
    
}

struct HOOperationUnit:HOProStarterPack {
    
    let uid:String
    
    var regolamento:Date?
    var storedTimeImputation:HOTimeImputation?
   
    var classification:HOOptClassification?
    var writing:HOWritingAccount?
    var amount:HOOperationAmount?
  
    var note:String?

    init() {
        
        self.uid = UUID().uuidString
                
    }
    
}


extension HOOperationUnit {
    
    func getScritturaNastrino(for account:HOProAccountDoubleEntry) -> HOAccWritingRiclassificato? {
        
        guard let writing,
              let amount else { return nil }
    
        guard var entrySpecification = writing.getWritingRiclassificato(for: account) else { return nil }
        
        entrySpecification.amount = amount.imponibile
        
        return entrySpecification
        
    }
    
   /* func getScritturaNastrino(for account:HOOperationTypeObject) -> HOAccWritingRiclassificato? {
        
        guard let writing,
              let amount else { return nil }
    
        guard var entrySpecification = writing.getEntrySpecification(for: account) else { return nil }
        
        entrySpecification.amount = amount.imponibile
        
        return entrySpecification
        
    } */
    
    
}

// 
