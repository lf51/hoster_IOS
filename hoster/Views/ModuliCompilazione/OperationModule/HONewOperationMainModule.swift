//
//  TEST.swift
//  hoster
//
//  Created by Calogero Friscia on 24/05/24.
//

import SwiftUI
import MyPackView

struct HONewOperationMainModule: View {
    
    @EnvironmentObject var viewModel: HOViewModel
    
    @StateObject var builderVM:HONewOperationBuilderVM
    
    @State private var generalErrorCheck: Bool = false
    @FocusState private var modelField:HOOperationUnit.FocusField?
    
    let destinationPath: HODestinationPath
    
    init(operation: HOOperationUnit, destinationPath: HODestinationPath) {
     
        let builder = HONewOperationBuilderVM(operation: operation)
        _builderVM = StateObject(wrappedValue: builder)
        
        self.destinationPath = destinationPath
    }
    
    var body: some View {
        
        let label = self.builderVM.operation.writingLabel.capitalized
        
        CSZStackVB(
            title: label,
            backgroundColorView: Color.hoBackGround) {
                
                VStack(alignment:.leading) {
                    
                 CSDivider()
                    
                    ScrollView {
                        
                        VStack(alignment:.leading,spacing:10) {
                            
                            HORegolamentoLineView(operation: $builderVM.operation)
                            
                            HOWritingAccountLineView(
                                operation: $builderVM.operation,
                               /* mainViewModel: viewModel,*/
                                focusEqualValue: .writing,
                                focusField: $modelField)
                            .focused($modelField,equals: .writing)
                            
                            if builderVM.operation.writing != nil {

                                HOAmountLineView(
                                        builderVM: builderVM,
                                        generalErrorCheck: generalErrorCheck,focusEqualValue: .amount,focusField: $modelField)
                                .focused($modelField, equals: .amount)
             
                                HOTimeImputationLineView(
                                        builderVM: builderVM,
                                        generalErrorCheck: generalErrorCheck)

                                HOGenericNoteLineView<HOOperationUnit>(oggetto: $builderVM.operation, focusEqualValue: .note, focusField:$modelField )
                                    .focused($modelField,equals: .note)
                                
                                CSBottomDialogView() {
                                    vbDescription()
                                } disableConditions: {
                                    disableCondition()
                                } preDialogCheck: {
                                   checkPreliminare()
                                } primaryDialogAction: {
                                    vbDialogButton()
                                }
                            } // chiusa 2° parte
                            
                            
                        } // chiusa vstack interno
                        
                    } // chiusa Scroll
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.interactively)
                } // chiusa VStack Madre
                .padding(.horizontal,10)
            } // chiusa zStack
            .onAppear {
                
                
            }
        
    } // chiusa body
    
    private func vbDescription() -> (Text,Text) {
        
        let short = self.shortDescription()
        let long = "\(self.builderVM.operation.writing?.getWritingDescription() ?? "") \(short)"
        return (Text(short).foregroundStyle(Color.malibu_p53),Text(long))
    }
    
    private func disableCondition() -> (Bool?,Bool,Bool?) {
        
       // let one = false //self.builderVM.isValidate
        return (nil,false,nil)
    }
    
    private func checkPreliminare() -> Bool {
        
        do {
            try self.builderVM.checkValidation()
            return true
            
        } catch let error {
            
            withAnimation {
                self.generalErrorCheck = true
                self.viewModel.sendSystemMessage(message: HOSystemMessage(vector: .log, title: "ATTENZIONE", body: .custom(error.localizedDescription)))
            }
            return false
        }
        
    }
    
    @ViewBuilder private func vbDialogButton() -> some View {
        
        csBuilderDialogButton {
            
            DialogButtonElement(
                label: .saveNew,
                role: nil) {
                    true
                } action: {
                    self.builderVM.publishOperation(mainVM: self.viewModel, refreshPath: nil)
                }

            DialogButtonElement(
                label: .saveEsc) {
                    true
                } action: {
                    self.builderVM.publishOperation(mainVM: self.viewModel, refreshPath: self.destinationPath)
                }
        }
        
    }
    
    private func shortDescription() -> String {
        
        guard let sharedTimeImputation = builderVM.sharedTimeImputation else {
    
            return "Questo tipo di operazione non viene imputata."}

        let importo = self.builderVM.sharedAmount?.imponibile
        
        let importoString = self.builderVM.sharedAmount?.imponibileStringValue

        let main = sharedTimeImputation.getImputationDescription(importo,asString: importoString)
        
        var additional:String?
        
        if let imputationAccount = self.builderVM.imputationAccountAssociated {

                additional = ", per conto \(imputationAccount.rawValue)."

        }
        
        return main + (additional ?? ".")
        
    }
    
}

#Preview {
    NavigationStack {
        
        let operation:HOOperationUnit = {
           
            var opt = HOOperationUnit()
        /* opt.writing = HOWritingAccount(
                type: .acquisto,
                dare: nil,
                avere: "AA04",
                oggetto: HOWritingObject(category: .veicoli, subCategory: .autovettura, specification: "Fiat 500 lounge 1.2"))*/
            return opt
        }()
        
        HONewOperationMainModule(operation: operation, destinationPath: .operations)
            .environmentObject(testViewModel)
            .tint(Color.hoAccent)
    }
}

