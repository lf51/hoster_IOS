//
//  HOWritingAccountBuilderVM.swift
//  hoster
//
//  Created by Calogero Friscia on 01/06/24.
//
import Foundation
import SwiftUI
import Combine
import MyPackView

final class HOWritingAccountBuilderVM:ObservableObject {
    // punto di partenza
    private var mainVM:HOViewModel?
    private(set) var existingWriting:HOWritingAccount?
    
    var operationAreaAvaible:[HOAreaAccount]?
    @Published var operationArea:HOAreaAccount?
    
    var operationTypeAvaible:[HOOperationType]?
    @Published var operationType:HOOperationType?

    var categoriesAccountAvaible:[HOObjectCategory]?
    @Published var categoryAccount:HOObjectCategory?
    
    var writingObjectAvaible:[HOWritingObject]?
    @Published var writingObject:HOWritingObject?
    
    var subCategoriesAccountAvaible:[HOObjectSubCategory]?
    @Published var subCategoryAccount:HOObjectSubCategory?
    
    @Published var specification:String?
    
    private var lockedImputationAccount:[HOImputationAccount:[HOWritingObject]]?
    var imputationAccountsAvaible:[HOImputationAccount]?
    @Published var imputationAccount:HOImputationAccount?
    
    @Published var editingComplete:Bool?
    @Published var lockEditing:Bool?
    var cancellables = Set<AnyCancellable>()
    
    init(mainVM:HOViewModel,existingWriting:HOWritingAccount?) {
        print("[INIT]_builderVM")
        
        self.mainVM = mainVM
        self.existingWriting = existingWriting
        compileBuilder()
    }
    
    deinit {
        cancellables.removeAll()
        print("[DE.INIT]_builderVM")
    }
    
    private func addAllSubScribers() {
        
        self.addAreaSubscriber()
        self.addTypeSubscriber()
        self.addCategoryAccountSubscriber()
        self.addSubCategorySubscriber()
        self.addOperationInfoSubscriber()
       
        self.addSpecificationSubscriber()
        self.addImputationAccountSubscriber()
        
        
    }
}

/// compiler and reset
extension HOWritingAccountBuilderVM {
    
    private func compileBuilder() {
        
        guard let existingWriting,
              let operationArea = existingWriting.operationArea,
              let type = existingWriting.type,
              let object = existingWriting.oggetto,
              let category = object.getCategoryCase() else {
            
            self.addAllSubScribers()
            return
        }
    
        self.lockEditing = true
        self.editingComplete = nil
        self.cancellables.removeAll()
        
       // self.operationArea = operationArea
        self.operationAreaAvaible = [operationArea]
        self.operationTypeAvaible = [type]
        self.categoriesAccountAvaible = [category]
        self.writingObjectAvaible = [object]
        
        if let sub = object.getSubCategoryCase() {
            
            self.subCategoriesAccountAvaible = [sub]
        }
    
        self.specification = object.specification
        
        if let imputationAccount = existingWriting.imputationAccount {
            self.imputationAccountsAvaible = [imputationAccount]
        }
    }
    
    func resetValue<E:HOProWritingDownLoadFilter>(propertyPath: ReferenceWritableKeyPath<HOWritingAccountBuilderVM,E?>,arrayPath:ReferenceWritableKeyPath<HOWritingAccountBuilderVM,[E]?>? = nil) {
    
        withAnimation {
            self[keyPath: propertyPath] = nil
            
            if let arrayPath {
                self[keyPath: arrayPath] = nil
            }
        }
}
}

/// metodi per il recupero delle WritingObject
extension HOWritingAccountBuilderVM {
    
