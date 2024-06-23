//
//  HONewOperationBuilderVM.swift
//  hoster
//
//  Created by Calogero Friscia on 18/06/24.
//

import Foundation
import SwiftUI

enum HOMonthImputation:String,CaseIterable {
    
    case singolo
    case bimestre
    case trimestre
    case quadrimestre
    case semestre
    
}

 final class HONewOperationBuilderVM:ObservableObject {
    
    @Published var operation: HOOperationUnit
    var storedOperation:HOOperationUnit
    
    @Published var monthImputation:HOMonthImputation? //7 da sviluppare/
    @Published var imputationAccount:HOImputationAccount? // per gli ammortamenti eventuali
    var imputationAccountAvaible:[HOImputationAccount]?
     
    init(operation: HOOperationUnit) {
        
        self.operation = operation
        self.storedOperation = operation
    }
    
}
/// logica per amount
extension HONewOperationBuilderVM {
    
    var lockPrice:Bool {
        guard let object = operation.writing,
              let area = object.operationArea,
              let type = object.type else  { return false }
        
        return area.isPMCLock(throw: type)
    }
    
    func initOperationAmount() {
        
        let partialAmountPrice = self.operation.writing?.oggetto?.partialAmount?.pricePerUnit
        
        self.operation.amount = HOOperationAmount(quantity: 1,pricePerUnit: partialAmountPrice)
    }
    
    func updateAmountValue(from integer:Int,upFrom bottom:Int = 0, to path:WritableKeyPath<HOOperationAmount,Double?>) {
    
        let convertedAsDouble = Double(integer)
    
       guard convertedAsDouble > Double(bottom) else {
           return
       }
       
        withAnimation {
            self.operation.amount?[keyPath: path] = convertedAsDouble
        }
       
   }
    
    func updateAmountValue(from stringValue:String,upFrom bottom:Int = 0, to path:WritableKeyPath<HOOperationAmount,Double?>) {
    
        let convertedAsDouble = Double(stringValue) ?? Double(Int(stringValue) ?? 0)
    
       guard convertedAsDouble > Double(bottom) else {
           return
       }
       
        withAnimation {
            self.operation.amount?[keyPath: path] = convertedAsDouble
        }
       
   }
    
    func getRangeQuantity() ->(range:ClosedRange<Int>,isLocked:Bool) {
        
        guard let writing = operation.writing,
              let object = writing.oggetto,
              let partialAmount = object.partialAmount,
              let quantity = partialAmount.quantity else {
            
            return (1...10000,false)
        }

        let valueInt = Int(quantity)
        
        return (1...valueInt,true)
        
    }
    
    
}

/// logica per gli ammortamenti eventuali
extension HONewOperationBuilderVM {
    
    private func setImputationAccountsAvaible(throw type:HOOperationType,for area:HOAreaAccount,and category:HOObjectCategory) {
        
        guard let imputationFromArea = type.getImputation(throw: area) else {
            self.imputationAccountAvaible = nil
            return
        }

        guard var imputationFromCategory = type.getImputation(throw: category) else {
            self.imputationAccountAvaible = imputationFromArea
            return
        }

        let subCategoryAccount = operation.writing?.oggetto?.getSubCategoryCase()
        
        if let imputationFromSub = type.getImputation(throw: subCategoryAccount){
            
            imputationFromCategory.removeAll(where: {!imputationFromSub.contains($0)})
            
        }
        
        let accounts = imputationFromArea.filter({imputationFromCategory.contains($0)})
        self.imputationAccountAvaible = accounts
        
    }
    
}
/// logica per il time imputation
extension HONewOperationBuilderVM {
    
    func updateTimeImputationValue(newValue:Int,upFrom bottom:Int = 0, to path:WritableKeyPath<HOTimeImputation,Int?>) {
       
       guard newValue > bottom else {
           return
       }
       
        self.operation.timeImputation?[keyPath: path] = newValue
       
   }
    /// call onAppear TimeImputationLineView
    func initTimeImputation() {
        
        guard var starterTimeImput = getTimeImputationRelated() else { return }
         
        let regolamentoComponents = Calendar.current.dateComponents([.year,.month], from: self.operation.regolamento)
         
         starterTimeImput.mese = regolamentoComponents.month
         starterTimeImput.anno = regolamentoComponents.year
         
        self.operation.timeImputation = starterTimeImput
        
     }
    
    private func getTimeImputationRelated() -> HOTimeImputation? {
        
        guard let writing = operation.writing,
              let area = writing.operationArea,
              let type = writing.type,
              let category = writing.oggetto?.getCategoryCase() else { return nil }
        
        switch area {
        case .scorte:
            
            switch type {
            case .acquisto,.resoAttivo:
                return nil
            case .consumo:
                return HOTimeImputation()
            default: return nil
            }
        
        case .corrente:
            return nil
        case .tributi:
            return nil
        case .pluriennale:
          // solo operazione di acquisto
            self.setImputationAccountsAvaible(throw: .ammortamento, for: area, and: category)
            let ammortamento = category.getAnniAmmortamento()
            return HOTimeImputation(ammortamento: ammortamento)
            
            
        }
        
    }
    
    
    /// Torna un range impostato sulla data odierna
     func getYearRangeForStepper() -> ClosedRange<Int> {
        
         let components = Calendar.current.dateComponents([.year], from: Date()) // sostanzialmente in questo modo si può caricare la contabilità degli ultimi tre anni. Vista in un altro modo, si hanno tre anni per caricare la contabilità.
        
        guard let currentYear = components.year else {
            
            return (2090...2099)
        }
        
        let bottom = currentYear - 3
        
        return (bottom...currentYear)
        
    }
    
}
