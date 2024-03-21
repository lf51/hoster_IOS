//
//  BedUnityBuilderView.swift
//  hoster
//
//  Created by Calogero Friscia on 09/03/24.
//

/*
import Foundation
import SwiftUI
import MyPackView

@resultBuilder
struct AddUnityLine {
    
    static func buildBlock(_ components: UnitModel...) -> some View {
        
        ForEach(components,id:\.self) { unity in
            
            HStack {
                
                Text("Label")
                
                
                Text("Pax:")
                    .foregroundStyle(Color.white)
                    .bold()
                    .padding(10)
                    .background(Color.cyan.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10,style: .circular))
                   // .shadow(radius: -20)
                
               /* let paxString = Binding {
                    String(self.pax)
                } set: { newValue in
                    self.pax = Int(newValue) ?? 0
                }*/

                CSTextField_4(
                    textFieldItem: .constant("paxString"),
                    placeHolder: "0",
                    image: "bed.double.fill",
                    imageActiveColor: Color.blue,
                    imageScale: .medium,
                    showDelete: false,
                    keyboardType: .numberPad)
                .frame(width: 100)
               
               /* let personValue = csSwitchSingolarePlurale(checkNumber: 0, wordSingolare: "person", wordPlurale: "persons")
                
                Text("max \(0) \(personValue) in")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .italic()
                    .foregroundStyle(Color.black)
                    .opacity(0.6) */
                
                Spacer()

            }

        }

    }
    
    
}

@ViewBuilder func csAddingUnity(@AddUnityLine _ content: () -> some View) -> some View {
   
    content()
}*/
