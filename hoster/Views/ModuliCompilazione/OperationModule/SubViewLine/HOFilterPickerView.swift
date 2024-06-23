//
//  HONewOperationMainModule.swift
//  hoster
//
//  Created by Calogero Friscia on 09/05/24.
//

import SwiftUI
import MyPackView
/*
/// Le operazioni saranno preCompilate, custodite in una collezione trasversale che manipoleremo o direttamente su firebase o da applicativo apposito.
struct HONewOperationMainModule: View {
    
    @EnvironmentObject var viewModel: HOViewModel
    
    @State private var operation: HOOperationUnit
    @State private var storedOperation: HOOperationUnit // per il reset
    
    @State private var generalErrorCheck: Bool = true
    @FocusState private var modelField:HOOperationUnit.FocusField?
    
    let destinationPath: HODestinationPath
    
    init(operation: HOOperationUnit, destinationPath: HODestinationPath) {
     
        self.operation = operation
        self.storedOperation = operation

        self.destinationPath = destinationPath
    }
    
    var body: some View {
        
        CSZStackVB(
            title: self.operation.writingLabel.capitalized,
            backgroundColorView: Color.hoBackGround) {
                
                VStack(alignment:.leading) {
                    
                    vbModelChoice()
                    
                    ScrollView {
                        
                        if showBody() {
                            
                            VStack(alignment:.leading,spacing:15) {
                                
                                // body compilazione
                                Text("Ciao")
                                
                            }
                            
                        }
                        
                    } // chiusa Scroll
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.immediately)

                } // chiusa VStack Madre
                .padding(.horizontal,10)
            } // chiusa zStack
            
        
    } // chiusa body
    

    
    private func showBody() -> Bool {
        
       // return self.operation.writing != nil
        return true
    }
    
    @ViewBuilder private func vbModelChoice() -> some View {
        
        if self.storedOperation.writing == nil {
            // trattasi di modifica operazione esistente
            HOWritingAccountLineView(operation: $operation)
        } else {
            // trattasi di operazione nuova
            Text("Divider o info sintetiche")
        }
        
    }
    
    // TEST
    func addNew() {
        /// TEST TEST TEST da verificare tutto il processo di pubblicazione
        let newOpt = HOOperationUnit()
    
        self.viewModel.publishData(from: newOpt, syncroDataPath: \.workSpaceOperations)
        
    }
    
}

#Preview {
    NavigationStack {
        
        HONewOperationMainModule(operation: HOOperationUnit(), destinationPath: .operations)
            .environmentObject(testViewModel)
            .tint(Color.hoAccent)
    }
}

import MyTextFieldSinkPack
struct HOWritingAccountLineView:View {
    
    @Binding var operation:HOOperationUnit
    
    @State private var localErrorCheck:Bool = false
    
    @StateObject private var builderVM:HOWritingAccountBuilderVM = HOWritingAccountBuilderVM()
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            if builderVM.editingExtended {
                
                vbWritingBuilderExtended()
                
            } else {
                
                vbWritingBuilderCompleted()
            }
                
            Text("BUILDER")
                .bold()
                .font(.title)
            Text(builderVM.operationArea?.rawValue ?? "no area value")
            Text(builderVM.operationType?.rawValue ?? "no type value")
           // Text("type avaible:\(builderVM.operationTypeAvaible?.count ?? 0)")
            
            Text(builderVM.categoryAccount?.rawValue ?? "no category value")
           // Text("category avaible:\(builderVM.categoriesAccountAvaible?.count ?? 0)")
            
            //Text(builderVM.subCategoryAccount?.rawValue ?? "no sub value")
           // Text("sub avaible:\(builderVM.subCategoriesAccountAvaible?.count ?? 0)")
            
            
            Text(builderVM.imputationAccount?.rawValue ?? "no imputation value")
           // Text("imputation avaible:\(builderVM.imputationAccountsAvaible?.count ?? 0)")

            
            Text("Operation Writing Account")
                .font(.largeTitle)
            
            Text("dare -> \(operation.writing?.dare ?? "no value")")
            Text("avere -> \(operation.writing?.avere ?? "no value")")
            
        } // chiusa vstack madre

    } // chiusa body

    @ViewBuilder private func vbWritingBuilderCompleted() -> some View {
        
        HStack {
            
            Text("builder Completed")
            
            Button(action: {
                builderVM.editingExtended.toggle()
            }, label: {
                Text("Extend")
            })
        }
        
    }
    
    @ViewBuilder private func vbWritingBuilderExtended() -> some View {
        
        HOFilterPickerView(
            property: $builderVM.operationArea,
            nilImage: "pencil.tip.crop.circle",
            nilPropertyLabel: "area",
            allCases: nil)
        
       
        if let operationTypeAvaible = builderVM.operationTypeAvaible {
            
            HOFilterPickerView(
                property: $builderVM.operationType,
                nilImage: "plus.slash.minus",
                nilPropertyLabel: "operazione",
                allCases: operationTypeAvaible)
            
        }
        
        if let categoriesAccountAvaible = builderVM.categoriesAccountAvaible {
            
            HOFilterPickerView(
                property: $builderVM.categoryAccount,
                nilImage: "list.bullet.clipboard",
                nilPropertyLabel: "oggetto",
                allCases: categoriesAccountAvaible)

        }
        
        if let subsCategories = builderVM.subCategoriesAccountAvaible {
            
            HOFilterPickerView(
                property: $builderVM.subCategoryAccount,
                nilImage: "list.bullet.indent",
                nilPropertyLabel: "sub oggetto",
                allCases: subsCategories)
            .csWarningModifier(
                warningColor: Color.hoWarning,
                overlayAlign: .topTrailing,
                isPresented: localErrorCheck) {
                    builderVM.subCategoryAccount == nil
                }

        }
        
        if let categoryAccount = builderVM.categoryAccount {
            
            vbSpecification(category: categoryAccount)
            
        }
    
    if let imputationAccountsAvaible = builderVM.imputationAccountsAvaible {
                
        HOFilterPickerView(
            property: $builderVM.imputationAccount,
            nilImage: "cursorarrow.click.2",
            nilPropertyLabel: "per attività",
            allCases: imputationAccountsAvaible)
        
    }
        
    if let editingComplete = builderVM.editingComplete,
               editingComplete {

            HStack {
                
                Button(action: {
                    self.resetAction()
                }, label: {
                    Text("Reset")
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.red)
                        .opacity(0.8)
                })
                
                Spacer()
                
                Button(action: {
                    
                    withAnimation {
                        self.goOnAction()
                    }
                    
                }, label: {
                    Text("Prosegui")
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.green)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                })
                
                
            }
            
            
        }
    }
    
    @ViewBuilder private func vbSpecification(category:HOCategoryAccount) -> some View {
        
        let categoryString = category.rawValue
        let sub = builderVM.subCategoryAccount?.rawValue ?? categoryString
    
        let specification = builderVM.specification
        let placeholder = specification ?? ("Etichetta \(sub)")
        
        let value:(image:String,imageColor:Color,descriptionSpecification:String) = {
            
            guard let specification else {
                return ("rectangle.and.pencil.and.ellipsis.rtl",Color.gray,"Nessuna etichetta specifica - min 5 caratteri" )
            }
            
            return ("list.bullet.indent",Color.seaTurtle_4,"Etichetta inserita correttamente")
            
        }()
        
        CSSyncTextField_4b(
            placeHolder: placeholder) {
                
                Image(systemName: value.image)
                    .bold()
                    .imageScale(.medium)
                    .foregroundStyle(value.imageColor)
                    .padding(.leading,5)
                
            } syncroAction: { value in
                self.specificationSubmit(new: value)
            }
        
        Text(value.descriptionSpecification)
            .italic()
            .font(.caption2)
            .foregroundStyle(Color.hoDefaultText)
            .opacity(0.8)
    }
    
    private func specificationSubmit(new:String) {
        
        let newValue = new.replacingOccurrences(of: " ", with: "")
        
        guard newValue.count > 5 else {
            
            return }
        
        self.builderVM.specification = new
        
    }
    
    private func resetAction() {
        
        withAnimation {
            self.builderVM.resetValue(propertyPath: \.operationArea)
        }
    }
    
    private func goOnAction() {
        
        guard let writingAccount = self.builderVM.getWritingAccountBack() else {
            self.localErrorCheck = true
            return
        }
        
        self.operation.writing = writingAccount
        
    }
}
import Combine
class HOWritingAccountBuilderVM:ObservableObject {
    
    @Published var operationArea:HOOperationArea?
    
    @Published var operationTypeAvaible:[HOOperationType]?
    @Published var operationType:HOOperationType?
    
    @Published var categoriesAccountAvaible:[HOCategoryAccount]?
    @Published var categoryAccount:HOCategoryAccount?
    
    @Published var subCategoriesAccountAvaible:[HOSubsCategoryAccount]?
    @Published var subCategoryAccount:HOSubsCategoryAccount?
    
    @Published var imputationAccountsAvaible:[HOImputationAccount]?
    @Published var imputationAccount:HOImputationAccount?
    
    @Published var specification:String?
    
    @Published var editingComplete:Bool?
    @Published var editingExtended:Bool = true
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
    
        self.addAreaSubscriber()
        self.addTypeSubscriber()
        self.addCategoryAccountSubscriber()
        self.addImputationAccountSubScriber()
        
    }
    
    func getWritingAccountBack() -> HOWritingAccount? {
        
        // quando questa funzione è chiamata può mancare solo la subCategories. In questo caso torniamo nil per mostrare il warning e scegliere un elemento
        guard checkAllPathCompleted() else { return nil }
        
        let writingInfo = HOAccWritingInfo(
            category: categoryAccount,
            subCategory: subCategoryAccount,
            specification: nil)
    
        let value = getDareAvere()
        
        let writingAccount = HOWritingAccount(
            dare: value.dare,
            avere: value.avere,
            type: operationType,
            info: writingInfo)
        
       // self.editingExtended = false
        
        return writingAccount
    }
    
    private func checkAllPathCompleted() -> Bool {
        
        guard operationArea != nil,
              operationType != nil,
              categoryAccount != nil,
              imputationAccount != nil else { return false }
        
        if subCategoriesAccountAvaible == nil { return true }
        else if subCategoryAccount != nil { return true }
        else { return false }
        
    }
    
    private func addImputationAccountSubScriber() {
        
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
    
    private func addCategoryAccountSubscriber() {
        
        $categoryAccount
            .sink { [weak self] categoryAcc in
                
                guard let self,
                      let categoryAcc else {
                    
                    self?.resetValue(propertyPath: \.subCategoryAccount, arrayPath: \.subCategoriesAccountAvaible)
                    
                    self?.specification = nil
                    
                    self?.resetValue(propertyPath: \.imputationAccount, arrayPath: \.imputationAccountsAvaible)
                    
                    return
                }
                
                self.resetValue(propertyPath: \.subCategoryAccount, arrayPath: \.subCategoriesAccountAvaible)
                self.specification = nil
                self.resetValue(propertyPath: \.imputationAccount, arrayPath: \.imputationAccountsAvaible)
                
                let subs = categoryAcc.getSubsCategories()
               // let imputationAssociated = categoryAcc.getImputationAccountAssociated()
                let imputationAssociated = self.getImputationAccountsAvaible(category: categoryAcc)
                
                self.imputationAccountsAvaible = imputationAssociated
                self.subCategoriesAccountAvaible = subs
            }.store(in: &cancellables)
    }
    
    private func addTypeSubscriber() {
        
        $operationType
            .sink { [weak self] type in
                
                guard let self,
                      let type else {
                    
                    self?.resetValue(propertyPath: \.categoryAccount, arrayPath: \.categoriesAccountAvaible)
                   
                    return }

                self.resetValue(propertyPath: \.categoryAccount,arrayPath: \.categoriesAccountAvaible)
                
                let categoriesAssociated = self.getCategoryAccountAvaibles(type: type)
                
                self.categoriesAccountAvaible = categoriesAssociated
                
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
                
                self.resetValue(propertyPath: \.operationType, arrayPath: \.operationTypeAvaible)
                
                let operationTypeAssociated = area.getOperationTypeAssociated()
                
                self.operationTypeAvaible = operationTypeAssociated
                
            }
            .store(in: &cancellables)
            
        
    }
    
    func resetValue<E:HOProWritingDownLoadFilter>(propertyPath: ReferenceWritableKeyPath<HOWritingAccountBuilderVM,E?>,arrayPath:ReferenceWritableKeyPath<HOWritingAccountBuilderVM,[E]?>? = nil) {
    
    self[keyPath: propertyPath] = nil
    
    if let arrayPath {
        self[keyPath: arrayPath] = nil
    }
}
    
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: Elabora le categorieAccount associate al Type escludendo quelle non associate al movimento
    private func getCategoryAccountAvaibles(type:HOOperationType) -> [HOCategoryAccount]? {
        
        guard let operationArea else { return nil }
        
        let categories = type.getCategoryAccountAssociated(throw: operationArea)
        
        return categories
    }
    
    private func getImputationAccountsAvaible(category:HOCategoryAccount) -> [HOImputationAccount]? {
        
        guard let operationType,
              let operationArea else { return nil }
        
        let imputationFromType = operationType.getImputationAccountsAssociated(throw: operationArea)
        
        let imputationFromcategory = category.getImputationAccountAssociated()
        
        let accounts = imputationFromType?.filter({imputationFromcategory.contains($0)})
        
        return accounts
        
    }
    
    private func getDareAvere() ->(dare:String?,avere:String?) {
        
        guard let operationArea,
              let operationType,
              let categoryAccount,
              let imputationAccount else { return (nil,nil) }
        
        let categoryCode = categoryAccount.getIDCode()
        let imputationCode = imputationAccount.getIDCode()
        let defaultAccountIDCode = operationArea.getDefaultAccountIDCode()
        
        var dare:String? // IDCode
        var avere:String? // IDCode
        
        switch operationArea {
        case .scorte:
            
            switch operationType {
            case .acquisto:
                dare = categoryCode
                avere = defaultAccountIDCode // coincide con l'imputation
       
            case .consumo:
                dare = defaultAccountIDCode
                avere = imputationCode
  
            case .vendita,.resoAttivo:
                dare = defaultAccountIDCode
                avere = categoryCode
         
            default:
                dare = nil
                avere = nil
            }
            
            
        case .corrente:
            dare = nil
            avere = nil
        case .tributi:
            dare = nil
            avere = nil
        case .pluriennale:
            dare = nil
            avere = nil
        }
        
        
        return (dare,avere)
        
    }
    
    
}
*/ // chiusa for test updtating al multiAccount 24.05.24
struct HOFilterPickerView<E:HOProWritingDownLoadFilter>:View {
   
