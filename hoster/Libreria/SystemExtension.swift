//
//  systemExtension.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import Foundation
import SwiftUI

extension CGFloat {
    
    static let vStackLabelBodySpacing:CGFloat = 5
    static let vStackBoxSpacing:CGFloat = 10
    
}

extension View {
    
    func csLogMessage(_ message:Binding<HOSystemMessage?>) -> some View {
        
        modifier(HOLogMessageModifier(message: message))
        
    }
    
    func csPopMessage(_ message:Binding<HOSystemMessage?>) -> some View {
        
        modifier(HOPopMessageModifier(message: message))
        
    }
    /// mostra un lucchetto. Il disabilita è opzionale.
    func csLock(_ color:Color,_ alignment:Alignment,_ padding:Edge.Set,_ lockCondition:Bool,_ enableDisable:Bool = false) -> some View {
        
        modifier(HOLockModifier(lockColor: color, overlayAlign: alignment, padding: padding,lockCondition: lockCondition,enableDisable: enableDisable))
        
    }
    

}

extension View {
    func csNavigationTitleColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}

extension String {
    
    func csCapitalizeFirst() -> String {
        
        var allWords = self.components(separatedBy: " ")
        
        guard allWords.count > 1 else { return self.capitalized}
        
        let first = allWords.removeFirst().capitalized
        allWords.insert(first, at: 0)

        return allWords.joined(separator: " ")
    }
    
}
