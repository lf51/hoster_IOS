//
//  HONewOperationBuilderVM.swift
//  hoster
//
//  Created by Calogero Friscia on 18/06/24.
//

import Foundation
import SwiftUI

 final class HONewOperationBuilderVM:ObservableObject {
    
    @Published var operation: HOOperationUnit
    var storedOperation: HOOperationUnit
    
    @Published var sharedAmount: HOOperationAmount?
    @Published var syncedPriceValue: String?
    @Published var amountCategory: HOAmountCategory = .piece
     
    @Published var sharedTimeImputation: HOTimeImputation?
    var periodsAssociated: [HOMonthImputation.HOMIPeriod]?
  
   // @Published var associatedOperation: HOOperationUnit?
    private var associatedWriting: HOWritingAccount?
    @Published var imputationAccountAssociated: HOImputationAccount? // per gli ammortamenti eventuali
    var imputationAccountAvaible: [HOImputationAccount]?
     
    init(operation: HOOperationUnit) {
        
        self.operation = operation
        self.storedOperation = operation
    }
    
}

/// computed
extension HONewOperationBuilderVM {
    
    var lockPrice:Bool {
        guard let object = operation.writing,
              let area = object.operationArea,
              let type = object.type else  { return false }
        
        return area.isPMCLock(throw: type)
    }
    
    var currentValueToCheck:String? {

        switch self.amountCategory {
        case .piece:
            if let value = self.sharedAmount?.pricePerUnit {
                return String(value)
            } else { return nil }
        
        case .pack:
            if let value = self.sharedAmount?.imponibile {
                return String(value)
            } else { return nil }
        }
    }
}

// logica salvataggio
extension HONewOperationBuilderVM {
    
    func publishOperation(mainVM:HOViewModel,refreshPath:HODestinationPath?) {
        
        let mainOPT = compileMainOperation()
        let associatedOPT = compileAssociatedOperation()
        
        mainVM.publishBatch(
            from: mainOPT,associatedOPT,
            syncroDataPath: \.workSpaceOperations,
            refreshVMPath: refreshPath)
        
    }
    
    private func compileMainOperation() -> HOOperationUnit {
        
        var localMainOPT = self.operation
        
        localMainOPT.amount = self.sharedAmount
        
        guard let _ = associatedWriting else {
            
            localMainOPT.timeImputation = self.sharedTimeImputation
            return localMainOPT
            
        }
        
        return localMainOPT
        
    }
    
    private func compileAssociatedOperation() -> HOOperationUnit? {
        
        guard  var localAssWriting = self.associatedWriting else { return nil }
        
        localAssWriting.avere = self.imputationAccountAssociated?.getIDCode()
        
        var associatedOPT = HOOperationUnit()
        
        associatedOPT.regolamento = self.operation.regolamento
        associatedOPT.timeImputation = self.sharedTimeImputation
        associatedOPT.writing = localAssWriting
        associatedOPT.amount = self.sharedAmount
        associatedOPT.note = self.operation.note
        
        return associatedOPT
    }
    
}

/// logica per amount
extension HONewOperationBuilderVM {
    
    func initOperationAmount() {
        
        let partialAmountPrice = self.operation.writing?.oggetto?.partialAmount?.pricePerUnit
        
        self.sharedAmount = HOOperationAmount(quantity: 1,pricePerUnit: partialAmountPrice)
    }
    
    func updateAmountValue(from integer:Int,upFrom bottom:Int = 0, to path:WritableKeyPath<HOOperationAmount,Double?>) {
    
        let convertedAsDouble = Double(integer)
    
       guard convertedAsDouble > Double(bottom) else {
           return
       }
       
        withAnimation {
           // self.operation.amount?[keyPath: path] = convertedAsDouble
            self.sharedAmount?[keyPath: path] = convertedAsDouble
        }
       
   }
    
