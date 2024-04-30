//
//  HONewReservation.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI

struct HONewReservationMainModule: View {
    
    @EnvironmentObject var viewModel: HOViewModel
    @State private var newModule: HOReservation
    
    let backgroundColorView: Color
    let destinationPath: HODestinationPath
    
    
    init(newModule: HOReservation, backgroundColorView: Color, destinationPath: HODestinationPath) {
     
        self.newModule = newModule
        self.backgroundColorView = backgroundColorView
        self.destinationPath = destinationPath
    }
    
    var body: some View {
        Button("Add New") {
            addNew()
        }
    }
    
    func addNew() {
        /// TEST TEST TEST da verificare tutto il processo di pubblicazione
        var newBook = HOReservation()
        newBook.guestName = String(newBook.hashValue)
        
        let collRef = self.viewModel.dbManager.workSpaceReservations.mainTree
        
        let data = HODataForPublishing(collectionRef:collRef, model: newBook)
        
            
        do {
            try self.viewModel.dbManager.publishDocumentData(from: data)
        } catch let error {
            
            print("ERRORE")
        }
        
        
    }
}

#Preview {
    HONewReservationMainModule(newModule: HOReservation(), backgroundColorView: Color.gray, destinationPath: .reservations)
        
}
