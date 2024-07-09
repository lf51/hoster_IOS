//
//  HONewReservation.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView

struct HONewReservationMainModule: View {
    
    @EnvironmentObject var viewModel: HOViewModel
    
    @State private var reservation: HOReservation
    @State private var storedReservation: HOReservation // per il reset
    
    @State private var generalErrorCheck: Bool = true
    @FocusState private var modelField:HOReservation.FocusField?

    let destinationPath: HODestinationPath
    
    @State private var unitOnFocus:HOUnitModel?
    
    init(reservation: HOReservation, destinationPath: HODestinationPath) {
     
        self.reservation = reservation
        self.storedReservation = reservation

        self.destinationPath = destinationPath
    }
    
    var body: some View {
        
        CSZStackVB(
            title: self.reservation.labelModCompile,
            backgroundColorView: Color.hoBackGround) {
            
                VStack {
                    
                    vbUnitLine()
                      
                    ScrollView {
                        
                        VStack(alignment:.leading,spacing:15) {
                            
                            HOGuestLineView(
                                reservation:$reservation,
                                generalErrorCheck: generalErrorCheck,
                                focusEqualValue: .guest,
                                focusField: $modelField)
                            .focused($modelField, equals: .guest)
                            
                            HOCheckInLineView(
                                reservation: $reservation,
                                generalErrorCheck: generalErrorCheck)
                            
                            HOBedDispoLineView(
                                reservation: $reservation,
                                generalErrorCheck: generalErrorCheck)
                            
                           /* HOReservationNoteLineView(
                                reservation: $reservation,
                                focusEqualValue: .note,
                                focusField: $modelField)
                            .focused($modelField,equals: .note)*/
                            
                            HOGenericNoteLineView<HOReservation>(
                                oggetto: $reservation,
                                focusEqualValue: .note,
                                focusField: $modelField)
                            .focused($modelField,equals: .note)
                        }
                    }
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.immediately)
                    
                }
                .padding(.horizontal,10)
                
            }.onAppear(perform: {
                addUnitOnAppear()
            })
        
    } // close body
    
    private func addUnitOnAppear() {
        
        guard let ws = self.viewModel.db.currentWorkSpace else {
            
            let alert = AlertModel(
                title: "Errore",
                message: "Current WorkSpace corrupted")
            self.viewModel.sendAlertMessage(alert: alert)
            return
        }
        
        switch ws.wsType {
       
        case .wholeUnit:
            let main = ws.wsUnit.main
            self.unitOnFocus = main
        case .withSub:
            self.unitOnFocus = nil
        }
        
    }
    
    @ViewBuilder private func vbUnitLine() -> some View {
        
        let ws = self.viewModel.db.currentWorkSpace
        
        HStack {
            
            Text(ws?.wsLabel ?? "error")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.hoDefaultText)
            Spacer()
            
            switch ws?.wsType {
                
            case .withSub:
                
                HOUnitLineView(
                    unit: $unitOnFocus)
                .csWarningModifier(
                    warningColor: Color.hoWarning,
                    overlayAlign: .topTrailing,
                    isPresented: generalErrorCheck) {
                    self.unitOnFocus == nil
                }
               
            default:
                Text("entire unit")
                    .italic()
                    .font(.subheadline)
                    .foregroundStyle(Color.hoDefaultText)
            }
            
        }.padding(.horizontal,10)
        
    }
    
    // TEST
    func addNew() {
        /// TEST TEST TEST da verificare tutto il processo di pubblicazione
        var newBook = HOReservation()
        newBook.guestName = String(newBook.hashValue)
        
        self.viewModel.publishData(from: newBook, syncroDataPath: \.workSpaceReservations)
        
    }
}

#Preview {
    
    NavigationStack {
        HONewReservationMainModule(
            reservation: HOReservation(),
            destinationPath: .reservations)
            .environmentObject(testViewModel)
    }

}



