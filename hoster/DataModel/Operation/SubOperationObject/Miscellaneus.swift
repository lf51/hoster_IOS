//
//  Miscellaneus.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation
import SwiftUI

/// Protocollo per conformare ad una pickerView per filtrare il download delle WritingAccount
protocol HOProWritingDownLoadFilter:Hashable {
    
    static var allCases:[Self] { get }
    
    func getRowLabel() -> String
    func getImageAssociated() -> String
    func getColorAssociated() -> Color
    
}

/*protocol HOProImputationRelated {
    
    associatedtype V:CaseIterable
    
    func getSubRelatedObject(throw type:HOOperationType?) -> [V]?
    func getImputationEnabling(throw type:HOOperationType?)
    
}*/

enum HOAccWritingPosition {
    
    case dare
    case avere
}

enum HOAccWritingSign:CaseIterable {
    
    case plus
    case minus
    
}

/// Enumerazione per categorizzare tutte le struct conformi al protoccolo HOProAccountDoubleEntry, di modo da identificare dai codici salvati su firebase a quale tipo di account si riferiscono, e poi dall'index recuperare il caso specifico
enum HODoubleEntryAccountIndex:String,CaseIterable {
    
    case areaAccount = "AA"
    case imputationAccount = "IA"
  //  case accountImputazione = "SP"
  //  case accountCategoria = "CE"
    
    static func getMainType(from idCode:String) -> (any HOProAccountDoubleEntry.Type)? {
        
        for eachAccount in Self.allCases {
            
            if eachAccount.rawValue == idCode.prefix(2) {
                return eachAccount.getTypeObject() }
            else { continue }
            
        }
        return nil
        
    }
    
    private func getTypeObject() -> any HOProAccountDoubleEntry.Type {
        
        switch self {
        case .areaAccount:
            return HOAreaAccount.self
        case .imputationAccount:
            return HOImputationAccount.self
        }
        
        
    }
    
}


