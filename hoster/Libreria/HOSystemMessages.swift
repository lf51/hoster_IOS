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
    case cityTaxImputation
    // messagi una tantum
    case custom(_ input:String)
    
    func bodyValue() -> String {
        
        switch self {
        case .cityTaxImputation:
            return "Il peso della tassa di soggiorno è diviso sull'intero periodo di permanenza su base giornaliera. Le prenotazioni a cavallo fra due periodi (due mesi, o due anni) possono portare a risultati incoerenti. In questi casi è necessario aggiungere o sottrarre manualmente la quota parte che si vuole includere o escludere.\nEsempio: Prenotazione di due notti 31 dicembre 2023 - 2 gennaio 2024. Tassa dovuta 4 euro. Il sistema attribuirà due euro in dicembre 2023 e due in gennaio 2024. Se ci è necessario dichiarare in base al check-in, sarà necessario togliere due a gennaio e aggiungerle a dicembre.\nNB:Questo Applicativo ha lo scopo di essere una guida, per dichiarazioni contabili verso enti ufficiali si raccomanda di controllare sempre i dati e rivolgersi a professionisti."
        case .custom(let input):
            return input
        }
    }
}

enum HOInfoMessageVector {
    
    case pop
    case log
}

/// pulsante pigiabile per mostrare una guida e/o informazioni utili
struct HOInfoMessageView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    var imageScale: Image.Scale = .medium
    
    let messageBody: HOSystemMessage
    
    var body: some View {
        
        Button(action: {
            
            self.viewModel.sendSystemMessage(message: messageBody)
        }, label: {
            Image(systemName: "info.circle.fill")
                .imageScale(imageScale)
                .bold()
                .foregroundStyle(Color.white)
        })

    }
}
