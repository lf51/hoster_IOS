//
//  HOSyncroDocumentManager.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import Combine
import FirebaseFirestoreInternal

protocol HOProSyncroManager {
    
    var mainTree:CollectionReference? { get }
    
    func setMainTree(to newValue:CollectionReference?)
}

protocol HOProCodable {
    
    static func getQueryFilterValue(_ mainTree:CollectionReference, for years:[Int]?) -> Query
    
    /// enum di campi string per le proprietà. Utile per recuperare le chiavi del database per i salvataggi single Value o per il filtraggio
    associatedtype InternalPropertyStringValue:RawRepresentable where InternalPropertyStringValue.RawValue == String
}

final class HOSyncroDocumentManager<Item:Codable>:HOProSyncroManager {
    
    private(set) var mainTree:CollectionReference?
    
    var listener:ListenerRegistration?
    var publisher = PassthroughSubject<Item?,Error>()
    
    init(mainTree:CollectionReference? = nil) {
        self.mainTree = mainTree
    }

    func setMainTree(to newValue:CollectionReference?) {
        
        self.mainTree = newValue
    }

}

final class HOSyncroCollectionManager<Item:Codable&HOProCodable>:HOProSyncroManager {
    
    private(set) var mainTree:CollectionReference?
    
    var listener:ListenerRegistration?
    var publisher = PassthroughSubject<(String?,[Item]?),Error>()
    
    init(mainTree:CollectionReference? = nil) {
        self.mainTree = mainTree
    }

    func setMainTree(to newValue:CollectionReference?) {
        
        self.mainTree = newValue
    }
    
    func getCollectionParentDocumentID() -> String? {
        
        guard let mainTree else { return nil }
        
        return mainTree.parent?.documentID
    }
    
    func getMainQuery(filteredBy years:[Int]?) throws -> Query {
        
        guard let mainTree else {
            
            throw HOCustomError.mainRefCorrotto
        }
        
        let filtered = Item.getQueryFilterValue(mainTree, for: years)
        
        return filtered
    }
}

extension HOReservation:HOProCodable {
    
   static var calendar:Calendar { Locale.current.calendar }
    
   static func getQueryFilterValue(_ mainTree:CollectionReference, for years:[Int]?) -> Query {
        
        guard let years,
              let bottomValue = years.min(),
              let topValue = years.max() else {
            print("ERROR !!! no years or bottom or top")
            return mainTree
        }
        
       guard let bottomDate = DateComponents(calendar:calendar,year:bottomValue,month: 1,day: 1).date,
             let topDate =  DateComponents(calendar:calendar,year:topValue,month: 12,day: 31).date else {
           
           print("ERROR !!! no top or bottom date")
           return mainTree }
       
       let key = InternalPropertyStringValue.dataArrivo.rawValue
       
     //  let currentQuery:Query = mainTree
       //    .whereField(key, isGreaterThanOrEqualTo: bottomDate)
        //   .whereField(key, isLessThanOrEqualTo: topDate)
       
       let currentQuery = mainTree
            .whereFilter(
            
                Filter.andFilter([
                
                    Filter.whereField(key, isGreaterOrEqualTo: bottomDate),
                    Filter.whereField(key, isLessThanOrEqualTo: topDate)
                
                
                ])
            
            )
       
           
       return currentQuery

        
    }
    
    enum InternalPropertyStringValue:String {
        
        case scheduleCache = "schedule_cache"
        case statoPagamento = "stato_pagamento"
        case dataArrivo = "data_arrivo"
    }
    
}

extension HOOperationUnit:HOProCodable {
    
    static func getQueryFilterValue(_ mainTree: CollectionReference, for years: [Int]?) -> Query {
        
        guard let years else { return mainTree }

        let fieldPath = FieldPath([InternalPropertyStringValue.timeImputation.rawValue,InternalPropertyStringValue.yyImputation.rawValue])
        
        let rootKey = InternalPropertyStringValue.timeImputation.rawValue

       let currentQuery = mainTree
            .whereFilter(
            
                Filter.orFilter([
                
                    Filter.whereField(rootKey, isEqualTo: NSNull()),
                    Filter.whereField(fieldPath, arrayContainsAny: years)
                
                ])
            
            )

         return currentQuery
    }
    
    enum InternalPropertyStringValue:String {
        
       case timeImputation = "time_imputation"
       case yyImputation = "yy_imputation"
    }
    
    
}

extension HOUnitModel:HOProCodable {
    
    static func getQueryFilterValue(_ mainTree: CollectionReference, for years: [Int]?) -> Query {
        return mainTree
    }
    
    enum InternalPropertyStringValue:String {
        // empty non in uso.
        case emptyValue = "empty"
            
    }
    
}
