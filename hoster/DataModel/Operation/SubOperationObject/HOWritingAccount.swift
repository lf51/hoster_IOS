//
//  HOCostLabel.swift
//  hoster
//
//  Created by Calogero Friscia on 23/03/24.
//

import SwiftUI

struct HOWritingAccount:Equatable,Codable {

    var type:HOOperationType?
    
    var dare:String? //IDCode//HOProAccountDoubleEntry?
    var avere:String?//IDCode//HOProAccountDoubleEntry?
    
    var oggetto:HOWritingObject?

}

extension HOWritingAccount {
    
    var operationArea:HOAreaAccount? { self.getDoubleEntryAccount() }
    
    var imputationAccount:HOImputationAccount? { self.getDoubleEntryAccount() }
    
    private func getDoubleEntryAccount<E:HOProAccountDoubleEntry>() -> E? {
        
        for eachCase in E.allCases {
            
            let defaultIdCase = eachCase.getIDCode()
            if defaultIdCase == dare ||
                defaultIdCase == avere { return eachCase }
            else { continue }
            
        }
        
        return nil // in teoria non viene mai eseguito. Si può fare meglio
    }
    
}

extension HOWritingAccount {
    
    func getWritingRiclassificato<Account:HOProAccountDoubleEntry>(for account:Account) -> HOAccWritingRiclassificato? {
        
        guard /*let dare,
              let avere,*/
              let oggetto else { return nil }
        
        let codeAccount = account.getIDCode()
        var algebricSign:HOAccWritingSign?
        
        if self.dare == codeAccount {
            
            algebricSign = account.getAlgebricSign(from: .dare)
            
        } else if self.avere == codeAccount {
            
            algebricSign = account.getAlgebricSign(from: .avere)
            
        } else { return nil }
        
        let wrt = HOAccWritingRiclassificato(
            info: oggetto, 
            sign: algebricSign,
            amount: nil)
        
        return wrt

    }
}

extension HOWritingAccount {
    
    var imputationStringValue:String {
        
        guard let imputationAccount else { 
            return "\(self.operationArea?.rawValue ?? "")" }
        
        return "conto \(imputationAccount.rawValue)"
        
    }
    
    /// Ritorna la descrizione della scrittura. Tipo: consumo scorte merci cocaCola per colazione
    func getWritingDescription() -> String? {
        
        guard let type,
              let operationArea,
              let oggetto else { return nil }
    
        let areaValue = operationArea.getDescription(throw: type) ?? "[no area]"
      
        let oggettoValue = oggetto.getDescription(campi:\.subCategory, \.specification)
        
       // let imputationValue = imputationAccount == nil ? "\(operationArea.rawValue)" : "conto \(imputationAccount!.rawValue)"
        
        let preposition = type.getPrepositionAssociated()
        
        return "\(areaValue.csCapitalizeFirst()) (\(oggettoValue)) \(preposition) \(imputationStringValue)."
        
    }
 
    func getWritingLabel() -> String {
        
        guard let type,
              let operationArea,
              let areaValue = operationArea.getDescription(throw: type) else { return "nuova scrittura" }
        
       return areaValue
        
    }
    
}

/*extension HOWritingAccount:Encodable {
    
    enum CodingKeys:String,CodingKey {
        
        case dare
        case avere
        case specification
    }
    
    func encode(to encoder: any Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
      //  let dareCode = self.dare?.getIDCode()
        
        try container.encode(self.dare, forKey: .dare)
        try container.encode(self.avere, forKey: .avere)
        try container.encode(self.specification, forKey: .specification)
        
        
    }
}*/

