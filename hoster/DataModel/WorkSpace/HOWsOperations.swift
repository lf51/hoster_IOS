//
//  HOWsOperations.swift
//  hoster
//
//  Created by Calogero Friscia on 13/04/24.
//

import Foundation

struct HOWsOperations:HOProStarterPack {
    
    let uid: String
    
    var all: [HOOperationUnit]
    
    init(focusUid:String,allOperations:[HOOperationUnit] = []) {
        self.uid = focusUid
        self.all = allOperations
    }
}

extension HOWsOperations {
    
    /// tutte le info delle operazioni fatte | categoria | subCategoria | specification
    var allWritingObject:[HOWritingObject] { self.getAllWritingObject() }
    
    private func getAllWritingObject() -> [HOWritingObject] {
        
        guard !all.isEmpty else { return [] }
        
        let info = all.compactMap({$0.writing?.oggetto})
        return info
        
    }
    
}

extension HOWsOperations {
    
    /// Array di Nastrini dei conti di Imputazione
    var allImputationAccount:[HONastrinoAccount] {
        self.getAllAccount(for: HOImputationAccount.self) }
    /// Array di Nastrini dei conti di categoria
   /* var allCategoryAccount:[HONastrinoAccount] {
        self.getAllAccount(for: HOObjectCategory.self)
    }*/
    var allAreaAccount:[HONastrinoAccount] {
        self.getAllAccount(for: HOAreaAccount.self)
    }
        
    private func getAllAccount<AccountType:HOProAccountDoubleEntry>(for accountType:AccountType.Type) -> [HONastrinoAccount] {
                
        var allAccount:[HONastrinoAccount] = []
        
        for typeAccount in accountType.allCases {
            
           /* let mapOPT = self.all.compactMap({
                
                $0.getScritturaNastrino(for: typeAccount)
            })
            
            let account = HONastrinoAccount(label: typeAccount.getIDCode(), all: mapOPT) */
            let account = getNastrinoAccount(for: typeAccount)
            
            allAccount.append(account)
            
        }
    
        return allAccount
    }
    
    func getNastrinoAccount<Account:HOProAccountDoubleEntry>(for element:Account) -> HONastrinoAccount {
        
        let mapOPT = self.all.compactMap({
            
            $0.getScritturaNastrino(for:element)
        })
        
        let account = HONastrinoAccount(label: element.getIDCode(), all: mapOPT)
        
        return account
    }
    
}



