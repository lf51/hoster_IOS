//
//  HOCostUnit.swift
//  hoster
//
//  Created by Calogero Friscia on 23/03/24.
//

import Foundation
import MyFilterPack

struct HOOperationUnit:HOProStarterPack {
    
    let uid:String
    var regolamento:Date
    
    var timeImputation:HOTimeImputation?
    
    var writing:HOWritingAccount?
    
    var amount:HOOperationAmount?
    var note:String?

    init() {
        
        self.uid = UUID().uuidString
        self.regolamento = Date()
    }
    
}


extension HOOperationUnit {
    
    var quantityAmountMisureUnit:HOAmountUnitMisure {
        
        guard let writing,
              let object = writing.oggetto else {
            return .standard
        }
        
        if let sub = object.getSubCategoryCase() {
           
            return sub.getUnitMisureAssociated()
            
        }
        else if let category = object.getCategoryCase(),
                let unit = category.getUnitMisureAssociated() { return unit
            
        } else { return .standard }
    }
    
    /// torna true se la quantà parziale è stata eguagliata dalla quantità corrente
    var quantityAmountAchieve:Bool? {
        
        guard let partial = writing?.oggetto?.partialAmount,
              let quantity = partial.quantity else { return nil }
        
        guard let amount,
              let currentQ = amount.quantity else { return nil }
        
        return currentQ == quantity
        
        
    }
}

extension HOOperationUnit {
    
    var writingLabel:String { self.writing?.getWritingLabel() ?? "nuova scrittura" }
    
}

extension HOOperationUnit:Codable { }

extension HOOperationUnit:Hashable {
    
    static func == (lhs: HOOperationUnit, rhs: HOOperationUnit) -> Bool {
        lhs.uid == rhs.uid &&
        lhs.regolamento == rhs.regolamento &&
        lhs.timeImputation == rhs.timeImputation &&
        lhs.writing == rhs.writing &&
        lhs.amount == rhs.amount &&
        lhs.note == rhs.note
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.uid)
    }
}

extension HOOperationUnit {
    
    func getScritturaNastrino<Account:HOProAccountDoubleEntry>(for account:Account) -> HOAccWritingRiclassificato? {
        
        guard let writing,
              let amount else { return nil }
    
        guard var entrySpecification = writing.getWritingRiclassificato(for: account) else { return nil }
        
        entrySpecification.amount = amount
        
        return entrySpecification
       // return nil
        
    }
}

extension HOOperationUnit:Object_FPC {
    
    typealias VM = HOViewModel
    var id: String { self.uid }
    
    static func sortModelInstance(lhs: HOOperationUnit, rhs: HOOperationUnit, condition: SortCondition?, readOnlyVM: HOViewModel) -> Bool {
        
        switch condition {
        case .regolamento:
            return true
        case nil:
            return false
        }
        
    }
    
    func stringResearch(string: String, readOnlyVM: HOViewModel?) -> Bool {
        return true
    }
    
    func propertyCompare(coreFilter: CoreFilter<HOOperationUnit>, readOnlyVM: HOViewModel) -> Bool {
        return true
    }
    
    struct FilterProperty:SubFilterObject_FPC {
        
        static func reportChange(old: HOOperationUnit.FilterProperty, new: HOOperationUnit.FilterProperty) -> Int {
            return 0
        }
        
        var storedTimeImputation:HOTimeImputation?
        
    }
    
    enum SortCondition:SubSortObject_FPC {
        
        static var defaultValue: HOOperationUnit.SortCondition = .regolamento
        
        case regolamento
        
        func simpleDescription() -> String {
            return "not setted"
        }
        
        func imageAssociated() -> String {
            return "circle"
        }
    }
    
}

extension HOOperationUnit:HOProFocusField {
    
    enum FocusField:Int,Hashable {
        
        case writing = 0
        case amount
        case note
        
        
        
    }
    
}

extension HOOperationUnit:HOProNoteField { }
