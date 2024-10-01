//
//  HOGeneralView.swift
//  hoster
//
//  Created by Calogero Friscia on 21/09/24.
//

import SwiftUI
import MyPackView

struct HOGeneralDataView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let focusUnit:String?
    
    var body: some View {
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.1,
            shadowColor: .black,
            rowColor: Color.scooter_p53,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading,spacing:5) {

                    HStack {
                        let sideLabel = focusUnit == nil ? "Struttura" : "Parziale"
                        
                        Text("Resoconto \(sideLabel)")
                             .font(.title2)
                             .bold()
                             .foregroundStyle(Color.cinderella_p47)
                             .opacity(0.8)
                        
                        Spacer()
                        
                        Button(action: {
                            
                            self.viewModel.addToThePath(destinationPath: .home, destinationView: .reportAnnuale(focusUnit))
                            
                        }, label: {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.hoAccent)
                        })
                        
                    }
                    
                    HOResumeLineView(
                        mmOrdinale: nil,
                        focusUnit: focusUnit,
                        firstLineFont: .subheadline,
                        amountFont: (.title,.largeTitle),
                        subTextFont: .caption)
                    
                }
               .padding(.horizontal,10)
                .padding(.vertical,5)
                
            }
        
        
    }
    
    // method
    
   
}

/*#Preview {
    HOGeneralView()
}*/



