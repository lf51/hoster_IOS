//
//  HOReservationRowView.swift
//  hoster
//
//  Created by Calogero Friscia on 29/07/24.
//

import SwiftUI
import MyPackView

struct HOReservationRowView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    let reservation:HOReservation
    
    var body: some View {
        
        CSZStackVB_Framed() {
            
            VStack {
                
                vbFirstLine()
                
                Button(action: {
                    
                    let valuePath:[String:Any] = ["schedule_cache":0]
                    
                    self.viewModel.publishSingleField(from: reservation, syncroDataPath: \.workSpaceReservations, valuePath: valuePath)
                    
                   /* self.viewModel.dbManager.setSingleField(from: HOSingleValuePublishig(docReference: <#T##DocumentReference?#>, path: <#T##[String : Any]#>))*/
                    
                    
                    
                    
                }, label: {
                    Text("noshow")
                })
                
                
                
                
                
            } // chiusa vstack madre
            .padding(.horizontal,10)
        }// chiusa framed
        
    } // chiusa body
    
    @ViewBuilder private func vbFirstLine() -> some View {
        
        HStack {
            
            Text(self.reservation.guestName ?? "no guest")
                .font(.title)
                .foregroundStyle(Color.black)
            
            Spacer()
            
            if let scheduleCache = reservation.statoSchedule {
                
                Text(scheduleCache.getStringValue())
            }
            
        }
        
    }
}


