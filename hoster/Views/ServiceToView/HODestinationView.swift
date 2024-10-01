//
//  HODestinationView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import Foundation
import SwiftUI

enum HODestinationView:Hashable {
    
    case reservation(_ book:HOReservation)
    case operation(_ opt:HOOperationUnit)
    
    case setupWsData
    case reportAnnuale(_ subRef:String?)
    
}

extension HODestinationView {
    
    @ViewBuilder func destinationAdress(destinationPath: HODestinationPath, readOnlyViewModel:HOViewModel) -> some View {
        
        switch self {
        case .reservation(let book):
            
            HONewReservationMainModule(
                reservation: book,
                destinationPath: destinationPath)
            
        case .operation(let opt):
            
            HONewOperationMainModule(
                operation: opt,
                destinationPath: destinationPath)
            
        case .setupWsData:
            
            Text("setup workspace data")
            
        case .reportAnnuale(let sub):
            
            HOAnnualReportView(focusUnit: sub)
            
        }
        
    }
}
