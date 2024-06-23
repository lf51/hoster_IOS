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
                    
                    Text(operation.uid)
         

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
