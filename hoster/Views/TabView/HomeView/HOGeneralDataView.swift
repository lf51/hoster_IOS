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
    
    @State var openDetails:Bool = false
    
    var body: some View {
        
        CSZStackVB_Framed(
            frameWidth: 400,
            backgroundOpacity: 0.1,
            shadowColor: .black,
            rowColor: Color.scooter_p53,
            cornerRadius: 5.0,
            riduzioneMainBounds: 20) {
                
                VStack(alignment:.leading,spacing:0) {

                    VStack {
                        
                        HStack {
                            
                            let sideLabel:String = {
                                
                                if let focusUnit {
                                    
                                    let unit = self.viewModel.getUnitModel(from: focusUnit)
                                    return unit?.label ?? "Sub Unit"
                                    
                                } else {
                                    return "Struttura"
                                }

                            }()
                            
                            Text("Prenotazioni \(sideLabel)")
                                // .font(.title2)
                                 .bold()
                                 .foregroundStyle(Color.cinderella_p47)
                                 .opacity(0.8)
                            
                            Spacer()
                            
                                Button(action: {
                                    
                                    self.viewModel.addToThePath(destinationPath: .home, destinationView: .pernottamentiAnnualReport)
                                    
                                }, label: {
                                    Image(systemName: "arrow.up.forward.circle.fill")
                                      //  .imageScale(.large)
                                        .foregroundStyle(Color.hoAccent)
                                })
                                
                        }
                        .font(.title2)
                        
                        HOReservationsResumeLineView(
                                mmOrdinale: nil,
                                focusUnit: focusUnit,
                                firstLineFont: .headline)
                    }
                   // .padding(.bottom,10)
                        
                    if openDetails {
                        
                        vbPernottamentoResume()
                            .padding(.top,10)
                        
                        vbCommissionsResume()
                        
                        vbCityTaxResume()
                        
                    }
 
                }
                .padding(.horizontal,10)
                .padding(.vertical,5)
                .onTapGesture {
                    withAnimation {
                        self.openDetails.toggle()
                    }
                }
            }
        
        
    } // chiusa body
    
 
    
    // method
    @ViewBuilder private func vbPernottamentoResume() -> some View {
        
        VStack(alignment:.leading) {
            
            Text("Vendita Pernottamenti")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.cinderella_p47)
                .opacity(0.8)
            
            HONastrinoResumeLine(
                account: HOImputationAccount.pernottamento,
                mmOrdinal: nil,
                unitRef: focusUnit,
                amountFont: (.title,.largeTitle),
                amountColor: (Color.green,Color.hoAccent),
                subTextFont: .caption,
                show: .totalPlusAverage)
                    
            
        }
        
    }
    
    @ViewBuilder private func vbCommissionsResume() -> some View {
        
        
        VStack(alignment:.leading) {
            
            Text("Commissioni OTA")
                .font(.title3)
                .bold()
                .foregroundStyle(Color.cinderella_p47)
                .opacity(0.8)

            HONastrinoResumeLine(
                account: HOImputationAccount.ota,
                mmOrdinal: nil,
                unitRef: focusUnit,
                amountFont: (.title,.largeTitle),
                amountColor: (Color.gray,Color.hoAccent),
                subTextFont: .caption,
                show: .total)
              
        }
        
    }
    
    @ViewBuilder private func vbCityTaxResume() -> some View {
        
        VStack(alignment:.leading) {
            
            Text("Tassa di Soggiorno")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.cinderella_p47)
                .opacity(0.8)
            
            HONastrinoResumeLine(
                account: HOImputationAccount.cityTax,
                mmOrdinal: nil,
                unitRef: focusUnit,
                amountFont: (.title,.largeTitle),
                amountColor: (Color.green,Color.gray),
                subTextFont: .caption,
                show: .plusMinus)
                    
            
            
        }
        
    }
}

/*#Preview {
    HOGeneralView()
}*/



