//
//  HONewReservation.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView

struct HONewReservationMainModule: View {
    
    @EnvironmentObject var viewModel: HOViewModel
    
    @StateObject var builderVM:HONewReservationBuilderVM
    
    @State private var generalErrorCheck: Bool = true
    @FocusState private var modelField:HOReservation.FocusField?

    let destinationPath: HODestinationPath
    
    init(reservation: HOReservation, destinationPath: HODestinationPath) {
     
        let builder = HONewReservationBuilderVM(reservation:reservation)
        _builderVM = StateObject(wrappedValue: builder)
        
        self.destinationPath = destinationPath

    }
    
    var body: some View {
        
        CSZStackVB(
            title: self.builderVM.reservation.labelModCompile,
            backgroundColorView: Color.hoBackGround) {
            
                VStack {
                    
                   // vbUnitLine()
                    HOUnitLineView(
                        builderVM: builderVM,
                        generalErrorCheck: generalErrorCheck)
                        /*.csWarningModifier(
                            warningColor: Color.hoWarning,
                            overlayAlign: .topTrailing,
                            isPresented: generalErrorCheck) {
                              
                             builderVM.checkUnitValidation()
                        }*/
                      
                    ScrollView {
                        
                        VStack(alignment:.leading,spacing:15) {
                            
                            HOGuestLineView(
                                builderVM:builderVM,
                                generalErrorCheck: generalErrorCheck,
                                focusEqualValue: .guest,
                                focusField: $modelField)
                            .focused($modelField, equals: .guest)
                            
                            HOCheckInLineView(
                                builderVM: builderVM,
                                generalErrorCheck: generalErrorCheck)
                            
                            HOBedDispoLineView(
                                builderVM: builderVM,
                                generalErrorCheck: generalErrorCheck)
                            
                            // amount
                            
                            // tassa di soggiorno
                            // commissionu
                            // costi transazione
                            
                            
                            
                            
                            HOGenericNoteLineView<HOReservation>(
                                oggetto: $builderVM.reservation,
                                focusEqualValue: .note,
                                focusField: $modelField)
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
                            
                        }
                    }
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.immediately)
                    
                }
                .padding(.horizontal,10)
                
            }/*.onAppear(perform: {
                builderVM.addUnitOnAppear(vm: viewModel)
            })*/
        
    } // close body
    
    private func vbDescription() -> (Text,Text) {
        
        let long = self.builderVM.longDescription()
        
        let short = self.builderVM.shortDescription()
        
        return (Text("\(short)"),Text("\(long)"))
    }
    
    private func disableCondition() -> (Bool?,Bool,Bool?) {
        
       // let one = false //self.builderVM.isValidate
        return (nil,false,nil)
    }
    
    private func checkPreliminare() -> Bool {
        
        do {
            try self.builderVM.checkValidation { value in
                self.generalErrorCheck = value
            }
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
                   // self.builderVM.publishOperation(mainVM: self.viewModel, refreshPath: nil)
                }

            DialogButtonElement(
                label: .saveEsc) {
                    true
                } action: {
                    self.builderVM.publishOperation(mainVM: self.viewModel, refreshPath: self.destinationPath)
                }
        }
        
    }
 
}

#Preview {
    
    NavigationStack {
        HONewReservationMainModule(
            reservation: HOReservation(),
            destinationPath: .reservations)
            .environmentObject(testViewModel)
    }

}



