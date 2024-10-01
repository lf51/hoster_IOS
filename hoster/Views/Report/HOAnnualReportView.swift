//
//  HOAnnualReportView.swift
//  hoster
//
//  Created by Calogero Friscia on 25/09/24.
//

import SwiftUI
import MyPackView

struct HOAnnualReportView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let focusUnit:String? // decidere se svilupparlo per sub o per struttura
    
    var body: some View {
      
        CSZStackVB(
            title: "Quadro Annuale",
            backgroundColorView: Color.hoBackGround) {
                
                VStack {
                    
                    HOResumeLineView(
                        mmOrdinale: nil,
                        focusUnit: nil,
                        firstLineFont: .headline,
                        amountFont: (.largeTitle,.title3),
                        subTextFont: .subheadline)
                         .padding(.horizontal,10)
                         .padding(.vertical,5)
                    
                    
                    ScrollView {
                        
                        if let subs = self.viewModel.getSubs() {

                                HOGrossUnitDataView(subs: subs)
                            

                        }
                      
                        
                        
                        
                        
                        
                    }// chiusa Scroll
                    .scrollIndicators(.never)

                }// chiusa VStack Madre
                .padding(.horizontal,10)
                
                
            }// chiusa ZStackFramed
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    vbCurrentYearView(viewModel: self.viewModel)

                }
            }
        
    }
}

#Preview {
    NavigationStack {
        
        HOAnnualReportView(focusUnit: nil)
            .environmentObject(testViewModel)
    }
}



