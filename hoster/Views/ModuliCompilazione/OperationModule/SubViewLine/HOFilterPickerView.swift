//
//  HONewOperationMainModule.swift
//  hoster
//
//  Created by Calogero Friscia on 09/05/24.
//

import SwiftUI
import MyPackView

struct HOFilterPickerView<E:HOProWritingDownLoadFilter>:View {
   
    @Binding var property:E?
    let nilImage:String
    let nilPropertyLabel:String
    let allCases:[E]
    
    /// <#Description#>
    /// - Parameters:
    ///   - property: proprietà da modificare attraverso il picker
    ///   - nilImage: immagine da mostrare quando il valore è nil
    ///   - allCases: casi da iterare fra cui scegliere. Se nil verrà usato l'allcase dell'oggetto
    init(property: Binding<E?>, nilImage: String,nilPropertyLabel:String = "no filter", allCases: [E]? = nil) {
       
        _property = property
        self.nilImage = nilImage
        self.nilPropertyLabel = nilPropertyLabel
        self.allCases = allCases ?? E.allCases
    }
    
    var body: some View {
        
        HStack(spacing:0) {
                
                let value:(image:String,colorImage:Color) = {
                    
                    guard let property else {
                        return (nilImage,Color.gray)
                    }
                    
                    let img = property.getImageAssociated()
                    let imgColor = property.getColorAssociated()
                    
                    return (img,imgColor)
                }()
                
               Image(systemName: value.image)
                    .bold()
                    .imageScale(.medium)
                    .foregroundStyle(value.colorImage)
                 
                
            Picker(selection:$property) {
                    
                    
                if property == nil {
                    let label = "Seleziona \(nilPropertyLabel)"
                 
                    Text(label.capitalized)
                        .tag(nil as E?)
                }
                    
                    ForEach(allCases,id:\.self) { sign in
                        
                            Text(sign.getRowLabel().capitalized)
                                .tag(sign as E?)
                    }
                    
                } label: {
                    //
                }
                .csModifier(self.property != nil) { picker in
                    picker
                        .menuIndicator(.hidden)
                        .tint(Color.hoDefaultText)
                        .opacity(0.6)
                }
                .tint(Color.hoAccent)
                
            Spacer()
            
            }
            .padding(.leading,5)
            .background {
                    RoundedRectangle(cornerRadius: 5.0)
                    .foregroundStyle(Color.hoDefaultText)
                        .opacity(0.1)
                        .shadow(radius: 5)
                        
                }
            .onAppear {
                print("ON APPEAR PICKER for allCases:\(allCases.description)")
                if allCases.count == 1 {
                   property = allCases.first
                }
            }

    } // chiusa body
}
