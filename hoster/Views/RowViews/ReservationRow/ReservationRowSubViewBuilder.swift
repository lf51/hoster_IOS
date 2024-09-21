//
//  ReservationRowSubViewBuilder.swift
//  hoster
//
//  Created by Calogero Friscia on 10/08/24.
//

import SwiftUI
import MyPackView

@ViewBuilder func vbVisualSchedule(reservation:HOReservation,viewModel:HOViewModel) -> some View {
   
    let visualData = reservation.visualScheduleDescription()
    
    let image = visualData.internalImage
    let color = visualData.internalColor
    let dashedColor = visualData.externalColor
    let description = visualData.description

    csCircleDashed(
        internalCircle: image,
        internalColor: color,
        dashedColor: dashedColor)
    .onTapGesture {
        
        viewModel.sendAlertMessage(alert: AlertModel(
            title: "\(reservation.labelModCompile)",
            message: description))
        
    }
 
}

func csCircleDashed(internalCircle:String = "circle.fill",internalColor:Color,dashedColor:Color) -> some View {
    
    ZStack {
        
        Image(systemName: internalCircle)
            .imageScale(.small)
            .foregroundStyle(internalColor)
            .zIndex(0)
        
        Image(systemName: "circle.dashed")
            .bold()
            .imageScale(.large)
            .foregroundStyle(dashedColor)
            .zIndex(1)
        
    }
}
