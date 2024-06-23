//
//  HOWritingObject.swift
//  hoster
//
//  Created by Calogero Friscia on 01/06/24.
//
import SwiftUI

struct HOWritingObject:Equatable,Codable { // modificare in HoOperationInfo
    //private(set) var id:String
    
    private(set) var category:String? //HOObjectCategory
    private(set) var subCategory:String?//HOSubCategory // non mandatory
    
    private(set) var specification:String? //
    
    private(set) var partialAmount:HOOperationAmount? // va escluso nell'encodeble e decodable
    
    init(category: HOObjectCategory?, subCategory: HOObjectSubCategory?, specification: String? ) {
       // self.id = UUID().uuidString
        self.category = category?.rawValue
        self.subCategory = subCategory?.rawValue
        self.specification = specification
        self.partialAmount = nil
    }
    
    mutating func setPartialAmount(newValue:HOOperationAmount?) {
        
        self.partialAmount = newValue
        
    }
    
    func getSubCategoryCase() -> HOObjectSubCategory? {
        
        guard let subCategory else { return nil }
        return HOObjectSubCategory(rawValue: subCategory)
        
    }
    
    func getCategoryCase() -> HOObjectCategory? {
        
        guard let category else { return nil }
        
        return HOObjectCategory(rawValue: category)
        
    }
}

extension HOWritingObject {
    
    func getDescription(campi:KeyPath<HOWritingObject,String?>...,partialAmountPath:KeyPath<HOOperationAmount,String?>...) -> String {
        
        var values:[String] = []
        
        for e in campi {
            
            let value = self[keyPath: e]
            
            if let value { values.append(value) }
            else { continue }
            
        }
        
        guard let partialAmount else {
            return values.joined(separator: " / ")
        }
        
        for x in partialAmountPath {
            
            let stringValue = partialAmount[keyPath: x]
            if let stringValue { values.append(stringValue) }
            else { continue }
        }
        
        return values.joined(separator: " / ")

    }
    
}

extension HOWritingObject:HOProWritingDownLoadFilter {
    
    static var allCases: [HOWritingObject] { return [] }

    func getRowLabel() -> String {
        
        guard category != nil,
              specification != nil else {
            return "nuova etichetta" }
        
        if partialAmount != nil {
            
            return self.getDescription(campi: \.specification, partialAmountPath: \.quantityStringValue)
            
        } else {
            
            return self.getDescription(campi: \.specification)
        }
        
        
        
       /* if subCategory != nil,
           partialAmount != nil {
            
            return self.getDescription(campi: \.subCategory,\.specification, partialAmountPath: \.quantityStringValue)
        }
        
        else if subCategory != nil {
            
            return self.getDescription(campi: \.subCategory,\.specification)
            
        }
        else if partialAmount != nil {
            
            return self.getDescription(campi:\.specification, partialAmountPath: \.quantityStringValue)
        }
        else {
            return self.getDescription(campi: \.specification) }*/
        }

    
   /* func getRowLabel() -> String {
        
        guard let category,
              let specification else {
            return "nuova etichetta" }
        
        guard let subCategory else {
            return "[\(category)] - \(specification)" }
        
        return "[\(category)/\(subCategory)]-\(specification)"
        
        
    }*/
    
    func getImageAssociated() -> String {
        return "checklist"
    }
    
    func getColorAssociated() -> Color {
        
        return Color.seaTurtle_4
    }
    
    
}
