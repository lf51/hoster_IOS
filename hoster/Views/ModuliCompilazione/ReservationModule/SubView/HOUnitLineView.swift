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
    
    @ObservedObject var builderVM:HONewReservationBuilderVM
    let generalErrorCheck:Bool
    //@Binding var unit:HOUnitModel?
    
    var choiceDone:Bool { self.builderVM.unitOnFocus != nil }

    var body: some View {
        
        HStack {
 
            let label = viewModel.db.currentWorkSpace?.wsLabel ?? "ws corrotto"
            
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.hoDefaultText)
            Spacer()
            
            if let subs = viewModel.getSubs() {
                
                Picker(selection: $builderVM.unitOnFocus) {
                    
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

            } else {
                
                Text("entire unit")
                    .italic()
                    .font(.subheadline)
                    .foregroundStyle(Color.hoDefaultText)

            }

        }
        .csWarningModifier(
            warningColor: Color.hoWarning,
            overlayAlign: .topTrailing,
            padding: (.trailing,10),
          //  offset: (0,-10),
            isPresented: generalErrorCheck) {
              
             builderVM.checkUnitValidation()
        }
        .onAppear(perform: {
            builderVM.initUnitOnFocus(vm: viewModel)
        })
        
    } // body close
    
}
