//
//  HOGenericNoteLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 03/07/24.
//

import SwiftUI
import MyPackView
import MyTextFieldSinkPack

struct HOGenericNoteLineView<Object:HOProFocusField&HOProNoteField>:View {
    
    @Binding var oggetto:Object
    
    @State private var addNote:Bool = false
    
    let focusEqualValue:Object.FocusField?
    @FocusState.Binding var focusField:Object.FocusField?
    
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
                    value: self.oggetto.note,
                    dismissButton: $addNote,
                    focusValue: focusEqualValue,
                    focusField: $focusField) { newValue in
                        
                        self.addNote(newValue: newValue)
                        
                    }
                                          
            } else {
                
                Text(self.oggetto.note == nil ? "Nessuna nota inserita" : self.oggetto.note!)
                    .italic()
                    .fontWeight(.light)
                    .foregroundStyle(Color.hoDefaultText)
            }
            
        
        } // chiusa VStack
        
    } // chiusa body
    
    private func addNote(newValue:String) {
        
        guard newValue != "" else {
            self.oggetto.note = nil
            return
        }
        
        self.oggetto.note = newValue
    }
}