    @Binding var property:E?
    let nilImage:String
    let nilPropertyLabel:String
    let allCases:[E]
    
    /// <#Description#>
    /// - Parameters:
    ///   - property: proprietà da modificare attraverso il picker
    ///   - nilImage: immagine da mostrare quando il valore è nil
    ///   - allCases: casi da iterare fra cui scegliere. Se nil verrà usato l'allcase dell'oggetto
    init(property: Binding<E?>, nilImage: String,nilPropertyLabel:String = "no filter", allCases: [E]? = nil) {
       
        _property = property
        self.nilImage = nilImage
        self.nilPropertyLabel = nilPropertyLabel
        self.allCases = allCases ?? E.allCases
    }
    
    var body: some View {
        
        HStack(spacing:0) {
                
                let value:(image:String,colorImage:Color) = {
                    
                    guard let property else {
                        return (nilImage,Color.gray)
                    }
                    
                    let img = property.getImageAssociated()
                    let imgColor = property.getColorAssociated()
                    
                    return (img,imgColor)
                }()
                
               Image(systemName: value.image)
                    .bold()
                    .imageScale(.medium)
                    .foregroundStyle(value.colorImage)
                 
                
            Picker(selection:$property) {
                    
                    
                if property == nil {
                    let label = "Seleziona \(nilPropertyLabel)"
                 
                    Text(label.capitalized)
                        .tag(nil as E?)
                }
                    
                    ForEach(allCases,id:\.self) { sign in
                        
                            Text(sign.getRowLabel().capitalized)
                                .tag(sign as E?)
                    }
                    
                } label: {
                    //
                }
                .csModifier(self.property != nil) { picker in
                    picker
                        .menuIndicator(.hidden)
                        .tint(Color.hoDefaultText)
                        .opacity(0.6)
                }
                .tint(Color.hoAccent)
                
            Spacer()
            
            }
            .padding(.leading,5)
            .background {
                    RoundedRectangle(cornerRadius: 5.0)
                    .foregroundStyle(Color.hoDefaultText)
                        .opacity(0.1)
                        .shadow(radius: 5)
                        
                }
            .onAppear {
                print("ON APPEAR PICKER for allCases:\(allCases.description)")
                if allCases.count == 1 {
                   property = allCases.first
                }
            }

    } // chiusa body
}