    /*
     • Magazzino
        - Acquisto: Gli acquisti per il magazzino recuperano le etichette (gli oggetti della scrittura) da tutte le operazioni fatte in precedenza nell'area. Inoltre tornano la possibilità di una nuova etichetta
     
        - Consumo,ResoAttivo: Queste operazione devono essere limitate a quegli oggetti precedentemente acquistati e non totalmente consumati o resi. Dunque sono recuperate soltanto quelle etichette che hanno un amount parziale diverso da zero
     
     • Corrente
        - Acquisto: Recuperiamo tutte le etichette per l'area precedentemente create, e una nuova etichetta vuota, sia per le merci che per i servizi esterni. Per i servizi esterni tuttavia abbiamo un blocco sulle quantità. Ossia ritorneranno tutti quegli oggetti precedentemente creati che hanno un saldo diverso da zero e se scelti saranno imputati negli stessi account. Questo per scalare dagli stessi account di imputazione eventuali vendite precedentemente create. Se a saldo zero le etichette non appaiano e l'utente dovrà ricrearle.
        - Vendita:
            - Merci: Possiamo immaginare che l'utente venda merci preventivamente caricate in magazzino,ancora da pagare. Quindi l'operazione di vendita merci può richiedere che vi siano dei prodotti caricati come costo negli account di vendita relativi (boutique, minibar) dal magazzino (attraverso il consumo) o dall'area corrente attraverso l'acquisto. Dunque recuperiamo solo quegli oggetti che hanno saldo diverso da zero
            - Servizi:
                _interni: I servizi interni possono essere venduti senza blocchi su acquisti precedenti
                _esterni: I servizi esterni immaginiamo che vengano venduti prima di essere acquistati o viceverse. Come per gli aquisti, in questo caso torneranno tutte le etichette diverse da zero con blocco delle imputazioni per assicurarci che quella vendita sia scalata da un acquisto sullo stesso account di imputazione.
        - Pagamento
        - ResoPassivo
        - Regalie
     
     
     */
    
    private func getWritingObjects(
        by forceCategory:HOObjectCategory? = nil,
        and forceSub:HOObjectSubCategory? = nil,
        lockedImputation:@escaping(_ lockedImputAccount:[HOImputationAccount:[HOWritingObject]]?) -> () ) -> [HOWritingObject]? {
        
        let category = forceCategory ?? self.categoryAccount
        
        guard let mainVM,
              let operationArea,
              let operationType,
              let category else { 
            
            lockedImputation(nil)
            return nil }
        
        let subCategory = forceSub ?? self.subCategoryAccount // è messa dopo perchè deve restare optional in quanto le sub non sempre ci sono
        
        switch operationArea {
        case .scorte:
            
                switch operationType {
                case .acquisto:
                    lockedImputation(nil)
                    return self.getWritingObjectAll(in: operationArea, by: category, and: subCategory, throw: mainVM)
              
                case .consumo,.resoAttivo:
                    lockedImputation(nil)
                    return self.getWritingObjectInCarico(in: operationArea, by: category, and: subCategory, throw: mainVM)
             
                default: return nil
       
                }
          
        case .corrente:

          // let emptyOne = HOWritingObject(category: category, subCategory: subCategory, specification: nil)
            
            switch operationType {
                
            case .acquisto:
                
               /* if category == .merci {
                    
                    lockedImputation(nil)
                    return self.getWritingObjectAll(in: operationArea, by: category, and: subCategory, throw: mainVM)
                }*/
                if category == .servizi {
                    
                    // sono solo esterni quindi non specifichiamo
                    let allObjects = getWritingObjectInCarico(category: category, and: subCategory,throw: mainVM, addEmptyLabel:true) { lockedImputAccount in
                        lockedImputation(lockedImputAccount)
                    }
                    
                   // return [emptyOne] + (allObjects ?? [])
                    return allObjects
                    
                } else {
                    lockedImputation(nil)
                    return self.getWritingObjectAll(in: operationArea, by: category, and: subCategory, throw: mainVM)
                }
                
            case .pagamento,.regalie:
                
                lockedImputation(nil)
                return self.getWritingObjectAll(in: operationArea, by: category, and: subCategory, throw: mainVM)
                
            case .resoPassivo: 
                
                let allObjects = getWritingObjectInCarico(category: category, and: subCategory, throw: mainVM) { lockedImputAccount in
                    lockedImputation(lockedImputAccount)
                }
                
                return allObjects
                
            case .vendita:
                
                if category == .merci {
                    
                    let allObjects = getWritingObjectInCarico(category: category, and: subCategory, throw: mainVM) { lockedImputAccount in
                        lockedImputation(lockedImputAccount)
                    }
                    
                    return allObjects

                }  else if category == .servizi,
                           subCategory == .esterno {
                       
                    let allObjects = getWritingObjectInCarico(category: category, and: subCategory, throw: mainVM,addEmptyLabel: true) { lockedImputAccount in
                        lockedImputation(lockedImputAccount)
                    }
                    
                   // return [emptyOne] + (allObjects ?? [])
                    return allObjects
                    
                   } else if category == .servizi,
                          subCategory == .interno {
                    
                    lockedImputation(nil)
                    return self.getWritingObjectAll(in: operationArea, by: category, and: subCategory, throw: mainVM)
                   
                } else {
                    lockedImputation(nil)
                    return nil  // mai eseguito
                }
                
            default: return nil
            }
            
        case .tributi,.pluriennale:
            
            lockedImputation(nil)
            return self.getWritingObjectAll(in: operationArea, by: category, and: subCategory, throw: mainVM)
            
        }

    }
    
