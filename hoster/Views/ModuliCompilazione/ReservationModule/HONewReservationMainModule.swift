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
    
    @State private var generalErrorCheck: Bool = false
    @State private var generalErrorByPassable: Bool = false
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
                            
                            HOCityTaxLineView(
                                builderVM: builderVM)

                            HOReservationAmountLineView(
                                builderVM: builderVM,
                                generalErrorCheck: self.generalErrorCheck,
                                focusField:$modelField)
                            .id(builderVM.portale)
                            
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
                builderVM.initOnAppear(to: self.viewModel)
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
            try self.builderVM.checkValidation() { focusOn in
                
                self.modelField = focusOn
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
            
            /*DialogButtonElement(
                label: .saveNew,
                role: nil) {
                    true
                } action: {
                    //self.builderVM.publishOperation(refreshPath: nil)
                    
                   /* self.viewModel.addToThePath(destinationPath: self.destinationPath, destinationView: .reservation(HOReservation()))*/
                }*/

            DialogButtonElement(
                label: .saveEsc) {
                    true
                } action: {
                    self.builderVM.publishOperation(refreshPath: self.destinationPath)
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
    @FocusState.Binding var focusField:HOReservation.FocusField?
    
    @State private var quantityStepIncrement:Int = 1
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            CSLabel_conVB(
                placeHolder: "Canale",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "plus.forwardslash.minus",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {

                    HStack {
                        
                        Picker(selection: $builderVM.portale) {
                            
                            Text("OTA:")
                                .tag(nil as HOOTAChannel?)
                            
                            ForEach(self.viewModel.getOTAChannels(),id:\.self) { channel in
                                
                                Text(channel.label ?? "")
                                    .tag(channel as HOOTAChannel?)
                            }

                        } label: {
                            //
                        }
                        .menuIndicator(.hidden)
                        .tint(Color.hoAccent)
                        .csWarningModifier(
                            warningColor: Color.hoWarning,
                            offset:(0,-5),
                            isPresented: self.generalErrorCheck) {
                            self.builderVM.portale == nil
                        }
                        
                        Spacer()
                        
                        HOInfoMessageView(
                            messageBody: HOSystemMessage(
                                vector: .log,
                                title: "INFO",
                                body: .custom(self.getInfo())))
                    }

                }

                VStack(alignment:.leading,spacing: 5) {

                    HOCommissionableLineView(
                        builderVM: builderVM,
                        focusField: $focusField,
                        generalErrorCheck: self.generalErrorCheck)
                        .focused($focusField,equals: .commisionabile)

                    HOOTACommissionLineView(builderVM: builderVM)
                       // .id(self.builderVM.portale)
                    
                    if let _ = builderVM.transazioneValue {
                        
                        HOCostiTransazioneLineView(builderVM: builderVM)
                           
                   }
                    
                    if let _ = builderVM.ivaValue {
                        
                        HOCostoIvaLineView(builderVM: builderVM)
                            
                    }
                    
                } // chiusa vstack interno
            
                    HOAmountResumeLineView(builderVM: builderVM)
                       .id(self.builderVM.commissionable)
                    
                   
              //  .id(self.builderVM.portale)
      

        } // chiusa vstack madre
     
    } // chiusa body
    
    
    private func getInfo() -> String {
        
        "Dal prezzo di vendita va esclusa la tassa di soggiorno.\n• SOGGETTI IVA:\nConsigliamo di escludere l'iva in entrata e in uscita. Inserire gli importi al netto.\n• SOGGETTI NON IVA:\nConsigliamo di includere l'iva nelle entrate e utilizzare l'apposito campo come costo.\n• COMMISSIONE:\nQuota riconosciuta ai portali per l'intermediazione.\n• TRANSAZIONE:\nTrattasi del costo che paghiamo al portale o alla banca per i pagamenti tramite carta. In caso di pagamenti in contanti il campo va azzerato manualmente.\n• IVA:\n Nella fattura l'iva sulla commissione e sulla transazione dovrebbe essere separata. I soggetti IVA non devono considerarla un costo e quindi la devono escludere dai costi di commissione e transazione. I soggetti non IVA la devono considerare un costo e applicarla tramite l'apposito campo."
    }
}

