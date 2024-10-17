//
//  MainView.swift
//  hoster
//
//  Created by Calogero Friscia on 06/03/24.
//

import SwiftUI
import MyPackView

struct MainView: View {
    
    @StateObject private var viewModel:HOViewModel
    @ObservedObject var authManager: HOAuthManager
    let backgroundColor:Color
    
    init(authData:HOAuthData,authManager:HOAuthManager,backgroundColor:Color) {
        
        let vm = HOViewModel(authData: authData)
        _viewModel = StateObject(wrappedValue: vm)
        self.authManager = authManager
        self.backgroundColor = backgroundColor
        
    }
    
    var body: some View {
        
       switchView()
            .environmentObject(viewModel)
            .csModifier(self.viewModel.mainLoadingCase != nil, transform: { view in
                vbOverlayLoadingView(trasform: view)
            })
            .csAlertModifier(isPresented: self.$viewModel.showAlert, item: self.viewModel.alertMessage)
            .csLogMessage($viewModel.logMessage)
            .csPopMessage($viewModel.popMessage)
    }
    
    // ViewBuilder
    
    @ViewBuilder private func vbOverlayLoadingView<Content:View>(trasform currentView:Content) -> some View {
    
        switch self.viewModel.mainLoadingCase {
            
        case .inFullScreen:
            currentView
                .overlay {
                    WaitLoadingView(backgroundColorView: Color.hoBackGround.opacity(0.4), image: "house.circle", imageColor: Color.white, loadingInfo:  {
                        
                            ForEach(self.viewModel.loadStatus,id:\.uid) { load in
                                
                                Text(load.loadDescription ?? "")
                                
                                
                            }
                    })
                }
        case .inBackground:
            currentView
                .overlay(alignment:.topLeading) {
                    
                    HStack(spacing:10) {
                        
                        ProgressView()
                            .imageScale(.small)
                        Text("loading..")
                            .italic()
                            .fontWeight(.light)
                            
                       // Spacer()
                    }
                    .padding(.trailing)
                    .padding(.leading,2)
                    .background {
                        
                        RoundedRectangle(cornerRadius: 5.0)
                            .fill(Color.hoAccent)
                            
                    }
                    .padding(.leading,10)
                    .onTapGesture {
                        self.viewModel.sendSystemMessage(message: HOSystemMessage(vector: .pop, title: "Loading Log", body: .custom("Da compilare con i messaggi dei vari loadingStatus")))
                    }
                }
            
        default: EmptyView()
        }

    }
    
    @ViewBuilder private func switchView() -> some View {
        
        switch self.viewModel.viewCase {
        case .main:
            MainTabView()
        case .setWorkSpace:
            HOViewSetWorkSpace(
                authManager: self.authManager,
                backgroundColor: backgroundColor)
        }        
    }
    
}

/*
#Preview {
    MainView(authManager: AuthManager())
}*/
