//
//  HOOperationsList.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView
import MyFilterPack

struct HOOperationsList: View {
    
    @EnvironmentObject var viewModel:HOViewModel
   
    @State private var mapTree:MapTree<HOOperationUnit,Test>?
    @State private var filterCore:CoreFilter<HOOperationUnit> = CoreFilter()
    
    var body: some View {
        
        NavigationStack(path: $viewModel.operationsPath) {
            
            let container:[HOOperationUnit] = {
               
                guard let _ = self.viewModel.db.currentWorkSpace else { return [] }
                
                return self.viewModel.ricercaFiltra(containerPath: \.db.currentWorkSpace!.wsOperations.all, coreFilter: filterCore)
                
            }()
            
            let generalDisable:Bool = {
                return container.isEmpty
            }()
            
            FiltrableContainerView(
                backgroundColorView: Color.hoBackGround,
                title: "All Operations \(container.count)",
                filterCore: $filterCore,
                placeHolderBarraRicerca: "Cerca per...",
                buttonColor: Color.hoAccent,
                elementContainer: container,
                mapTree: mapTree,
                generalDisable: generalDisable,
                onChangeValue: self.viewModel.resetScroll) { proxy in
                    if self.viewModel.currentPathSelection == .operations {
                        withAnimation {
                            proxy.scrollTo(1, anchor: .top)
                        }
                    }
                } mapButtonAction: {
                    //
                } trailingView: {
                    vbTrailing()
                } filterView: {
                    vbFilterView(container: container)
                } sorterView: {
                    vbSorterView()
                } elementView: { operation in
                    
                    VStack(alignment:.leading) {
                        
                        Text(operation.writingLabel.uppercased())
                            .bold()
                        Text(operation.regolamento,format: .dateTime)
                        
                        if let writing = operation.writing {
                            
                            
                            Text("area: \(writing.operationArea?.rawValue ?? "no area")")
                            Text("type: \(writing.type?.rawValue ?? "no type")")
                            Text("dare: \(writing.dare ?? "no dare")")
                            Text("avere: \(writing.avere ?? "no avere")")
                            
                            if let oggetto = writing.oggetto {
                                Text("categoria: \(oggetto.category ?? "no cat in")")
                                Text("subCat: \(oggetto.subCategory ?? "no sub in")")
                                Text("specification: \(oggetto.specification ?? "noSpecs")")
                                
                                
                            } else {
                                
                                Text("no oggetto in")
                            }
                            
                            
                        } else {
                            
                            Text("no writing in")
                        }
                        
                        if let amount = operation.amount {
                            
                            Text("q:\(amount.quantityStringValue ?? "no q")\n\(amount.pricePerUnitStringValue ?? "no pmc")")
                        } else {
                            
                            Text("no amount in")
                        }
                        
                       
                        if let note = operation.note {
                            
                            Text(note)
                            
                        } else { Text("no note in")}
                       
                        Text("-----------")
                        
                        if let time = operation.timeImputation {
                            
                            Text("startYY: \(time.startYY ?? 1000)")
                            Text("yearsOfImput: \(time.yyImputation ?? [1000,1001])")
                            
                            if let monthImputation = time.monthImputation {
                                
                                if let startMM = monthImputation.mmStart {
                                    
                                    Text("startMM: \(startMM )")
                                } else { Text("startMM is Nil")}
                                
                                if let advancingMM = monthImputation.mmAdvancing {
                                    Text("advancingMM: \(advancingMM)")
                                } else { Text("advancin is nil ")}
                                
                            } else {
                                Text("no month imputation")
                            }
                            
                            
                        } else {
                            Text("time imputation is nil")
                        }
                        
                        
                        Divider()
                    }
         

                } onRefreshAction: {
                    //
                }
                .navigationDestination(for: HODestinationView.self, destination: { destination in
                    destination.destinationAdress(destinationPath: .operations, readOnlyViewModel: viewModel)
                })
            
            
            
            
        } // chiusa navStack
    }// chiusa body
    
    @ViewBuilder private func vbTrailing() -> some View {
        
        Button {
            self.viewModel.addToThePath(
                destinationPath: .operations,
                destinationView: .operation(HOOperationUnit()))
        } label: {
            HStack {
                Text("Add New")
                Image(systemName: "circle")
                   
                
            }
            .foregroundStyle(Color.hoAccent)
        }
    
    }
    
    @ViewBuilder private func vbFilterView(container:[HOOperationUnit]) -> some View {
        
        Text("Filtri")
       /* MyFilterRow(
            allCases: ProductAdress.allCases,
            filterCollection: $filterCore.filterProperties.percorsoPRP,
            selectionColor: Color.white.opacity(0.5),
            imageOrEmoji: "fork.knife",
            label: "Tipologia") { value in
                container.filter({$0.adress == value}).count
            }*/
        
    }
    
    @ViewBuilder private func vbSorterView() -> some View {
        
        MySortRow(
            sortCondition: $filterCore.sortConditions,
            localSortCondition: .regolamento,
            coloreScelta: Color.yellow)
        
     
    }


}

#Preview {
    NavigationStack {
        
        HOOperationsList()
            .environmentObject(testViewModel)
    }
}
