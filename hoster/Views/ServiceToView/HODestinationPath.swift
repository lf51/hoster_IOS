//
//  HODestinationPath.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import Foundation
import SwiftUI

enum HODestinationPath:Hashable {
    
    case home
    case reservations
    case operations
    
    func vmPathAssociato() -> ReferenceWritableKeyPath<HOViewModel,NavigationPath> {
        
        switch self {
        case .home:
            return \.homePath
        case .reservations:
            return \.reservationsPath
        case .operations:
            return \.operationsPath

        }
        
        
    }
}
