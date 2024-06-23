//
//  HOPopMessageModifier.swift
//  hoster
//
//  Created by Calogero Friscia on 04/05/24.
//

import Foundation
import SwiftUI

struct HOPopMessageModifier: ViewModifier {

   @Binding var message:HOSystemMessage?
   
    func body(content: Content) -> some View {
       
           content
            .popover(item: $message, content: { message in
                
                VStack {
                    
                    Text(message.title)
                        .font(.title2)
                    
                    Text(message.body.bodyValue())
                        .font(.body)
                    
                    Spacer()
                    
                    Text("GRAFICA DA IMPLEMENTARE")
                }
                .presentationDetents([.medium])
                
            })
   
           
   }
}
