//
//  HOCostUnit.swift
//  hoster
//
//  Created by Calogero Friscia on 23/03/24.
//

import Foundation

/// da mettere su un frameWork
protocol HOProCDCPack {
    
    associatedtype SubCostImputation:HOProObjectCostImputation
    associatedtype TypeCode:HOProCDCTypeCode
    
    static var typeCode:TypeCode { get }
    
    static var costsAggregationLabel:[HOCostAggregationLabel] { get }
    
    func getCostKPath(from imputation:SubCostImputation) -> KeyPath<Self,Int?>?
    
}

protocol HOProObjectCostImputation {
    
    static var allCases:[Self] { get }
    
    func getAsUnitOfMeasure() -> String
    
    func getCostLabel() -> String
    
}

protocol HOProCDCTypeCode {
    
    static var allCases:[Self] { get }
    static var allCDCType:[any HOProCDCPack] { get }
    
    func getCDCType() -> any HOProCDCPack
}
//
enum HOTypeCDCcode:String,HOProCDCTypeCode {
    
    static var allCases: [HOTypeCDCcode] = [.unitModel,.reservation,.bedUnit]
    static var allCDCType: [any HOProCDCPack] {
        allCases.map({$0.getCDCType()})
    }
    
    case unitModel = "ho_000"
    case reservation = "ho_001"
    case bedUnit = "ho_002"
    
    func getCDCType() -> any HOProCDCPack {
        
        switch self {
        case .unitModel: return HOUnitModel.self as! (any HOProCDCPack)
        case .reservation: return HOReservation.self as! (any HOProCDCPack)
        case .bedUnit: return HOBedUnit.self as! (any HOProCDCPack)
            
        }
        
    }
}


struct HOCostUnit {
    
    let uid:String
    // imputazione automatica
    /// codice per identificare l'oggetto Centro di costo
    var cdcTypeCode:String?
    /// codice con cui risalire al keyPath della proprietà del CDC a cui imputare il costPerUnit
    var kpCDCImputationUnitCode:String?
    
    /// riferimento all'istanza di centro di costo a cui è imputato
    var refCDC:String?
    
    var aggregationLabel:String? // scelta dall'utene
    var costLabel:String? // derivata dall'unità di imputazione
    
    var imputationUnit:Double? // arriva da fuori e non viene modificata
    /// costo per unità
    var costPerUnit:Double?
    
    var note:String?

    init() {
        
        self.uid = UUID().uuidString
                
    }
    
}

extension HOCostUnit {
    
    func checkIsreadyToBeStored() throws -> Bool {
        
        guard self.aggregationLabel != nil else {
            throw HOCustomError.erroreGenerico(problem: "label di aggregazione assente")
        }
        
        guard self.costLabel != nil else {
            throw HOCustomError.erroreGenerico(problem: "label di costo assente")
        }
        
        guard self.costPerUnit != nil else {
            
            throw HOCustomError.erroreGenerico(problem: "Costo per Unità assente")
        }
        
        guard self.cdcTypeCode != nil else {
            
           let result = try checkIsFinalImputationReady()
            return result
        }
        
       let result = try checkIsAutomaticImputationReady()
        return result
    }
    
    private func checkIsFinalImputationReady() throws -> Bool { 
        
        guard self.refCDC != nil else {
            throw HOCustomError.erroreGenerico(problem: "Centro di costo non assegnato")
        }
        
        guard self.imputationUnit != nil else {
            throw HOCustomError.erroreGenerico(problem: "Unità di imputazione non assegnata")
        }
    
        return true
    }
    
    private func checkIsAutomaticImputationReady() throws -> Bool { 
        
        guard self.kpCDCImputationUnitCode != nil else {
            throw HOCustomError.erroreGenerico(problem: "Unità di imputazione costi mancante",solution: "Selezionare unità di imputazione")
        }
        
        return true
    }
    
}
/// final Value Logic
extension HOCostUnit {
    
