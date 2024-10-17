//
//  Untitled.swift
//  hoster
//
//  Created by Calogero Friscia on 16/10/24.
//

import SwiftUI
import MyPackView

struct HOReservationsResumeLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let mmOrdinale:Int?
    let focusUnit:String?
    var firstLineFont:Font? = .caption
    var firstLineColor:Color = .gray
   // var amountFont:(Font,Font)? = (.title3,.title2)
   // var subTextFont:Font? = .system(size: 10)
    
    var body: some View {
        
        let reservationsInfo = viewModel.getReservationInfo(month:mmOrdinale,sub: focusUnit)
        
        let count = reservationsInfo?.count ?? 0
        let countString = csSwitchSingolarePlurale(checkNumber: count, wordSingolare: "arrivo", wordPlurale: "arrivi")
        let guest = reservationsInfo?.totaleGuest ?? 0
        let night = reservationsInfo?.totaleNotti ?? 0
        
        let tassoDoubleCutted:Double = {
            let tassoOccupazioneNotti = reservationsInfo?.tassoOccupazioneNigh ?? 0
            let tassoCutted = String(format: "%.4f", tassoOccupazioneNotti)
            
            return Double(tassoCutted) ?? 0
        }()

            HStack(spacing:20) {
                
                HStack(spacing:2) {
                    
                    Image(systemName: "person.2.square.stack")
                       
                    Text("\(count) \(countString)")
                }
                
                HStack(spacing:2) {
                    
                    Image(systemName: "person.fill")
                       
                    Text("\(guest)")
                       
                }
                
                Spacer()
                
                HStack(spacing:2){
                    
                    Image(systemName: "moon.zzz.fill")
                       
                    Text("\(night)")
                    
                    Text("(\(tassoDoubleCutted,format: .percent))")
                        .colorInvert()
                        .padding(.horizontal,3)
                        .onTapGesture {
                            self.viewModel.sendSystemMessage(message: HOSystemMessage(vector: .log, title: "Tasso Occupazione", body: .custom("Rappresenta la percentuale di notti vendute sull'intero periodo considerato")))
                        }
                }
   
            }
            //.fontWeight(.semibold)
            .font(firstLineFont)
            .foregroundStyle(firstLineColor)

        
        
    } // chiusa body
       
}
