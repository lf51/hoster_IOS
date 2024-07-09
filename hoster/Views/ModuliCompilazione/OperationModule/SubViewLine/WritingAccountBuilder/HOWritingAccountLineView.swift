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
    // vedi Nota init deInit 05.07.24 Vi è una inefficienza a mio modo di vedere da provare in futuro a risolvere
    @EnvironmentObject var viewModel:HOViewModel
    
    @Binding var operation:HOOperationUnit
   // let operation:HOOperationUnit
    
    @StateObject private var wrBuilderVM:HOWritingAccountBuilderVM
    
    let focusEqualValue:HOOperationUnit.FocusField?
    @FocusState.Binding var focusField:HOOperationUnit.FocusField?
    
   // let syncroAction:(_ :HOWritingAccount?) -> Void
    
    init(operation: Binding<HOOperationUnit>,
         mainViewModel:HOViewModel,
         focusEqualValue:HOOperationUnit.FocusField?,
         focusField:FocusState<HOOperationUnit.FocusField?>.Binding) {
        
        _operation = operation
        let builder = HOWritingAccountBuilderVM(mainVM: mainViewModel,existingWriting: operation.wrappedValue.writing)
        _wrBuilderVM = StateObject(wrappedValue: builder)
        
        self.focusEqualValue = focusEqualValue
        _focusField = focusField
       // self.syncroAction = syncroAction
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
                    property: $wrBuilderVM.operationArea,
                    nilImage: "pencil.tip.crop.circle",
                    nilPropertyLabel: "area",
                    allCases: wrBuilderVM.operationAreaAvaible)
                //.disabled(builderVM.lockEditing ?? false)
                .csLock(Color.gray, .trailing, .trailing, wrBuilderVM.lockEditing ?? false)

                if let operationTypeAvaible = wrBuilderVM.operationTypeAvaible {
                    
                    HOFilterPickerView(
                        property: $wrBuilderVM.operationType,
                        nilImage: "plus.slash.minus",
                        nilPropertyLabel: "operazione",
                        allCases: operationTypeAvaible)
                    .csLock(Color.gray, .trailing, .trailing, wrBuilderVM.lockEditing ?? false)
                    .id(wrBuilderVM.operationArea)
                    
                    
                }

                if let categoriesAccountAvaible = wrBuilderVM.categoriesAccountAvaible {

                    HOFilterPickerView(
                        property: $wrBuilderVM.categoryAccount,
                        nilImage: "list.bullet.clipboard",
                        nilPropertyLabel: "oggetto",
                        allCases: categoriesAccountAvaible)
                    .csLock(Color.gray, .trailing, .trailing, wrBuilderVM.lockEditing ?? false)
                    .id(wrBuilderVM.operationType) // nota 27.05.24

                    }

                if let subsCategories = wrBuilderVM.subCategoriesAccountAvaible {
                    
                    HOFilterPickerView(
                        property: $wrBuilderVM.subCategoryAccount,
                        nilImage: "list.bullet.indent",
                        nilPropertyLabel: "sub oggetto",
                        allCases: subsCategories)
                    .csLock(Color.gray, .trailing, .trailing, wrBuilderVM.lockEditing ?? false)
                    .id(wrBuilderVM.categoryAccount)
     
                }
                
                if let allOperationInfo = wrBuilderVM.writingObjectAvaible {
                    
                        HOFilterPickerView(
                            property: $wrBuilderVM.writingObject,
                            nilImage: "checklist.unchecked",
                            nilPropertyLabel: "da archivio",
                            allCases: allOperationInfo)
                        .csLock(Color.gray, .trailing, .trailing, wrBuilderVM.lockEditing ?? false)
                        .id(wrBuilderVM.categoryAccount)
                    
                        //.id(allOperationInfo)
                    
                }
                
                if let operationInfo = wrBuilderVM.writingObject,
                    operationInfo.specification == nil {
                    
                    // se esiste un operationInfo e la specification è nil, vuol dire che è stata scelta una nuova etichetta. Se esiste l'info e la specification vuol dire che la si è caricata da archivio.
                                
                    vbSpecification()
                        .id(operationInfo)
                        //.id(builderVM.subCategoryAccount)

                }
                    
                
                if let imputationAccountsAvaible = wrBuilderVM.imputationAccountsAvaible {
                             
                     HOFilterPickerView(
                         property: $wrBuilderVM.imputationAccount,
                         nilImage: "cursorarrow.click.2",
                         nilPropertyLabel: "per attività",
                         allCases: imputationAccountsAvaible)
                     .csLock(Color.gray, .trailing, .trailing, wrBuilderVM.lockEditing ?? false)
                     .id(wrBuilderVM.specification)
                     //.id(builderVM.writingObject)
                    // .id(builderVM.subCategoryAccount)
                     
                 }
                
            if let editingComplete = wrBuilderVM.editingComplete,
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
            
            if let writing = wrBuilderVM.existingWriting {
                
                let label = writing.getWritingDescription() ?? "none anagrafica"
                
                Text(label)
                    .italic()
                    .font(.caption)
                    .foregroundStyle(Color.malibu_p53)
                
            }
            
        } // chiusa vstack madre

    } // chiusa body

    @ViewBuilder private func vbSpecification() -> some View {
        
        let categoryString = wrBuilderVM.categoryAccount?.rawValue ?? "Oggetto"
        let sub = wrBuilderVM.subCategoryAccount?.rawValue ?? categoryString
    
        let specification = wrBuilderVM.specification
        let placeholder = specification ?? ("Etichetta \(sub)")
        
        let value:(image:String,imageColor:Color/*,descriptionSpecification:String*/) = {
            
            guard specification != nil else {
                return ("rectangle.and.pencil.and.ellipsis.rtl",Color.gray/*"Nessuna etichetta specifica - min 5 caratteri"*/ )
            }
            
            return ("list.bullet.indent",Color.seaTurtle_4/*"Etichetta inserita correttamente"*/)
            
        }()
        
        CSSyncTextField_4b(
             placeHolder: placeholder,
             focusValue:self.focusEqualValue,
             focusField:self.$focusField) {
                 
                 Image(systemName: value.image)
                     .bold()
                     .imageScale(.medium)
                     .foregroundStyle(value.imageColor)
                     .padding(.leading,5)
                 
             } disableLogic: { value in
                 self.disableLogic(check: value)
                 
             } keyboardMiddleContent: { value in
                 self.vbVisualValidation(value: value)
                 
             } syncroAction: { value in
                 self.specificationSubmit(new: value)
             }
             .csLock(Color.gray, .trailing, .trailing, (wrBuilderVM.lockEditing ?? false), true)
        
       /* if wrBuilderVM.lockEditing == nil {
            
            HStack {
                
                if wrBuilderVM.specification == nil {
                    
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
                
        }*/
    }
    
    @ViewBuilder private func vbVisualValidation(value:String) -> some View {
        
        let newValue = value.replacingOccurrences(of: " ", with: "")
        
        let image:(name:String,color:Color) = {
            let count = newValue.count
            if count < 5 { return ("x.circle",Color.gray)}
            else { return ("checkmark.circle",Color.green)}
        }()

            
        HStack {
            
            Text("min 3 lettere - max 7 parole")
                .font(.caption2)
                .italic()
            
            Image(systemName: image.name)
                    .imageScale(.medium)
                    .foregroundStyle(image.color)
        }
            
            
    }
    
    private func specificationSubmit(new:String) {
        
       /* let newValue = new.replacingOccurrences(of: " ", with: "")
        
        guard newValue.count > 5 else {
            self.wrBuilderVM.specification = nil
            return }*/
        
        let forbidden:CharacterSet = .punctuationCharacters.union(.whitespacesAndNewlines)
        
        let cleanString = csStringCleaner(value: new, byCharacter: forbidden)
        
        self.wrBuilderVM.specification = cleanString
        
    }
    
    private func disableLogic(check stringValue:String) -> Bool {
        
        let forbidden:CharacterSet = .punctuationCharacters.union(.whitespacesAndNewlines)
        
        let cleanString = csStringCleaner(value: stringValue, byCharacter: forbidden)
        
        guard cleanString.count > 3 else { return true }
        
        let wordCount = cleanString.components(separatedBy: " ").count
        
        return wordCount > 7

    }
    
    private func goOnAction() {
        
        self.wrBuilderVM.setWritingAccount()
        
        guard let writingAccount = self.wrBuilderVM.existingWriting else { 
            
            let alert = AlertModel(title: "Errore", message: "Scrittura non riuscita. Riprovare")
            viewModel.sendAlertMessage(alert: alert)
           
            return }
        
        self.operation.writing = writingAccount
       // self.syncroAction(writingAccount)
        
    }
}
