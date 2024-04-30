//
//  HOOperationsList.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView

struct HOOperationsList: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    let backgroundColorView: Color
    
    var body: some View {
        
        NavigationStack(path: $viewModel.operationsPath) {
            
            CSZStackVB(title: "Operations", backgroundColorView: backgroundColorView) {
                
                VStack {
                    
                    ScrollView {
                        
                        Text("operations")
                    }
                    
                    
                }
                
                
            }
            
        }
    }
}

#Preview {
    HOOperationsList(backgroundColorView: Color.green)
}
