//
//  ContentView.swift
//  hoster
//
//  Created by Calogero Friscia on 28/02/24.
//

import SwiftUI
import Firebase
import MyPackView

struct ContentView: View {
    
    @StateObject private var authManager: HOAuthManager = HOAuthManager()
    let mainBackgroundColor:Color = Color.yellow.opacity(0.9)
    
    var body: some View {

        switchAuthCase()
            .csModifier(self.authManager.isLoading ?? false, transform: { view in
                view.overlay {
                    WaitLoadingView(backgroundColorView: Color.yellow, image: "house.circle", imageColor: Color.white)
                }
            })
            .csAlertModifier(isPresented: $authManager.showAlert, item: authManager.alertItem)
           
    }
    
    // Method
    
   @ViewBuilder private func switchAuthCase() -> some View {
        
       if let authData = authManager.authData {
           // abbiamo eliminato il caso e duplicato il dato per essere sicuro e non doverlo swrappare
           MainView(
            authData:authData,
            authManager: self.authManager,
            backgroundColor: mainBackgroundColor)
           
       } else {
           
           SignInView(
            authManager: self.authManager,
            backgroundColorView: mainBackgroundColor)
       }

    }
}

/*#Preview {
    ContentView()
}*/
