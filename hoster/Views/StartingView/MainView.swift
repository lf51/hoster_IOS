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
                    WaitLoadingView(backgroundColorView: Color.pink, image: "house.circle", imageColor: Color.white, loadingInfo:  {
                        
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
                        Color.gray
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            
                    }
                    
                    
                }
            
        default: EmptyView()
        }

    }
    
    @ViewBuilder private func switchView() -> some View {
        
        switch self.viewModel.viewCase {
        case .main:
            MainTabView()
            
           /* VStack {
                
                let user = self.viewModel.db.currentUser
                let ws = self.viewModel.db.currentWorkSpace
                
                Text("authData uuid: \(self.viewModel.authData.uid)")
                Text("authData email: \(self.viewModel.authData.email ?? "noMail")")
                
                Text("userData id: \(user.uid)")
                Text("user focus WorkSpace id: \(user.wsFocusUnitRef ?? "noFocus")")
                
                Text("workSpace Label: \(ws?.wsLabel ?? "no Label")")
                    .font(.largeTitle)
                
                Text("workSpace uuid: \(ws?.uid ?? "no uuid")")
                Text("workSpaceData uuid: \(ws?.wsData.uid ?? "no uuid")")
                Text("workSpaceUnit uuid: \(ws?.wsUnit.uid ?? "no uuid")")
                
                Text("workspace type: \(ws?.wsType.rawValue() ?? "no Type")")
                
                Text("workspace whole name: \(ws?.wsLabel ?? "no label")")
                
                Text("all_Unit: \(ws?.wsUnit.all.count ?? 0)")
                Text("MainUnitName: \(ws?.wsUnit.main.label ?? "no name") ")
                
                Text("subsIn:\(ws?.wsUnit.subs?.count ?? 0)")
                
                ForEach(ws?.wsUnit.all ?? [],id:\.self) { unit in
                    
                    VStack {
                        Text("\(unit.label)")
                            .font(.title)
                            .bold()
                        Text("type:\(unit.unitType.rawValue)")
                        Text("pax: \(unit.pax ?? 999)")
                    }
                    
                }
                
                Button(action: {
                    self.viewModel.db.currentWorkSpace = nil
                   
                }, label: {
                    Text("Erase WorkSpace")
                }) // per test
 
            } */
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
