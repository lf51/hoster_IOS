//
//  HOHomeView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView

struct HOHomeView: View {
    
    @EnvironmentObject var viewModel:HOViewModel
    let backgroundColorView: Color
    
    var body: some View {
        
        NavigationStack(path: $viewModel.homePath) {
            
            CSZStackVB(title: "Home", backgroundColorView: backgroundColorView) {
                VStack {
                    
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

                }
            }
        }
        
        
         
    }
}

#Preview {
    HOHomeView(backgroundColorView: Color.red)
}
