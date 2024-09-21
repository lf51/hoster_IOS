//
//  HOAccountIntermendi.swift
//  hoster
//
//  Created by Calogero Friscia on 29/05/24.
//

import Foundation
import SwiftUI
import MyFilterPack

enum HOAreaAccount:String,CaseIterable,Codable {
    
    case scorte = "magazzino"
    case corrente = "c/c corrente"
    case tributi
    case pluriennale = "f.do Ammortamento"
    
}

/// Description Method
extension HOAreaAccount {
    
    func getDescription(throw type:HOOperationType) -> String? {
        
        let typeValue = type.getDescriptionValue()
       // let associatedType = self.getOperationTypeAssociated()
        
       // if associatedType.contains(type) {
            
        return "\(typeValue) \(self.getGergalRawValue())"
            
       // } else { return nil }
        
    }
 
    private func getGergalRawValue() -> String {
        
        switch self {
        case .scorte:
            return "scorte"
        case .corrente:
            return "corrente"
        case .tributi:
            return "tributi"
        case .pluriennale:
            return "pluriennale"//"bene ammortizzabile"
        }
        
    }
    
}

/// Metodi costruzione Scritture Contabili
extension HOAreaAccount {
    
    func isPMCLock(throw type: HOOperationType) -> Bool {
        
        switch self {
        case .scorte:
            switch type {
            case .acquisto:
                return false
            case .consumo,.resoAttivo:
                return true
            default: return false
           
            }
        case .corrente:
            return false
        case .tributi:
            return false
        case .pluriennale:
            return false 
        }
        
    }
    
    func getOperationTypeAssociated() -> [HOOperationType] {
        
        switch self {
        case .scorte:
            return [.acquisto,.consumo,.resoAttivo]
        case .corrente:
            return [.acquisto,.pagamento,.vendita/*,.resoAttivo*/,.resoPassivo,.regalie]
        case .tributi:
            return [.pagamento,.versamento]
        case .pluriennale:
            return [.acquisto/*,.ammortamento*/] // ammortamento va automatizzato
        }
    }
    
    func getOPTWhereImputationIsEnabled() -> [HOOperationType] {
        
        switch self {
        case .scorte:
            return [.consumo]
        case .corrente:
            return [.acquisto,.pagamento,.resoPassivo,.regalie,.vendita]
        case .tributi:
            return [.pagamento,.versamento]
        case .pluriennale:
            return [.ammortamento]
        }
        
    }
    
    func getSubRelatedObject(throw type: HOOperationType) -> [HOObjectCategory]? {
        
        let typeAssociated = self.getOperationTypeAssociated()
        
        switch self {
        case .scorte:
            
            if typeAssociated.contains(type) { return [.merci]}
            else { return nil }

        case .corrente:
            
            switch type {
            case .acquisto:
                return [.merci,.servizi,.ads]
            case .vendita:
                return [.merci,.servizi]
            case .resoPassivo:
                return [.servizi]
            case .pagamento:
                return [.abbonamentiQuoteCanoni,.commissioni,.manutenzione,.mod,.utenze,.altro]
            case .resoAttivo:
                return nil//[.merci]
            case .regalie:
                return [.tip]
            default: return nil
            }
            
        case .tributi:
            
            switch type {
            
            case .pagamento:
                return [.tassePatrimoniali]
           
            case .versamento:
                return [.imposte]
            default: return nil
            }
            
           /* if typeAssociated.contains(type) { return [.tassePatrimoniali,.imposte]}
            else { return nil }*/
            
        case .pluriennale:

            switch type {
            case .acquisto,.ammortamento:
                return [.edifici,.costruzioniLeggere,.arredi,.biancheria,.attrezzatura,.impiantiGenerici,.impiantiSpecifici,.elettronica,.veicoli]
            default: return nil
            }

        }
        
        
    }

}

extension HOAreaAccount: HOProAccountDoubleEntry {
    
    static let typeCode: HODoubleEntryAccountIndex = .areaAccount
    
    static func getCase(from idCode: String) throws -> HOAreaAccount {
        
        let caseIndex = idCode.dropFirst(2)
        
        for eachCase in Self.allCases {
            
            let index = eachCase.getCaseIndex()
            if index == caseIndex { return eachCase }
            else { continue }
            
        }
        
        throw HOCustomError.erroreGenerico(problem: "idCase conto area non esistente", reason: nil, solution: nil)
    }
    
    func getCaseIndex() -> String {
        
        switch self {
        case .scorte:
            return "02"
        case .corrente:
            return "01"
        case .tributi:
            return "03"
        case .pluriennale:
            return "04"
        }
        
        
    }
    
    func getIDCode() -> String {
        return Self.typeCode.rawValue + self.getCaseIndex()
    }
    
    func getAlgebricSign(from sign: HOAccWritingPosition) -> HOAccWritingSign {
        
        switch sign {
        case .dare:
            return .minus
        case .avere:
            return .plus
        }
        
    }
}

extension HOAreaAccount:HOProWritingDownLoadFilter {
    
    func getRowLabel() -> String {
        
        switch self {
        case .pluriennale:
            return "costo pluriennale"
        default: return self.rawValue
        }
        
    }
    
    func getImageAssociated() -> String {
        
        switch self {
        case .scorte:
            return "storefront"
        case .corrente:
            return "eurosign.arrow.circlepath"
        case .pluriennale:
            return "calendar.badge.clock"
        case .tributi:
            return "building.columns"
        }
    }
    
    func getColorAssociated() -> Color {
        
        switch self {
        case .scorte:
            return Color.yellow.opacity(0.6)
        case .corrente:
            return Color.malibu_p53
        case .pluriennale:
            return Color.cinderella_p47
        case .tributi:
            return Color.hoBackGround
        }
    }
    
}

extension HOAreaAccount: Property_FPC {
    func simpleDescription() -> String {
        return self.rawValue
    }
    
    func returnTypeCase() -> HOAreaAccount {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        switch self {
        case .scorte:
            return 0
        case .corrente:
            return 1
        case .tributi:
            return 2
        case .pluriennale:
            return 3
        }
    }
    
    
    
    
}

extension HOAreaAccount: Property_FPC_Mappable {
   
    var id: String {self.rawValue}
    
    func imageAssociated() -> String {
        self.getImageAssociated()
    }
    
    
}
