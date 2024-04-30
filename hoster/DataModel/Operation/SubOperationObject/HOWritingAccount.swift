//
//  HOCostLabel.swift
//  hoster
//
//  Created by Calogero Friscia on 23/03/24.
//

import Foundation

protocol HOProAccountDoubleEntry:Encodable {
    
    static var mainIDCode:String { get }
    static var allCases:[Self] { get }
    
    /// indice stringa del case
    func getCaseIndex() -> String
    /// main code del type + indice stringa del case
    func getIDCode() -> String
    
    func getAlgebricSign(from sign: HOAccWritingPosition) -> HOAccWritingSign
}

struct HOAccWritingInfo {
    
    var category:String? //HOOperationTypeObject?
    var subCategory:String?//HOTypeObjectSubs? // non mandatory
    
    var specification:String? // [SubCategoria] - [Label]
}

struct HOWritingAccount {
    
    var dare:String? //IDCode//HOProAccountDoubleEntry?
    var avere:String?//IDCode//HOProAccountDoubleEntry?
    
    var info:HOAccWritingInfo?
    
    func getWritingRiclassificato(for account:HOProAccountDoubleEntry) -> HOAccWritingRiclassificato? {
        
        guard let dare,
              let avere,
              let info else { return nil }
        
        let codeAccount = account.getIDCode()
        var algebricSign:HOAccWritingSign?
        
        if dare == codeAccount {
            
            algebricSign = account.getAlgebricSign(from: .dare)
            
        } else if avere == codeAccount {
            
            algebricSign = account.getAlgebricSign(from: .avere)
            
        } else { return nil }
        
        let wrt = HOAccWritingRiclassificato(
            sign: algebricSign,
            info: info,
            amount: nil)
        
        return wrt

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

