//
//  MainTabView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
    private let backgroundColorView: Color = Color.seaTurtle_1
    
    var body: some View {
        
        TabView(selection: $viewModel.currentPathSelection.csOnUpdate({ old, newValue in
            
            if old == newValue {
                self.viewModel.refreshPathAndScroll()
                }
            }),content:  {
            
                
                Group {
                    
                    HOHomeView(backgroundColorView: backgroundColorView)
                        .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }.tag(HODestinationPath.home)
                    
                    HOReservationsList(backgroundColorView: backgroundColorView)
                        .tabItem { 
                            Image(systemName: "menucard")
                            Text("Books")
                        }.tag(HODestinationPath.reservations)
                    
                    HOOperationsList(backgroundColorView: backgroundColorView)
                        .tabItem {
                            Image(systemName: "leaf")
                            Text("+/-")
                        }.tag(HODestinationPath.operations)
                    
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color.yellow, for: .tabBar)
                
            
                
        })
        .accentColor(.seaTurtle_2)
        
    }
}

#Preview {
    MainTabView()
}