    /// Recupera gli account di imputazione Avaible. Per ognuno di questi recupera tutti gli oggetti filtrandoli per categoria, sub e saldo diverso da zero. Ritorna tutti gli oggetti restanti, e attraverso un closure torna un dizionario dove associa ad ogni account di imputazione esaminato un array di oggetti collegati. Serve in caso di scelta di oggetto preesistente a imputare automaticamente all'account di imputazione associato. Elimina i duplicati e di default Non torna etichette vuote.
    private func getWritingObjectInCarico(category:HOObjectCategory,and sub:HOObjectSubCategory?,throw vm:HOViewModel,addEmptyLabel:Bool = false,lockedImputation:@escaping(_ lockedImputAccount:[HOImputationAccount:[HOWritingObject]]?) -> ()) -> [HOWritingObject]? {
        
        guard let ws = vm.db.currentWorkSpace else {
            
            let alert = AlertModel(title: "Errore", message: "WorkSpace assente o corrotto. Provare a riavviare ")
            vm.sendAlertMessage(alert: alert)
            lockedImputation(nil)
            return nil //nil
            
        }
        
        guard let imputationAccounts = self.getImputationAccountsAvaible(category: category) else {
            
            lockedImputation(nil)
            return nil
        }
       
        var locked:[HOImputationAccount:[HOWritingObject]] = [:]
        var allObjects:[HOWritingObject] = []
        
        for eachAccount in imputationAccounts {
            
            let nastrino = ws.wsOperations.getNastrinoAccount(for: eachAccount)
            
            guard let objects = nastrino.getObjectWithPartialAmount else { continue }
            
            let filteredByCategory = objects.filter({ $0.category == category.rawValue })
            let subFilter = filteredByCategory.filter({$0.subCategory == sub?.rawValue})
            
            let noZeroObject = subFilter.filter({
                
                if let amount = $0.partialAmount,
                   let q = amount.quantity {
                    return q != 0
                } else { return false }
                    })
            
            guard !noZeroObject.isEmpty else { continue }
            
            locked.updateValue(noZeroObject, forKey: eachAccount)
            allObjects.append(contentsOf: noZeroObject)
            
        }
        
        if addEmptyLabel {
            let emptyOne = HOWritingObject(category: category, subCategory: sub, specification: nil)
            allObjects.insert(emptyOne, at: 0)
        }
        
        guard !locked.isEmpty ||
              !allObjects.isEmpty else {
            
            let type = self.operationType?.getGergalDescription() ?? ""
            let message = "In conto \(self.operationArea?.rawValue ?? "[error]") non vi è \(category.rawValue) (\(sub?.rawValue ?? "")) \(type) "
            
            vm.sendSystemMessage(
                message: HOSystemMessage(vector: .log, title: "Errore", body: .custom(message)))
            
            lockedImputation(nil)
            return nil
        }
        
        let cleanDuplicate = Set(allObjects) // rimuove tutte le etichette che oltre ad avere le stringhe uguali hanno anche l'amount uguale. Poi a valle però per l'unica che appare sarà possibile scegliere fra più account di imputazione
        
        lockedImputation(locked)
        
        return Array(cleanDuplicate)
       
    }
    
