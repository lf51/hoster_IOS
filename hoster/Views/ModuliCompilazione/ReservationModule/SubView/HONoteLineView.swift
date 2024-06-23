//
//  HONoteLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 07/05/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HONoteLineView:View {
    
    @Binding var reservation:HOReservation
    
    @State private var addNote:Bool = false
    
    let focusEqualValue:HOReservation.FocusField?
    @FocusState.Binding var focusField:HOReservation.FocusField?
    
    var body: some View {
        
        VStack(alignment:.leading,spacing:10) {
            
            CSLabel_conVB(
                placeHolder: "Note",
                placeHolderColor: Color.hoDefaultText,
                imageNameOrEmojy: "scribble",
                imageColor: Color.hoDefaultText,
                backgroundColor: Color.hoBackGround,
                backgroundOpacity: 0.4) {

                    CSButton_image(
                        activationBool: addNote,
                        frontImage: "minus.circle",
                        backImage:"square.and.pencil",
                        imageScale: .large,
                        backColor: .hoWarning,
                        frontColor: .hoAccent){
                            withAnimation(.default) {
                                self.addNote.toggle()
                              
                            }

                        }
                }
            
            if self.addNote {

                CSSyncTextField_ExpandingBox(
                    value: self.reservation.note,
                    dismissButton: $addNote,
                    focusValue: focusEqualValue,
                    focusField: $focusField) { newValue in
                        
                        self.addNote(newValue: newValue)
                        
                    }
                                          
            } else {
                
                Text(reservation.note == nil ? "Nessuna nota inserita" : reservation.note!)
                    .italic()
                    .fontWeight(.light)
                    .foregroundStyle(Color.hoDefaultText)
            }
            
        
        } // chiusa VStack
        
    } // chiusa body
    
    private func addNote(newValue:String) {
        
        guard newValue != "" else {
            self.reservation.note = nil
            return
        }
        
        self.reservation.note = newValue
    }
}
