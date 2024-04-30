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
    
}

extension HODestinationView {
    
    @ViewBuilder func destinationAdress(backgroundColorView: Color, destinationPath: HODestinationPath, readOnlyViewModel:HOViewModel) -> some View {
        
        switch self {
        case .reservation(let book):
            
            HONewReservationMainModule(
                newModule: book,
                backgroundColorView: backgroundColorView,
                destinationPath: destinationPath)
            
        }
        
    }
}