    /// Analizza l'area, e ritorna tutte le etichette che hanno saldo diverso da zero ( ). Elimina i duplicati e Non torna etichette vuote.
    private func getWritingObjectInCarico(in area:HOAreaAccount,by category:HOObjectCategory,and sub:HOObjectSubCategory?,throw vm:HOViewModel) -> [HOWritingObject]? {
        
        guard let ws = vm.db.currentWorkSpace else {
            
            let alert = AlertModel(title: "Errore", message: "WorkSpace assente o corrotto. Provare a riavviare ")
            vm.sendAlertMessage(alert: alert)
            
            return nil
            
        }
        
        let account = ws.wsOperations.getNastrinoAccount(for: area)
        
        guard let objects = account.getObjectWithPartialAmount else {
            
            let type = self.operationType?.getGergalDescription() ?? ""
            let message = "In conto \(area.rawValue) non vi è \(category.rawValue) (\(sub?.rawValue ?? "")) \(type) "
            
            vm.sendSystemMessage(
                message: HOSystemMessage(vector: .log, title: "Errore [allObjects]", body: .custom(message)))
            
            return nil }
        
        let filtered = objects.filter({
            $0.category == category.rawValue &&
            $0.subCategory == sub?.rawValue })
       // let subFilter = filteredByCategory.filter({$0.subCategory == sub?.rawValue})
        
        let noZeroObject = filtered.filter({
            
            if let amount = $0.partialAmount,
               let q = amount.quantity {
                return q != 0
            } else { return false }
                })
    
        guard !noZeroObject.isEmpty else {
            
            let type = self.operationType?.getGergalDescription() ?? ""
            let message = "In conto \(area.rawValue) non vi è \(category.rawValue) (\(sub?.rawValue ?? "")) \(type) "
            
            vm.sendSystemMessage(
                message: HOSystemMessage(vector: .log, title: "Errore [noZeroObjects]", body: .custom(message)))
            
            return nil
            
        }
        
        return noZeroObject
    } // IN USO: MAGAZZINO
    
    /// Recupera le etichette tutte, relative ad un area. Utile per quelle aree come il magazzino sempre coinvolte nelle operazioni che la riguardano
    private func getWritingObjectAll(in area:HOAreaAccount,by category:HOObjectCategory,and sub:HOObjectSubCategory?,throw vm:HOViewModel) -> [HOWritingObject]? {
        
        guard let ws = vm.db.currentWorkSpace else {
            
            let alert = AlertModel(title: "Errore", message: "WorkSpace assente o corrotto. Provare a riavviare ")
            vm.sendAlertMessage(alert: alert)
            
            return nil
            
        }
        
        let newOne = HOWritingObject(
            category: category,
            subCategory: sub,
            specification: nil)
        
        let account = ws.wsOperations.getNastrinoAccount(for: area)
    
        guard let all = account.allObjectInNoPartialAmount else { return [newOne] }
       
        let categoryFilter = category.rawValue
        
        //let filtered = all.filter({ $0.category == categoryFilter })
        let filtered = all.filter({ 
            $0.category == categoryFilter &&
            $0.subCategory == sub?.rawValue
           
        })
        
        return [newOne] + filtered
        
        /*let subFilter = filtered.filter({$0.subCategory == sub?.rawValue})
        print("category is: \(categoryFilter)\nsubCategory is:\(sub?.rawValue ?? "no rawValue")")
        return [newOne] + subFilter*/

        
    } // IN USO: Magazzino, c/c current
    
    
}

/// builder method AccountWriting
extension HOWritingAccountBuilderVM {
    