     var finalCost:Double {
         
         get { self.getFinalCost() }
         
         set { self.setFinalCost(to: newValue) }
     }
    
    private func getFinalCost() -> Double { 
        (self.imputationUnit ?? 0) * (self.costPerUnit ?? 0)
    }
    
   mutating private func setFinalCost(to newValue:Double) {
        
        let currentUnit = self.imputationUnit ?? 1

        self.costPerUnit = newValue / currentUnit
    }
    
}


extension HOCostUnit:Decodable {
    
    static let codingInfo:CodingUserInfoKey = CodingUserInfoKey(rawValue: "hoCostUnit")!
    
     enum CodingKeys:String,CodingKey {
        
        case uid
        case refCDC = "ref_cdc"
        case typeCode = "type_code"
        case imputationUnitCode = "imputation_code"
        case labelDiAggregazione = "label_aggregata"
        case labelDiCosto = "label_costo"
        case costPerUnit = "cost_x_unit"
        case finalValue = "costo_finale"
        
        case note
        
        
    }
    
    enum HOCodingCase {
        
        case automaticImputation
        case finalImputation
        
    }
    
    
    init(from decoder: any Decoder) throws {
        
        let decodingCase = decoder.userInfo[Self.codingInfo] as? HOCodingCase ?? .finalImputation
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try container.decode(String.self, forKey: .uid)
        self.aggregationLabel = try container.decode(String.self, forKey: .labelDiAggregazione)
        self.costLabel = try container.decode(String.self, forKey: .labelDiCosto)
        
        switch decodingCase {
        case .automaticImputation:
            try decodeAutomaticImputation(from: container)
        case .finalImputation:
            try decodeFinalImputation(from: container)
        }
        
    }
    
    private mutating func decodeFinalImputation(from container: KeyedDecodingContainer<HOCostUnit.CodingKeys>) throws { 
       
        self.refCDC = try container.decode(String.self, forKey: .refCDC)
        self.finalCost = try container.decode(Double.self, forKey: .finalValue)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
   
    }
    
    private mutating func decodeAutomaticImputation(from container: KeyedDecodingContainer<HOCostUnit.CodingKeys>) throws {
        
        self.cdcTypeCode = try container.decode(String.self, forKey: .typeCode)
        self.kpCDCImputationUnitCode = try container.decode(String.self, forKey: .imputationUnitCode)
        self.costPerUnit = try container.decode(Double.self, forKey: .finalValue)
       
    }
    
}

extension HOCostUnit:Encodable {
    
    func encode(to encoder: any Encoder) throws {
        
        let codingCase = encoder.userInfo[Self.codingInfo] as? HOCodingCase ?? .finalImputation
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.aggregationLabel, forKey: .labelDiAggregazione)
        try container.encode(self.costLabel, forKey: .labelDiCosto)
        
        switch codingCase {
        case .automaticImputation:
            try encodeForAutomaticImputation(into: &container)
        case .finalImputation:
            try encodeFinalImputation(into: &container)
            
        }
    }
    
   private func encodeForAutomaticImputation(into container: inout KeyedEncodingContainer<HOCostUnit.CodingKeys>) throws {

        // cdcTypeCode
        // kpCDCImputationCode
        // costo per unità
       try container.encode(self.cdcTypeCode, forKey:.typeCode)
       try container.encode(self.kpCDCImputationUnitCode, forKey: .imputationUnitCode)
       try container.encode(self.costPerUnit, forKey: .costPerUnit)
            
    }
    
    
    private func encodeFinalImputation(into container: inout KeyedEncodingContainer<HOCostUnit.CodingKeys>) throws {

        // refCDC
        // valore finale
        // note
        try container.encode(self.refCDC, forKey: .refCDC)
        try container.encode(self.finalCost, forKey: .finalValue)
        try container.encodeIfPresent(self.note, forKey: .note)
        
        
    }
    
}
