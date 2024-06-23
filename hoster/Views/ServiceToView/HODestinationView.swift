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
            
        }
        
    }
}