// Temporaneo carrello HOWritingAccount remoto x test. Impostare importazione dalla libreria
/*
let opt1:HOWritingAccount = {
    
    var opt = HOWritingAccount()
   
    let oggettoScrittura = HOCategoryAccount.merci.getIDCode()
    
    opt.dare = oggettoScrittura
    opt.avere = nil // scelto dall'utente
    
    opt.area = .corrente
    opt.type = .acquisto
    opt.info = HOAccWritingInfo(category: oggettoScrittura)
    
    return opt
}()

let opt2:HOWritingAccount = {
    
    var opt = HOWritingAccount()
   
    let oggettoScrittura = HOCategoryAccount.merci.getIDCode()
    let imputazione = HOImputationAccount.warehouse.getIDCode()
    
    opt.dare = oggettoScrittura
    opt.avere = imputazione
    
    opt.area = .scorte
    opt.type = .acquisto
    opt.info = HOAccWritingInfo(category: oggettoScrittura)
    
    return opt
}()

let opt3:HOWritingAccount = {
    
    var opt = HOWritingAccount()
   
    let oggettoScrittura = HOCategoryAccount.merci.getIDCode()
    let imputazione = HOImputationAccount.warehouse.getIDCode()
    
    opt.dare = imputazione
    opt.avere = nil // scelto dall'utente
    
    opt.area = .scorte
    opt.type = .consumo
    opt.info = HOAccWritingInfo(category: oggettoScrittura)
    
    return opt
}()
*/
