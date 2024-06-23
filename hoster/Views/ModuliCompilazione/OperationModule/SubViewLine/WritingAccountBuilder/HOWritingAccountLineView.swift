//
//  HOWritingAccountLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 01/06/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOWritingAccountLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @Binding var operation:HOOperationUnit
    
    @StateObject private var builderVM:HOWritingAccountBuilderVM
    
    init(operation: Binding<HOOperationUnit>, mainViewModel:HOViewModel) {
        
        _operation = operation
        let builder = HOWritingAccountBuilderVM(mainVM: mainViewModel,existingWriting: operation.wrappedValue.writing)
        _builderVM = StateObject(wrappedValue: builder)
    }
    
    var body: some View {
        
        VStack(alignment:.leading,spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Anagrafica",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "square.grid.3x1.folder.fill.badge.plus",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                        EmptyView()
            }
            
            VStack(alignment:.leading,spacing:5) {

                HOFilterPickerView(
                    property: $builderVM.operationArea,
                    nilImage: "pencil.tip.crop.circle",
                    nilPropertyLabel: "area",
                    allCases: builderVM.operationAreaAvaible)
                //.disabled(builderVM.lockEditing ?? false)
                .csLock(Color.gray, .trailing, .trailing, builderVM.lockEditing ?? false)

                if let operationTypeAvaible = builderVM.operationTypeAvaible {
                    
                    HOFilterPickerView(
                        property: $builderVM.operationType,
                        nilImage: "plus.slash.minus",
                        nilPropertyLabel: "operazione",
                        allCases: operationTypeAvaible)
                    .csLock(Color.gray, .trailing, .trailing, builderVM.lockEditing ?? false)
                    .id(builderVM.operationArea)
                    
                    
                }

                if let categoriesAccountAvaible = builderVM.categoriesAccountAvaible {

                    HOFilterPickerView(
                        property: $builderVM.categoryAccount,
                        nilImage: "list.bullet.clipboard",
                        nilPropertyLabel: "oggetto",
                        allCases: categoriesAccountAvaible)
                    .csLock(Color.gray, .trailing, .trailing, builderVM.lockEditing ?? false)
                    .id(builderVM.operationType) // nota 27.05.24

                    }

                if let subsCategories = builderVM.subCategoriesAccountAvaible {
                    
                    HOFilterPickerView(
                        property: $builderVM.subCategoryAccount,
                        nilImage: "list.bullet.indent",
                        nilPropertyLabel: "sub oggetto",
                        allCases: subsCategories)
                    .csLock(Color.gray, .trailing, .trailing, builderVM.lockEditing ?? false)
                    .id(builderVM.categoryAccount)
     
                }
                
                if let allOperationInfo = builderVM.writingObjectAvaible {
                    
                        HOFilterPickerView(
                            property: $builderVM.writingObject,
                            nilImage: "checklist.unchecked",
                            nilPropertyLabel: "da archivio",
                            allCases: allOperationInfo)
                        .csLock(Color.gray, .trailing, .trailing, builderVM.lockEditing ?? false)
                        .id(builderVM.categoryAccount)
                    
                        //.id(allOperationInfo)
                    
                }
                
                if let operationInfo = builderVM.writingObject,
                    operationInfo.specification == nil {
                    
                    // se esiste un operationInfo e la specification è nil, vuol dire che è stata scelta una nuova etichetta. Se esiste l'info e la specification vuol dire che la si è caricata da archivio.
                                
                    vbSpecification()
                        .id(operationInfo)
                        //.id(builderVM.subCategoryAccount)

                }
                    
                
                if let imputationAccountsAvaible = builderVM.imputationAccountsAvaible {
                             
                     HOFilterPickerView(
                         property: $builderVM.imputationAccount,
                         nilImage: "cursorarrow.click.2",
                         nilPropertyLabel: "per attività",
                         allCases: imputationAccountsAvaible)
                     .csLock(Color.gray, .trailing, .trailing, builderVM.lockEditing ?? false)
                     .id(builderVM.specification)
                     //.id(builderVM.writingObject)
                    // .id(builderVM.subCategoryAccount)
                     
                 }
                
            if let editingComplete = builderVM.editingComplete,
                       editingComplete {

                    HStack {
                        
                        Spacer()
                        
                        Button(action: {
                            
                            withAnimation {
                                self.goOnAction()
                            }
                            
                        }, label: {
                            Text("Valida")
                                .font(.headline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color.green)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        })
                    }
            }
                    
            } // chiusa vstack interno
            
           /* Text("area: \(builderVM.operationArea?.rawValue ?? "noValue")")
            Text("type: \(builderVM.operationType?.rawValue ?? "noValue")")
            Text("category: \(builderVM.categoryAccount?.rawValue ?? "noValue")")
            Text("Subcategory: \(builderVM.subCategoryAccount?.rawValue ?? "noValue")")
            Text("oggetto: \(builderVM.writingObject?.getDescription(campi: \.category,\.specification, partialAmountPath: \.quantityStringValue) ?? "noValue")")
            Text("imputazione: \(builderVM.imputationAccount?.rawValue ?? "novalue")") */
            
            if let writing = builderVM.existingWriting {
                
                let label = writing.getWritingDescription() ?? "none anagrafica"
                
                Text(label)
                    .italic()
                    .font(.caption)
                    .foregroundStyle(Color.malibu_p53)
                
            }
            
        } // chiusa vstack madre

    } // chiusa body

    @ViewBuilder private func vbSpecification() -> some View {
        
        let categoryString = builderVM.categoryAccount?.rawValue ?? "Oggetto"
        let sub = builderVM.subCategoryAccount?.rawValue ?? categoryString
    
        let specification = builderVM.specification
        let placeholder = specification ?? ("Etichetta \(sub)")
        
        let value:(image:String,imageColor:Color,descriptionSpecification:String) = {
            
            guard specification != nil else {
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
            .csLock(Color.gray, .trailing, .trailing, (builderVM.lockEditing ?? false), true)
        
        if builderVM.lockEditing == nil {
            
            HStack {
                
                if builderVM.specification == nil {
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.yellow)
                }
    
                Text(value.descriptionSpecification)
                    .italic()
                    .font(.caption2)
                    .foregroundStyle(Color.hoDefaultText)
                    .opacity(0.8)
                
            }
                
        }
    }
    
    private func specificationSubmit(new:String) {
        
        let newValue = new.replacingOccurrences(of: " ", with: "")
        
        guard newValue.count > 5 else {
            self.builderVM.specification = nil
            return }
        
        self.builderVM.specification = new
        
    }
    
    private func goOnAction() {
        
        self.builderVM.setWritingAccount()
        
        guard let writingAccount = self.builderVM.existingWriting else { 
            
            let alert = AlertModel(title: "Errore", message: "Scrittura non riuscita. Riprovare")
            viewModel.sendAlertMessage(alert: alert)
           
            return }
        
        self.operation.writing = writingAccount
        
    }
}
