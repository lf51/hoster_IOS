//
//  TEST.swift
//  hoster
//
//  Created by Calogero Friscia on 24/05/24.
//

import SwiftUI
import MyPackView

struct HONewOperationMainModule: View {
    
    @EnvironmentObject var viewModel: HOViewModel
    
    @StateObject var builderVM:HONewOperationBuilderVM
    
    @State private var generalErrorCheck: Bool = true
    @FocusState private var modelField:HOOperationUnit.FocusField?
    
    let destinationPath: HODestinationPath
    
    init(operation: HOOperationUnit, destinationPath: HODestinationPath) {
     
        let builder = HONewOperationBuilderVM(operation: operation)
        _builderVM = StateObject(wrappedValue: builder)
        
        self.destinationPath = destinationPath
    }
    
    var body: some View {
        
        CSZStackVB(
            title: "self.operation.writingLabel.capitalized",
            backgroundColorView: Color.hoBackGround) {
                
                VStack(alignment:.leading) {
                    
                 CSDivider()
                    
                    ScrollView {
                        
                        VStack(alignment:.leading,spacing:10) {
                            
                            HORegolamentoLineView(operation: $builderVM.operation)
                            
                            HOWritingAccountLineView(
                                operation: $builderVM.operation,
                                mainViewModel: viewModel)
                            
                            if builderVM.operation.writing != nil {
                               
                                
                                HOAmountLineView(builderVM: builderVM)
                                
                                            
                                HOTimeImputationLineView(builderVM: builderVM)
                                    
                                
                              //  HOTimeAmountBuilderView(operation: $operation)
                                //    .id(operation.regolamento) // valutare se tenerlo o meno (id)
                                
                                
                            }
                            
                           /* if let ws = viewModel.db.currentWorkSpace {
                                
                                Text("wsOperationIn:\(ws.wsOperations.all.count)")
                                
                                
                            } else {
                                
                                Text("NoWorkSpace")
                                
                            }*/
                            
                            
 
                        } // chiusa vstack interno
                        
                    } // chiusa Scroll
                    .scrollIndicators(.never)
                    .scrollDismissesKeyboard(.immediately)
                } // chiusa VStack Madre
                .padding(.horizontal,10)
            } // chiusa zStack
            .onAppear {
                
                
            }
        
    } // chiusa body
    
    // TEST
    func addNew() {
        /// TEST TEST TEST da verificare tutto il processo di pubblicazione
        let newOpt = HOOperationUnit()
    
        self.viewModel.publishData(from: newOpt, syncroDataPath: \.workSpaceOperations)
        
    }
    
}

#Preview {
    NavigationStack {
        
        let operation:HOOperationUnit = {
           
            var opt = HOOperationUnit()
         opt.writing = HOWritingAccount(
                type: .acquisto,
                dare: nil,
                avere: "AA04",
                oggetto: HOWritingObject(category: .veicoli, subCategory: .autovettura, specification: "Fiat 500 lounge 1.2"))
            return opt
        }()
        
        HONewOperationMainModule(operation: operation, destinationPath: .operations)
            .environmentObject(testViewModel)
            .tint(Color.hoAccent)
    }
}




