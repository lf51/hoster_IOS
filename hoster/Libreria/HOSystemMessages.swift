//
//  HOSystemMessages.swift
//  hoster
//
//  Created by Calogero Friscia on 04/05/24.
//

import Foundation
import MyPackView
import SwiftUI

struct HOSystemMessage:Identifiable {
    
    let id: String = UUID().uuidString
    
    let vector: HOInfoMessageVector
    
    let title: String
    let body: HOSystemBodyMessage
    
}


enum HOSystemBodyMessage {
    
    // messaggi ripetibili
    
    // messagi una tantum
    case custom(_ input:String)
    
    func bodyValue() -> String {
        
        switch self {
        case .custom(let input):
            return input
        }
    }
}

enum HOInfoMessageVector {
    
    case pop
    case log
}

/// Quando vogliamo un pulsante pigiabile con informazioni
struct HOInfoMessageView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    var imageScale: Image.Scale = .medium
    
    let messageBody: HOSystemMessage
    
    var body: some View {
        
        Image(systemName: "info.circle.fill")
            .imageScale(imageScale)
            .bold()
            .foregroundStyle(Color.white)
            .onTapGesture {
                
                self.viewModel.sendSystemMessage(message: messageBody)

            }
    }
}
