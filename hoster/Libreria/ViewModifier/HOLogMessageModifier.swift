//
//  HOSystemMessageViewModifier.swift
//  hoster
//
//  Created by Calogero Friscia on 04/05/24.
//

import Foundation
import SwiftUI

 struct HOLogMessageModifier: ViewModifier {

    @Binding var message:HOSystemMessage?
    
     func body(content: Content) -> some View {
        
            content
            .overlay(alignment:.bottom) {

                    if let message {
                        
                        VStack {
                            
                            Text(message.title)
                                .font(.title2)
                            
                            Text(message.body.bodyValue())
                                .font(.body)
                        }
                            .padding(.horizontal,5)
                            .padding(.vertical,10)
                            .frame(maxWidth:.infinity)
                            .background {
                                  RoundedRectangle(cornerRadius: 5.0)
                                    .foregroundStyle(Color.yellow.opacity(0.4))
                              }
                            .padding(.horizontal)
                            .padding(.bottom,150)
                            .onTapGesture {
                                  withAnimation {
                                      self.message = nil
                                  }
                              }
                    }
                }
            
    }
}
