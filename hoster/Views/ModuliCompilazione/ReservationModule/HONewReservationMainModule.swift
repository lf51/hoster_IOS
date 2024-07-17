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

                    HOUnitLineView(
                        builderVM: builderVM,
                        generalErrorCheck: generalErrorCheck)
                      
                    ScrollView {
                        
                        VStack(alignment:.leading,spacing:15) {
                            
                            HOGuestLineView(
                                builderVM:builderVM,
                                generalErrorCheck: self.generalErrorCheck,
                                focusEqualValue: .guest,
                                focusField: $modelField)
                            .focused($modelField, equals: .guest)
                            
                            HOCheckInLineView(
                                builderVM: builderVM,
                                generalErrorCheck: self.generalErrorCheck)
                            
                            HOBedDispoLineView(
                                builderVM: builderVM,
                                generalErrorCheck: self.generalErrorCheck)
                            
                            // tassa di soggiorno
                            
                            HOCityTaxLineView(
                                builderVM: builderVM,
                                focusEqualValue: .cityTax,
                                focusField: $modelField)
                                .focused($modelField,equals: .cityTax)
                            
                            // amount
                            
                            HOReservationAmountLineView(
                                builderVM: builderVM,
                                generalErrorCheck: self.generalErrorCheck,
                                focusEqualValue:.refOperation,
                                focusField:$modelField)
                            
                           
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
                
            }.onAppear(perform: {
                builderVM.setMainVM(to: self.viewModel)
            })
        
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

import MyTextFieldSinkPack
struct HOReservationAmountLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    @ObservedObject var builderVM:HONewReservationBuilderVM
    let generalErrorCheck:Bool
    
    @State private var quantityStepIncrement:Int = 1
    
    let focusEqualValue:HOReservation.FocusField?
    @FocusState.Binding var focusField:HOReservation.FocusField?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Canale",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "plus.forwardslash.minus",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    Picker(selection: $builderVM.reservation.portale) {
                        
                        Text("portale:")
                            .tag(nil as String?)
                        
                        ForEach(HOReservationChannel.allCases,id:\.self) { channel in
                            
                            Text(channel.getExtendedRawValue())
                                .tag(channel.rawValue as String?)
                        }

                    } label: {
                        //
                    }
                    .menuIndicator(.hidden)
                    .tint(Color.hoAccent)
                    
                }

            VStack(alignment:.leading,spacing: 5) {

                let isIvaSubject = self.viewModel.getIvaSubject()
                
                HStack {
                    
                    CSSyncTextField_4b(
                        placeHolder: "0.0",
                        showDelete: false,
                        keyboardType:.decimalPad,
                        focusValue: focusEqualValue,
                        focusField: $focusField) {
                        
                        HStack(spacing:5) {
                            
                            Text("Entrata lorda")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.vertical,10)
                                .padding(.horizontal,6)
                                .background(Color.scooter_p53.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                            
                            Image(systemName: "eurosign.circle.fill")
                                .imageScale(.large)
                                .bold()
                               // .foregroundStyle(currentPrice == nil ? Color.gray : Color.green)
                        }
                        
                    } disableLogic: { value in
                        
                     return false
                        
                    } syncroAction: { new in
                        self.quantityStepIncrement = Int(new) ?? 0
                   
                    }
                
                    
                    //vbVisualCheckAndRefresh()
                }
                
                HStack {
                    
                    CSSyncTextField_4b(
                        placeHolder: "0.0",
                        showDelete: false,
                        keyboardType:.decimalPad,
                        focusValue: focusEqualValue,
                        focusField: $focusField) {
                        
                        HStack(spacing:5) {
                            
                            Text("Commissione")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.vertical,10)
                                .padding(.horizontal,6)
                                .background(Color.blazeOrange_p53.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                            
                            Image(systemName: "eurosign.circle.fill")
                                .imageScale(.large)
                                .bold()
                               // .foregroundStyle(currentPrice == nil ? Color.gray : Color.green)
                        }
                        
                    } disableLogic: { value in
                        
                     return false
                        
                    } syncroAction: { new in
                        self.quantityStepIncrement = Int(new) ?? 0
                   
                    }
                
                    
                    //vbVisualCheckAndRefresh()
                }
                
                HStack {
                    
                    CSSyncTextField_4b(
                        placeHolder: "0.0",
                        showDelete: false,
                        keyboardType:.decimalPad,
                        focusValue: focusEqualValue,
                        focusField: $focusField) {
                        
                        HStack(spacing:5) {
                            
                            Text("Transazione")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.vertical,10)
                                .padding(.horizontal,6)
                                .background(Color.blazeOrange_p53.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                            
                            Image(systemName: "eurosign.circle.fill")
                                .imageScale(.large)
                                .bold()
                               // .foregroundStyle(currentPrice == nil ? Color.gray : Color.green)
                        }
                        
                    } disableLogic: { value in
                        
                     return false
                        
                    } syncroAction: { new in
                        self.quantityStepIncrement = Int(new) ?? 0
                   
                    }
                
                    
                    //vbVisualCheckAndRefresh()
                }
                
                if !isIvaSubject {
                    
                    HStack {
                        
                        CSSyncTextField_4b(
                            placeHolder: "0.0",
                            showDelete: false,
                            keyboardType:.decimalPad,
                            focusValue: focusEqualValue,
                            focusField: $focusField) {
                            
                            HStack(spacing:5) {
                                
                                Text("Iva")
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.vertical,10)
                                    .padding(.horizontal,6)
                                    .background(Color.blazeOrange_p53.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                                
                                Image(systemName: "eurosign.circle.fill")
                                    .imageScale(.large)
                                    .bold()
                                   // .foregroundStyle(currentPrice == nil ? Color.gray : Color.green)
                            }
                            
                        } disableLogic: { value in
                            
                         return false
                            
                        } syncroAction: { new in
                            self.quantityStepIncrement = Int(new) ?? 0
                       
                        }
                    
                        
                        //vbVisualCheckAndRefresh()
                    }
                    
                }
                
                } // chiusa vstack interno
                
           // }

        } // chiusa vstack madre
       // .onAppear { self.builderVM.initOperationAmount() }
    } // chiusa body
    
    
   /* private func vbVisualCheckAndRefresh() -> some View {
        
         guard let syncedPriceValue = builderVM.syncedPriceValue,
               let currentValueToCheck = builderVM.currentValueToCheck,
              // let currentAmount = self.builderVM.operation.amount,
               let currentAmount = self.builderVM.sharedAmount,
               let pmc = currentAmount.pricePerUnit,
               let total = currentAmount.imponibile else {
          
             let value:(image:String,color:Color) = {
                 
                 if self.generalErrorCheck {
                     return ("exclamationmark.triangle.fill",Color.hoWarning)
                     
                 } else {
                     return ("checkmark.circle",Color.gray)
                 }
             }()
             
             return Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                 Image(systemName: value.image)
                     .foregroundStyle(value.color)
             }).disabled(true)
             
         }
            /* var currentValueToCheck:String?
             
             switch amountCategory {
             case .piece:
                 currentValueToCheck = String(pmc)
             case .pack:
                 currentValueToCheck = String(total)
             }*/
             
        var buttonImageName:String
        var buttonColor:Color
        var buttonAction:() -> () = { }
        var buttonDisable:Bool
        
             if currentValueToCheck == syncedPriceValue {
                 
                 buttonImageName = "checkmark.circle.fill"
                 buttonColor = Color.malibu_p53
                 buttonDisable = true
                
             } else {
                 
                 buttonImageName = "arrow.clockwise.circle.fill"
                 buttonColor = Color.hoAccent
                 buttonDisable = false
                 
                 let path = self.setAmountFromCategory().path
                // let converted = Int(syncedPriceValue)
                 buttonAction = {self.builderVM.updateAmountValue(from: syncedPriceValue, to: path)}
                
                 
             }
        
        return Button(action: {
            
            buttonAction()
            
        }, label: {
            Image(systemName: buttonImageName)
                 .foregroundStyle(buttonColor)
        })
        .disabled(buttonDisable)

         }
    */
    private func setIncrement() {
        
        let current = self.quantityStepIncrement
        
        if current == 1 { self.quantityStepIncrement = 5 }
        
        else if current % 25 != 0 { self.quantityStepIncrement += 5}
        
        else { self.quantityStepIncrement = 1}
        
        
    }
    
   /* private func setAmountFromCategory() -> (label:String,path:WritableKeyPath<HOOperationAmount,Double?>) {
        
        let label = builderVM.amountCategory.rawValue.capitalized
        var path:WritableKeyPath<HOOperationAmount,Double?>
        
        switch builderVM.amountCategory {
        case .piece:
            path = \.pricePerUnit
        case .pack:
            path = \.imponibile
        }
        
        return (label,path)
    }*/
    
    
}

