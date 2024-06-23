//
//  HOUnitLineView.swift
//  hoster
//
//  Created by Calogero Friscia on 04/05/24.
//

import Foundation
import SwiftUI
import MyPackView

struct HOUnitLineView:View {
    
    @EnvironmentObject var viewModel:HOViewModel
    @Binding var unit:HOUnitModel?
    
    var choiceDone:Bool { self.unit != nil }

    var body: some View {
        
        HStack {
 
            Picker(selection: $unit) {
                let subs = self.viewModel.getSubs()
                
                Text("select unit:")
                    .tag(nil as HOUnitModel?)
                  
                ForEach(subs,id:\.self) { sub in
            
                    Text(sub.label)
                        .tag(sub as HOUnitModel?)
                       
                }
                
            } label: {
                Text("")
            }
            .csModifier(choiceDone, transform: { view in
                view.menuIndicator(.hidden)
                    
            })
            .tint(choiceDone ? Color.hoDefaultText : Color.hoAccent)
            .background {
                    RoundedRectangle(cornerRadius: 5.0)
                    .foregroundStyle(Color.hoBackGround)
                        .opacity(0.1)
                        .shadow(radius: 5)
                        
                }
        }
        
    } // body close
    
}
