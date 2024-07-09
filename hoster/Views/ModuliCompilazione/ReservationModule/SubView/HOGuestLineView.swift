//
//  HOGuestLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 05/05/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOGuestLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    @Binding var reservation:HOReservation
    let generalErrorCheck:Bool
    
   // @State private var stateMessage:String = ""
    
    let focusEqualValue:HOReservation.FocusField?
    @FocusState.Binding var focusField:HOReservation.FocusField?
    
    var body: some View {
        
        VStack(alignment:.leading,spacing:10) {
        
            CSLabel_conVB(
                placeHolder: "Guest",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "person.fill",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {

                    HOGuestTypeLineView(
                        reservation: $reservation,
                        generalErrorCheck: self.generalErrorCheck)

                }
            
            let placeHolder = self.reservation.guestName ?? "guest name on reservation"
            
           // VStack(alignment:.leading,spacing:5) {
                
                CSSyncTextField_4b(
                    placeHolder: placeHolder,
                    focusValue:focusEqualValue,
                    focusField:$focusField) {
                        
                        vbInlineTextFieldContent()
                        
                    } disableLogic: { value in
                        self.disableLogic(value: value)
                    } keyboardMiddleContent: { value in
                        self.vbMidlleKeyboard(value: value)
                    } syncroAction: { value in
                        self.guestNameSubmit(new: value)
                    }

                   /* Text(stateMessage)
                        .italic()
                        .font(.caption2)
                        .foregroundStyle(Color.hoDefaultText)
                        .opacity(0.8) */
          // }

        }/*.onChange(of: self.generalErrorCheck) { _, newValue in
            
            if newValue {
                
                if self.reservation.guestName == nil {
                    
                    self.stateMessage = "[Error]: Guest name missed"
                }
                
            }
        }*/
       /* .onAppear {
            self.stateMessage = getDefaultStateMessage()
        }*/
    }
    
    @ViewBuilder private func vbInlineTextFieldContent() -> some View {
        
        let image:(color:Color,symbol:String) = {
            
            if self.reservation.guestName != nil {
                
                return (Color.hoAccent,"person.fill")
                
            } else { return getImageInfoForNilGuest() }
            
        }()
        
        Image(systemName:image.symbol)
            .foregroundStyle(image.color)
            .padding(.leading,15)
    }
    
    private func getImageInfoForNilGuest() -> (color:Color,symbol:String) {
        
        if generalErrorCheck {
            
            return (Color.hoWarning,"exclamationmark.triangle.fill")
            
        } else {
            
            return (Color.gray,"person")
            
        }
        
    }
    
    private func guestNameSubmit(new:String) {
        
       /* let newValue = new.replacingOccurrences(of: " ", with: "")
        
        guard newValue.count > 5 else {
            
            self.stateMessage = "Value can't be updated. Min 5 characters"
            return }
        
        self.stateMessage = getDefaultStateMessage()*/
        
        let forbidden:CharacterSet = .punctuationCharacters.union(.whitespacesAndNewlines).union(.symbols).union(.decimalDigits)
        
        let cleanString = csStringCleaner(value:new, byCharacter:forbidden)
        self.reservation.guestName = cleanString.capitalized
        
    }
    
   /* private func getDefaultStateMessage() -> String {
        
        "Press Enter to update value. Min 5 characters"
        
    }*/
    
    /// guest name minimo 3 character max 4 words. No punteggiatura
    private func disableLogic(value:String) -> Bool {
        
        let forbidden:CharacterSet = .punctuationCharacters.union(.whitespacesAndNewlines).union(.symbols).union(.decimalDigits)
        
        let cleanString = csStringCleaner(value:value, byCharacter:forbidden)
        
        guard cleanString.count > 3 else { return true }
        
        let wordCount = cleanString.components(separatedBy: " ").count
        
        return wordCount > 4
        
        
    }
    
    @ViewBuilder private func vbMidlleKeyboard(value:String) -> some View {
        
        Text("min 3 caratteri - max 4 parole")
            .font(.caption2)
            .italic()
        
    }
    
}

struct HOGuestTypeLineView:View {
    
    @Binding var reservation:HOReservation
    
    let generalErrorCheck:Bool
    
    var body: some View {
        
        HStack(spacing:10) {
        
            vbPaxIn()
           
            vbGuestType()

        }
        .shadow(radius: 0.5)
        
    }
    
    @ViewBuilder private func vbPaxIn() -> some View {
        
        let paxRange = self.reservation.guestType?.getPaxRange() ?? 0...20
        
        CSSinkStepper_1(
            range:paxRange,
            image:"person.2.fill",
            imageColor:Color.hoAccent,
            valueColor:Color.hoDefaultText,
            numberWidth:35) { _, newValue in
            
                self.reservation.pax = newValue

        }
        .fixedSize()
        
    }
    
    @ViewBuilder private func vbGuestType() -> some View {
            
        Group {

            Picker(selection: self.$reservation.guestType) {
                
                Text("type:")
                    .tag(nil as HOGuestType?)
                
                ForEach(HOGuestType.allCases,id:\.self) { type in
                    
                    Text(type.stringValue())
                        .tag(type as HOGuestType?)
        
                }
                
            } label: {
                Text("")
            }
            .menuIndicator(.hidden)
            .tint(Color.hoAccent)
        }
        .csWarningModifier(
            warningColor: Color.hoWarning,
            overlayAlign: .trailing,
            isPresented: self.generalErrorCheck) {

                self.getGuestTypeError()
            }
            
        }
        
    private func getGuestTypeError() -> Bool {
        
        guard let type = self.reservation.guestType else {
            return true
        }
        
        guard let pax = self.reservation.pax else { return true }
        
        let typePax = type.getPaxLimit()
        
        switch typePax.limit {
            
        case .exact:
            let condition = pax == typePax.value
            return !condition
            
        case .minimum:
            let condition = pax >= typePax.value
            return !condition
            
        }
    }
}
