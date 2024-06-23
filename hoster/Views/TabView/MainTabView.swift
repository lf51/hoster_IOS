//
//  MainTabView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView

struct MainTabView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    
   // private let backgroundColorView: Color = Color.hoBackGround
    
    var body: some View {
        
        TabView(selection: $viewModel.currentPathSelection.csOnUpdate({ old, newValue in
            
            if old == newValue {
                self.viewModel.refreshPathAndScroll()
                }
            }),content:  {
            
                Group {
                    
                    HOHomeView()
                        .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }.tag(HODestinationPath.home)
                    
                    HOReservationsList()
                        .tabItem { 
                            Image(systemName: "menucard")
                            Text("Books")
                        }.tag(HODestinationPath.reservations)
                    
                    HOOperationsList()
                        .tabItem {
                            Image(systemName: "leaf")
                            Text("+/-")
                        }.tag(HODestinationPath.operations)
                    
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color.blueWood_p47, for: .tabBar)
                
        })
        .accentColor(Color.hoAccent)
        .csNavigationTitleColor(Color.hoNavTitle)
        //.csAlertModifier(isPresented: $viewModel.showAlert, item: viewModel.alertMessage)
        
    }
}

#Preview {
    MainTabView()
}
