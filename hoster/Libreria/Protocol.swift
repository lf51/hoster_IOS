//
//  Protocol.swift
//  hoster
//
//  Created by Calogero Friscia on 15/03/24.
//

import Foundation

protocol HOProStarterPack {
    
    var uid:String { get }
    
}

protocol HOProFocusField {
    
    associatedtype FocusField:RawRepresentable,Hashable where FocusField.RawValue == Int 
}

protocol HOProNoteField {
    
    var note:String? { get set }
}

protocol HOProAccountDoubleEntry:RawRepresentable,Encodable where RawValue == String {
    
    static var typeCode:HODoubleEntryAccountIndex { get }
    static var allCases:[Self] { get }
    
    /// indice stringa del case
    func getCaseIndex() -> String
    /// typeCode + caseIndex
    func getIDCode() -> String
    /// recupera il case dall'IdCode
    static func getCase(from idCode:String) throws -> Self
    
    func getAlgebricSign(from sign: HOAccWritingPosition) -> HOAccWritingSign
}
