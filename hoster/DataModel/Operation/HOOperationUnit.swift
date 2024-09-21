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

/// time logic
extension HOOperationUnit {
    
    func getMonthsImputationString(for year:Int) -> [String]? {
        
        guard let timeImputation,
              let mmToYY = timeImputation.monthToYearImputation else { return nil }
        
        
        guard let currentYear = mmToYY[year] else { return nil }
        
        var valueDescription:[String] = []
        
        for mm in currentYear {
            
            let value = csMonthString(from: mm)
            
            valueDescription.append(value)
            
        }
        
        guard !valueDescription.isEmpty else { return nil }
        
        return valueDescription
        
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
    /// computed che deriva dal writing l'areaAccount, In caso il valore sia assente la imposta su corrente
    var operationArea:HOAreaAccount { getAreaAccount() }
    
    private func getAreaAccount() -> HOAreaAccount {
        
        guard let writing,
              let area = writing.operationArea else { return .corrente }
        return area
        
    }
    
}

extension HOOperationUnit:Decodable { 
    
    enum CodingKeys:String,CodingKey {
        
       case uid
       case regolamento
       case timeImputation //= "time_imputation"
       case writing
       case amount
       case note
    
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try container.decode(String.self, forKey: .uid)
        
        self.regolamento = try container.decode(Date.self, forKey: .regolamento)
        
        self.timeImputation = try container.decodeIfPresent(HOTimeImputation.self, forKey: .timeImputation)
        
        self.writing = try container.decodeIfPresent(HOWritingAccount.self, forKey: .writing)
        
        self.amount = try container.decodeIfPresent(HOOperationAmount.self, forKey: .amount)
        
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
    }
    
}

extension HOOperationUnit:Encodable { 
    
    func encode(to encoder: any Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.regolamento, forKey: .regolamento)
        try container.encode(self.timeImputation, forKey: .timeImputation)
        try container.encodeIfPresent(self.writing, forKey: .writing)
        try container.encodeIfPresent(self.amount, forKey: .amount)
        try container.encodeIfPresent(self.note, forKey: .note)
        
        
    }
    
}

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
            return lhs.regolamento > rhs.regolamento
        case nil:
            return false
        }
        
    }
    
    func stringResearch(string: String, readOnlyVM: HOViewModel?) -> Bool {

        guard let writing,
              let spec = writing.oggetto?.specification else { return false }
        
        let ricerca = string.lowercased()

        return spec.lowercased().contains(ricerca)
        
    }
    
    func propertyCompare(coreFilter: CoreFilter<HOOperationUnit>, readOnlyVM: HOViewModel) -> Bool {
        
        let filterProperties = coreFilter.filterProperties
        
        let tipologia = self.writing?.type ?? .acquisto
        let area = self.writing?.operationArea ?? .corrente
        let imputazione = self.writing?.imputationAccount ?? .diversi
        let categoria = self.writing?.oggetto?.getCategoryCase() ?? .altro
        
        let subCategoria = self.writing?.oggetto?.getSubCategoryCase() ?? .altro
        
        let stringResult:Bool = {
            
            let stringa = coreFilter.stringaRicerca
            guard stringa != "" else { return true }
            
            let result = self.stringResearch(string: stringa, readOnlyVM: nil)
            return coreFilter.tipologiaFiltro.normalizeBoolValue(value: result)
            
        }()
        
        return stringResult &&
        coreFilter.comparePropertyToProperty(localProperty: tipologia, filterProperty: filterProperties.tipologia) &&
        coreFilter.comparePropertyToProperty(localProperty: area, filterProperty: filterProperties.area) &&
        coreFilter.comparePropertyToProperty(localProperty: imputazione, filterProperty: filterProperties.imputazione) &&
        coreFilter.comparePropertyToProperty(localProperty: categoria, filterProperty: filterProperties.categoria) &&
        coreFilter.comparePropertyToProperty(localProperty: subCategoria, filterProperty: filterProperties.subCategoria)
    }
    
    struct FilterProperty:SubFilterObject_FPC {
        
        static func reportChange(old: HOOperationUnit.FilterProperty, new: HOOperationUnit.FilterProperty) -> Int {
            
            countManageSingle_FPC(newValue: new.tipologia, oldValue: old.tipologia) +
            countManageSingle_FPC(newValue: new.area, oldValue: old.area) +
            countManageSingle_FPC(newValue: new.imputazione, oldValue: old.imputazione) +
            countManageSingle_FPC(newValue: new.categoria, oldValue: old.categoria) +
            countManageSingle_FPC(newValue: new.subCategoria, oldValue: old.subCategoria)
        }
        
        // tipologia
        // area
        // imputazione
        // categoria
        // sotto categoria
        // mese imputazione
        
        var tipologia: HOOperationType?
        var area: HOAreaAccount?
        var imputazione: HOImputationAccount?
        var categoria: HOObjectCategory?
        var subCategoria: HOObjectSubCategory?
        
        
        
    }
    
    enum SortCondition:SubSortObject_FPC {
        
        static var defaultValue: HOOperationUnit.SortCondition = .regolamento
        
        case regolamento
        
        func simpleDescription() -> String {
            
            switch self {
            case .regolamento:
                return "Data Contabile"
            }
        }
        
        func imageAssociated() -> String {
           
            switch self {
            case .regolamento:
                return "calendar"
            }
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
