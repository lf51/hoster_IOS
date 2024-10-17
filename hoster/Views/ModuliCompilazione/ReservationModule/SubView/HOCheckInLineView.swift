//
//  HOCheckInLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 06/05/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOCheckInLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @ObservedObject var builderVM:HONewReservationBuilderVM

    let generalErrorCheck:Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
           
            //vbArrivalBox()
            
            CSLabel_conVB(
                placeHolder: "Calendar",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "calendar",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {
                    
                    vbNightIn()
                        .csWarningModifier(
                            warningColor: Color.hoWarning,
                            overlayAlign: .topTrailing,
                            isPresented: self.generalErrorCheck) {
                               // errorIn()
                                !self.builderVM.checkDateAndNight()
                            }
                    
            }
            
            VStack(alignment:.leading,spacing: 5) {
                
               vbArrivalBox()
              
               vbCheckOutBox()
          
            }
           
            
        }.onAppear { self.onAppearAction() }
        
    } // close body
    
    private func onAppearAction() {
        
       // print("OnAppear HOCheckInLineView")
        self.builderVM.reservation.imputationPeriod = getCurrentPeriod()
        
    }
    
    private func getCurrentPeriod() -> HOImputationPeriod {
        
        let today = self.viewModel.localCalendar.date(bySettingHour: 03, minute: 00, second: 00, of: Date.now)
        
        let period = HOImputationPeriod(start: today)
        
        return period
 
    }
    
    @ViewBuilder private func vbArrivalBox() -> some View {
        
        let dataArrivo = Binding {
            self.builderVM.reservation.dataArrivo ?? Date()
        } set: { new in
            
            let notti = self.builderVM.reservation.notti ?? 0

            self.builderVM.reservation.imputationPeriod?.start = new
            self.builderVM.reservation.imputationPeriod?.setDistance(newValue: notti)
        }

        let inToday = self.viewModel.localCalendar.isDateInToday(self.builderVM.reservation.dataArrivo ?? Date())
        
        HStack(alignment:.top) {
            
            DatePicker(selection: dataArrivo,
                       displayedComponents: [.date/*,.hourAndMinute*/]) {
                
                Text("Check-In:")
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                
            }
                       .colorMultiply(Color.black)
                       .fixedSize()
            
            
         //   Text("\(hour):\(minute)")
            
            Text("orario previsto")
                .italic()
                .font(.caption2)
                .foregroundStyle(Color.black)
            Spacer()
            
            if inToday {
                
                Button(action: {
                    
                    self.viewModel.sendAlertMessage(alert: AlertModel(title: "Attenzione", message: "Il check-in è previsto per la data di oggi. Correggere o ignorare."))
                    
                }, label: {
                    Image(systemName: "lightbulb.min.badge.exclamationmark.fill")
                        .imageScale(.medium)
                        .foregroundStyle(Color.yellow)
                })
                
            }
            
         //   Spacer()
            
        }
        .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundStyle(Color.scooter_p53)
                .opacity(0.8)
                .frame(maxWidth:400)
            
        }
        
    }
    

    
  /*  @ViewBuilder private func vbPernottBox() -> some View {
        
        VStack {
            
            Text("Pernottamenti")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
                
            Text("\(self.builderVM.reservation.pernottamenti)")
                .fontWeight(.heavy)
                .font(.body)
                .foregroundStyle(Color.scooter_p53)
        }
        .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundStyle(Color.hoBackGround)
                .frame(maxWidth:.infinity)
               
        }
        
    }*/ // deprecated
    
    @ViewBuilder private func vbCheckOutBox() -> some View {
        
        HStack {
        
        HStack {
            
            let checkOut:String = {
                
                guard let out = self.builderVM.reservation.checkOut else { return "no value"}
                
                return csTimeFormatter(style: .long).data.string(from: out)
            }()
            
            Text("Check-Out:")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
            
            Text(checkOut)
                .italic()
                .fontWeight(.light)
                .font(.body)
                .foregroundStyle(Color.malibu_p53)
            // .lineLimit(1)
            //  Spacer()
        }
        .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundStyle(Color.hoBackGround)
            // .frame(maxWidth:.infinity)
            
        }
        
            if !builderVM.inOutAreConformed {
                
                Button(action: {
                    
                    self.viewModel.sendAlertMessage(alert: AlertModel(title: "Attenzione", message: "Il numero minimo di notti è uno"))
                    
                }, label: {
                    Image(systemName: "lightbulb.min.badge.exclamationmark.fill")
                        .imageScale(.medium)
                        .foregroundStyle(Color.yellow)
                })
                
            }
            
    }
        
        
    }
    
    /*@ViewBuilder private func vbCheckOutBox() -> some View {
        
       VStack {
            
            let checkOut = csTimeFormatter().data.string(from: self.builderVM.reservation.checkOut)
            
            Text("Check-Out")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
                
            Text(checkOut)
                .italic()
                .fontWeight(.light)
                .font(.body)
                .foregroundStyle(Color.malibu_p53)
                .lineLimit(1)
        }
       
        .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundStyle(Color.hoBackGround)
               // .frame(maxWidth:.infinity)
               
        }
        
    }*/ // deprecated
    
    @ViewBuilder private func vbNightIn() -> some View {

        let maxIn = self.viewModel.getMaxNightIn()
       // let initialValue = self.builderVM.reservation.notti ?? 0
        HStack {
            
            CSSinkStepper_1(
               // initialValue:initialValue,
                range:0...maxIn,
               /* label:"Notti",
                labelBackground: Color.sienna_p52,*/
                image:"moon.zzz.fill",
                imageColor:Color.hoAccent,
                valueColor:Color.hoDefaultText,
                numberWidth:35) { _, newValue in
                
                    self.builderVM.reservation.imputationPeriod?.ddDistance = newValue

            }
            //.id(self.builderVM.reservation.dataArrivo)
            .fixedSize()
            
            let value = csSwitchSingolarePlurale(checkNumber: self.builderVM.reservation.notti ?? 1, wordSingolare: "notte", wordPlurale: "notti")
           Text(self.builderVM.reservation.notti?.description ?? "no")
            Text(value)
                .italic()
                .font(.caption)
                .foregroundStyle(Color.hoDefaultText)
                .lineLimit(1)
                .opacity(0.8)
            
        }/*.csWarningModifier(
            warningColor: Color.hoWarning,
            overlayAlign: .topTrailing,
            isPresented: self.generalErrorCheck) {
                (self.reservation.notti ?? 0) == 0
        }*/
        
    }
}