  func setWritingAccount() {
    
    guard let operationArea,
          let operationType,
          let categoryAccount,
          let writingObject,
          let specification else { return }
    
      let info:HOWritingObject = {
          
          var obj = HOWritingObject(
            category: categoryAccount,
            subCategory: subCategoryAccount,
            specification: specification)
          
          let wrtPartialAmount = writingObject.partialAmount
          
          obj.setPartialAmount(newValue: wrtPartialAmount)
          return obj
          
      }()
        
    var writing:HOWritingAccount?
      
    switch operationArea {
        
    case .scorte:
        
        switch operationType {
        case .acquisto:
            
            writing = HOWritingAccount(
                type: operationType,
                dare: nil,
                avere: operationArea.getIDCode(),
                oggetto: info)

        case .consumo:
            
            writing = HOWritingAccount(
                type: operationType,
                dare: operationArea.getIDCode(),
                avere: imputationAccount?.getIDCode(),
                oggetto: info)

        case .resoAttivo:
            
            writing = HOWritingAccount(
                type: operationType,
                dare: operationArea.getIDCode(),
                avere: nil,
                oggetto: info)

        default: return
        }
        
    case .corrente:
        
        switch operationType {
        case .acquisto,.resoPassivo,.pagamento:
            
             writing = HOWritingAccount(
                type: operationType,
                dare: operationArea.getIDCode(),
                avere: imputationAccount?.getIDCode(),
                oggetto: info)
            
        case .vendita,.regalie:
            
             writing = HOWritingAccount(
                type: operationType,
                dare: imputationAccount?.getIDCode(),
                avere: operationArea.getIDCode(),
                oggetto: info)
 
        default: return
        }
        
    case .tributi:
        
        writing = HOWritingAccount(
            type: operationType,
            dare: operationArea.getIDCode(),
            avere: imputationAccount?.getIDCode(),
            oggetto: info)
        
    case .pluriennale:
        
        writing = HOWritingAccount(
            type: operationType,
            dare: nil,
            avere: operationArea.getIDCode(),
            oggetto: info)
        
    }
    
      self.existingWriting = writing
      self.compileBuilder()

  }
}

/// metodi compilatori interni
extension HOWritingAccountBuilderVM {
    
    private func setImputationAccounts() -> [HOImputationAccount]? {
        
        guard let writingObject else { return nil }
        
        guard let imputationAssociated = self.getImputationAccountsAvaible() else {
            
            self.editingComplete = true
            return nil
        }

        guard let lockedImputationAccount else {

            return imputationAssociated
        }
        
        var imputations:[HOImputationAccount] = []
        
        for (key,values) in lockedImputationAccount {
            
            if values.contains(writingObject) {
                imputations.append(key)
            } else { continue }
            
        }
        
        if imputations.isEmpty {
            return imputationAssociated
        } else {
            return imputations
        }

    }
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: Elabora le categorieAccount associate all'AREA throw ill Type
    private func getCategoryAccountAvaibles(type:HOOperationType) -> [HOObjectCategory]? {
        
        guard let operationArea else { return nil }

       // let categories = operationArea.getOperationCategoryAssociated(throw: type)
        let categories = operationArea.getSubRelatedObject(throw: type)
        return categories
    }
    
    private func getImputationAccountsAvaible(category:HOObjectCategory? = nil) -> [HOImputationAccount]? {
        
        let categoryAccount = category ?? self.categoryAccount
        
        guard let operationType,
              let operationArea,
              let categoryAccount else { return nil }
        
        guard let imputationFromArea = operationType.getImputation(throw: operationArea) else { return nil }
        
        guard var imputationFromCategory = operationType.getImputation(throw: categoryAccount) else { return imputationFromArea }
        
        if let imputationFromSub = operationType.getImputation(throw: self.subCategoryAccount) {
            
            imputationFromCategory.removeAll(where: {!imputationFromSub.contains($0)})
        }
        
        let accounts = imputationFromArea.filter({imputationFromCategory.contains($0)})
        let accountOrdered = accounts.sorted(by: {
            ($0.getOrderIndex(),$0.rawValue) < ($1.getOrderIndex(),$1.rawValue)
        })
        
        return accountOrdered
    }
}

/// SubScriber
extension HOWritingAccountBuilderVM {
    
    private func addImputationAccountSubscriber() {
        
        $imputationAccount
            .sink { [weak self] imputation in
                
                guard let self,
                      imputation != nil else {
                    
                    self?.editingComplete = nil
                    
                    return
                }
                
                self.editingComplete = true
                
            }.store(in: &cancellables)
        
    }
    