    func updateAmountValue(from stringValue:String,upFrom bottom:Int = 0, to path:WritableKeyPath<HOOperationAmount,Double?>) {
    
        let convertedAsDouble = csConvertToDotDouble(from: stringValue) //Double(Int(stringValue) ?? 0)
    
       guard convertedAsDouble > Double(bottom) else {
           return
       }
       
        withAnimation {
          //  self.operation.amount?[keyPath: path] = convertedAsDouble
            
            self.sharedAmount?[keyPath: path] = convertedAsDouble
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
    
    /// crea la struttura dell'operazione associata e compila l'array dei relativi campi di imputazione
    private func setImputationAccountsAvaible() {
        
        guard let associatedWriting,
              let area = associatedWriting.operationArea,
              let type = associatedWriting.type,
              let category = associatedWriting.oggetto?.getCategoryCase() else { return }
        
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
        let accountOrdered = accounts.sorted(by: {
            ($0.getOrderIndex(),$0.rawValue) < ($1.getOrderIndex(),$1.rawValue)
        })
        self.imputationAccountAvaible = accountOrdered
        
    }
    
   /* private func setImputationAccountsAvaible(throw type:HOOperationType,for area:HOAreaAccount,and category:HOObjectCategory) {
        
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
        
    }*/ // bcackuo 03.07
    
}
/// logica per il time imputation
extension HONewOperationBuilderVM {
    
    func updateTimeImputationMonthValue(to newMonth:Int) {

        self.sharedTimeImputation?.monthImputation?.mmStart = newMonth
   }
    
    func updateTimeImputationYearValue(to newYear:Int) {
       
      //  let yearsImputation = self.sharedTimeImputation?.monthImputation?.getYYImputation(startYY: newYear)
        
       // self.sharedTimeImputation?.anno = yearsImputation
        self.sharedTimeImputation?.startYY = newYear
   }

    /// call onAppear TimeImputationLineView
    func initTimeImputation() {
        
        let initSharedTimeImputation = getTimeImputationRelated()
        
        guard initSharedTimeImputation.consenti else { return }
         
        let regolamentoComponents = Calendar.current.dateComponents([.year,.month], from: self.operation.regolamento)

        let advancing = initSharedTimeImputation.categoria?.getDefaultMonthAdvancedAssociated()
        
        let periodsAssociated = initSharedTimeImputation.categoria?.getPeriodsAssociated()
        
        let monthImputation = HOMonthImputation(startMM: regolamentoComponents.month, advancingMM: advancing)
        
       // let yearsImputation = monthImputation.getYYImputation(startYY: regolamentoComponents.year)
                
        self.periodsAssociated = periodsAssociated
        
        self.sharedTimeImputation = HOTimeImputation(startYY: regolamentoComponents.year, monthImputation: monthImputation)
        
     }
    
    private func getTimeImputationRelated() -> (consenti:Bool,categoria:HOObjectCategory?)  /*HOTimeImputation?*/{
        
        guard let writing = operation.writing,
              let area = writing.operationArea,
              let type = writing.type,
              let oggetto = writing.oggetto,
              let category = oggetto.getCategoryCase() else { return (false,nil) }
        
        switch area {
        case .scorte:
            
            switch type {
            case .acquisto,.resoAttivo:
                return (false,category)
            case .consumo:
                return (true,category) //HOTimeImputation()
            default: return (false,category)
            }
        
        case .corrente:
            
            switch type {
            case .resoPassivo:
                // dovremmo imputarla nello stesso time dell'operazione che viene rimborsata (quindi andrebbe su false. Ma richiede che si conosca quando l'operazione collegata è stata imputata)
                return (true,category)
            default: return (true,category)
            }
            
        case .tributi:
            return (true,category)
        case .pluriennale:
          // solo operazione di acquisto
            self.associatedWriting = HOWritingAccount(
                type: .ammortamento,
                dare: writing.avere,
                avere: nil,
                oggetto: oggetto)
            
            self.setImputationAccountsAvaible()
          //  self.setImputationAccountsAvaible(throw: .ammortamento, for: area, and: category)
            
            return (true,category)
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

/// logica validazione e salvataggio
extension HONewOperationBuilderVM {
    
     func checkValidation() throws /*-> Bool*/ {
        // la writing è già validata nel builder specifico
        guard let sharedAmount/*,
              let sharedTimeImputation*/ else {
            
            throw HOCustomError.erroreGenerico(problem: "Epic Fail", reason: "amount assente o corroto", solution: "uscire e rientrare")
             }
        
       guard currentValueToCheck == syncedPriceValue else {
           
           throw HOCustomError.erroreGenerico(problem: "non vi è coerenza fra prezzo, quantità e categoria di amount.", reason: "la tipologia di amount, la quantità e il prezzo sono stati modificati in ordine sparso.", solution: "premere pulsante di refresh.")
         }
         
        guard let _ = sharedAmount.quantity,
              let _ = sharedAmount.pricePerUnit else {
            
            throw HOCustomError.erroreGenerico(problem: "Amount", reason: "prezzo per quantià assente o non valido", solution: "inserire un valore valido")
            
        }
        
        try checkSharedTimeImputation()
        
        guard imputationAccountAvaible != nil else {
            return
        }
        
        guard imputationAccountAssociated != nil else {
             
            throw HOCustomError.erroreGenerico(problem: "Attività", reason: "conto d'imputazione assente", solution: "selezionare una attività dal menu a tendina")
         }

         return 
    }
    
    private func checkSharedTimeImputation() throws {
        
        guard let sharedTimeImputation else { return }
        
        guard let _ = sharedTimeImputation.startYY,
              let monthImputation = sharedTimeImputation.monthImputation,
              let _ = monthImputation.mmStart,
              let _ = monthImputation.mmAdvancing else {
            
            throw HOCustomError.erroreGenerico(problem: "Imputazione Temporale", reason: "imputazione corrotta", solution: "provare a modificare i dati")
        }
        
        return
        
    }
    
}
