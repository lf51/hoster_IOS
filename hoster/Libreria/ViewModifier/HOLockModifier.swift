//
//  HOLockModifier.swift
//  hoster
//
//  Created by Calogero Friscia on 31/05/24.
//

import Foundation
import SwiftUI

struct HOLockModifier: ViewModifier {

    let lockColor:Color
    let overlayAlign:Alignment
    let padding:Edge.Set
    let lockCondition:Bool
    let enableDisable:Bool
   
    func body(content: Content) -> some View {
       
           content
            .disabled(enableDisable ? lockCondition : false)
            .overlay(alignment: overlayAlign) {
                if lockCondition {
                    
                    Image(systemName: "exclamationmark.lock.fill")
                        .foregroundStyle(lockColor)
                        .padding(padding)
                }
            }
   
           
   }
}