    private func addSpecificationSubscriber() {
        
        $specification
            .debounce(for: 0.25, scheduler: RunLoop.current) // necessario quanto carica un etichetta dal subscriber del writingObject. Poicheè fa partire la compilazione senza aver ancora aggiornato il valore del writing
            .sink { [weak self] specific in
                
                guard let self,
                      specific != nil else {
                    
                    self?.resetValue(propertyPath: \.imputationAccount,arrayPath: \.imputationAccountsAvaible)
                    self?.editingComplete = nil
                    
                    return }
                
                self.resetValue(propertyPath: \.imputationAccount)
                
                withAnimation {
                    self.imputationAccountsAvaible = self.setImputationAccounts()
                }
                
            }.store(in: &cancellables)
        
    }
    
    private func addOperationInfoSubscriber() {
        
        $writingObject
            .sink { [weak self] info in
            
                guard let self,
                       let info else {
                    
                    self?.specification = nil
                    
                    return }
                
                if let etichetta = info.specification {
                    
                    // trattasi di etichetta caricata da archivio
                    self.specification = etichetta
                    
                } else {
                    //trattasi di nuova etichetta
                    self.specification = nil
                }
                
            }.store(in: &cancellables)
        
    }
    
    private func addSubCategorySubscriber() {
     
        $subCategoryAccount
            .sink { [weak self] sub in
                
                guard let self,
                      let sub else {
                    
                     self?.resetValue(propertyPath: \.writingObject, arrayPath: \.writingObjectAvaible)
                    return
                }
                
                self.resetValue(propertyPath: \.writingObject)
                
                let objects = self.getWritingObjects(and: sub) { lockedImputation in
                
                    self.lockedImputationAccount = lockedImputation
                    
                }
                
                withAnimation {
                    self.writingObjectAvaible = objects
                }
                
                
            }.store(in: &cancellables)
        
    }
    
    private func addCategoryAccountSubscriber() {
        
        $categoryAccount
            .sink { [weak self] categoryAcc in
                
                guard let self,
                      let categoryAcc else {
                    
                    self?.resetValue(propertyPath: \.subCategoryAccount, arrayPath: \.subCategoriesAccountAvaible)
                    return
                }
            
                if let subs = categoryAcc.getSubRelatedObject(throw: self.operationType) {
                    
                    self.resetValue(propertyPath: \.subCategoryAccount)
                    self.subCategoriesAccountAvaible = subs
                    
                } else {
                    
                    self.resetValue(propertyPath: \.subCategoryAccount, arrayPath: \.subCategoriesAccountAvaible)
                    
                    let objects = self.getWritingObjects(by: categoryAcc) { lockedImputation in
                    
                        self.lockedImputationAccount = lockedImputation
                        
                    }
                    
                    withAnimation {
                        self.writingObjectAvaible = objects
                    }
                    
                }

            }.store(in: &cancellables)
    }
    
    private func addTypeSubscriber() {
        
        $operationType
            .sink { [weak self] type in
                
                guard let self,
                      let type else {
                    
                    self?.resetValue(propertyPath: \.categoryAccount, arrayPath: \.categoriesAccountAvaible)
                   
                    return }

                self.resetValue(propertyPath: \.categoryAccount)
                
                let categoriesAssociated = self.getCategoryAccountAvaibles(type: type)
                
                withAnimation {
                    self.categoriesAccountAvaible = categoriesAssociated
                }
                
            }.store(in: &cancellables)
        
    }
    
    private func addAreaSubscriber() {

        $operationArea
            .sink { [weak self] area in
                
                guard let area,
                      let self else {
   
                    self?.resetValue(propertyPath: \.operationType, arrayPath: \.operationTypeAvaible)
                    return
                }

                self.resetValue(propertyPath: \.operationType)
                
                let operationTypeAssociated = area.getOperationTypeAssociated()
                
                withAnimation {
                    self.operationTypeAvaible = operationTypeAssociated
                }
         
            }
            .store(in: &cancellables)
            
        
    }
}

