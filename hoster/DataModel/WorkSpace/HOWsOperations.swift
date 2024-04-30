//
//  HOWsOperations.swift
//  hoster
//
//  Created by Calogero Friscia on 13/04/24.
//

import Foundation



struct HOWsOperations {
    // subCollection Omni Comprensiva
    var all:[HOOperationUnit]
    
    init() {
        
        self.all = []
    }
}

extension HOWsOperations {
    
    var allImputationAccount:[HONastrinoAccount] {
        self.getAllAccount(for: HOImputationAccount.self) }
    
    var allTypeObjectAccount:[HONastrinoAccount] {
        self.getAllAccount(for: HOOperationTypeObject.self)
    }
        
    func getAllAccount(for accountType:HOProAccountDoubleEntry.Type) -> [HONastrinoAccount] {
                
        var allAccount:[HONastrinoAccount] = []
        
        for typeAccount in accountType.allCases {
            
            let mapOPT = self.all.compactMap({
                
                $0.getScritturaNastrino(for: typeAccount)
            })
            
            let account = HONastrinoAccount(label: typeAccount.getIDCode(), all: mapOPT)
            
            allAccount.append(account)
            
        }
    
        return allAccount
    }
    
}



