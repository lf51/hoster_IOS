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
  //  @Binding var reservation:HOReservation
    
    let generalErrorCheck:Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
           
            CSLabel_conVB(
                placeHolder: "Check-In",
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
                                self.builderVM.errorCheckIn()
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
        self.builderVM.reservation.dataArrivo = getCurrentDate()
        
    }
    
    private func getCurrentDate() -> Date? {
        
        let calendar = Locale.current.calendar // Calendar.current
        
        var today = calendar.dateComponents([.day,.month,.year,.weekday], from: Date.now)
        
        let wsCheckInTime = self.viewModel.getCheckInTime()
        
        today.hour = wsCheckInTime.hour
        today.minute = wsCheckInTime.minute
        
        guard let date = calendar.date(from: today) else { return nil }
        return date
    }
    
   /*private func errorIn() -> Bool {
        
        guard self.reservation.dataArrivo != nil,
              let notti = self.reservation.notti,
              notti > 0 else { return true }
        return false
        
    }*/
    
   /* @ViewBuilder private func vbArrivalDateExtended() -> some View {
        
        let arrivalDate = csTimeFormatter(style: .short).data.string(from: self.builderVM.reservation.dataArrivo ?? Date.now)
        
        let arrivalTime = csTimeFormatter(style: .short).ora.string(from: self.builderVM.reservation.dataArrivo ?? Date.now)
        
        Text("Check-in –––> \(arrivalDate) dalle ore \(arrivalTime)")
            .italic()
            .font(.caption2)
            .foregroundStyle(Color.hoDefaultText)
            .opacity(0.8)
    }*/ // deprecated
    
   /* @ViewBuilder private func vbDateLabel() -> some View {
        
            Text("Check-In:")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .font(.subheadline)
              
    }*/ // deprecated
    
    @ViewBuilder private func vbArrivalBox() -> some View {
        
        let dataArrivo = Binding {
            self.builderVM.reservation.dataArrivo ?? Date()
        } set: { new in
            
            self.builderVM.reservation.dataArrivo = new
        }

        HStack(alignment:.top) {

            DatePicker(selection: dataArrivo,
                       displayedComponents: [.date,.hourAndMinute]) {
              
                Text("Check-In:")
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                
            }
            .colorMultiply(Color.black)
            .fixedSize()
            
           Text("orario previsto")
                .italic()
                .font(.caption2)
                .foregroundStyle(Color.black)
            Spacer()
        }
        .padding(.horizontal,10)
        .padding(.vertical,5)
        .background {
            
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundStyle(Color.scooter_p53)
                .opacity(0.8)
                .frame(maxWidth:.infinity)
               
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
            
           let checkOut = csTimeFormatter(style: .long).data.string(from: self.builderVM.reservation.checkOut)
            
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
        
        HStack {
            
            CSSinkStepper_1(
                range:0...maxIn,
               // label:"Notti",
                image:"moon.zzz.fill",
                imageColor:Color.hoAccent,
                valueColor:Color.hoDefaultText,
                numberWidth:35) { _, newValue in
                
                    self.builderVM.reservation.notti = newValue

            }
            .fixedSize()
            
            let value = csSwitchSingolarePlurale(checkNumber: self.builderVM.reservation.notti ?? 1, wordSingolare: "notte", wordPlurale: "notti")
            
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
