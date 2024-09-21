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
   
    @State private var mapTree:MapTree<HOOperationUnit,HOAreaAccount>?
    @State private var filterCore:CoreFilter<HOOperationUnit> = CoreFilter()
    
    var body: some View {
        
        NavigationStack(path: $viewModel.operationsPath) {
            
            let container:[HOOperationUnit] = {
               
                guard let _ = self.viewModel.db.currentWorkSpace else { return [] }
                
                return self.viewModel.ricercaFiltra(containerPath: \.db.currentWorkSpace!.wsOperations.all, coreFilter: filterCore)
                
            }()
            
            let generalDisable:Bool = {
                
                let condition_1 = container.isEmpty
                let condition_2 = self.filterCore.countChange == 0
                let condition_3 = self.filterCore.stringaRicerca == ""
                
                return condition_1 && condition_2 && condition_3
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
                   // mapButtonAction()
                    // 13.09.24 disabilitato poichè lo scroll sfarfallia. Comunque per le operazioni non è così necessario. Valutare modifiche al pack
                    
                } trailingView: {
                    vbTrailing()
                } filterView: {
                    vbFilterView(container: container)
                } sorterView: {
                    vbSorterView()
                } elementView: { operation in
                    
                    HOOperationRowView(operation: operation)
         

                } onRefreshAction: {
                    //
                }
                .navigationDestination(for: HODestinationView.self, destination: { destination in
                    destination.destinationAdress(destinationPath: .operations, readOnlyViewModel: viewModel)
                })
            
            
            
            
        } // chiusa navStack
    }// chiusa body
    
   /* private func mapButtonAction() {
        
        if mapTree == nil {
 
            let allCases = HOAreaAccount.allCases.sorted(by: {$0.orderAndStorageValue() < $1.orderAndStorageValue() })
            
            self.mapTree = MapTree(
                mapProperties: allCases,
                kpPropertyInObject: \.operationArea.id,
                labelColor: Color.scooter_p53,
                labelOpacity: 0.3)
            
            
        } else {
            
            self.mapTree = nil
        }
    }*/
    
    @ViewBuilder private func vbTrailing() -> some View {
        
       /* let currentYY = self.viewModel.yyFetchData ?? self.viewModel.currentYY*/
        
        HStack {
            
            HStack(spacing:5) {
                
                Image(systemName: "calendar")
                Text("\(self.viewModel.yyFetchData.description)")
                 
                }
                .font(.subheadline)
                .foregroundStyle(Color.hoDefaultText)
                .opacity(0.6)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5.0)
                        .fill(Color.hoBackGround.opacity(0.4))
                }

            
            
            Button {
                self.viewModel.addToThePath(
                    destinationPath: .operations,
                    destinationView: .operation(HOOperationUnit()))
            } label: {
                
             //   HStack {
                   // Text("Add New")
                   // Image(systemName: "circle")
                       
                    Image(systemName: "doc.badge.plus")
                        .imageScale(.large)
                        .foregroundStyle(Color.hoAccent)
              //  }
               // .foregroundStyle(Color.hoAccent)
            }
            
        }
    
    }
    
    @ViewBuilder private func vbFilterView(container:[HOOperationUnit]) -> some View {
        
        MyFilterRow(
            allCases: HOAreaAccount.allCases,
            filterProperty: $filterCore.filterProperties.area,
            selectionColor: Color.blue.opacity(0.5),
            imageOrEmoji: "storefront",
            label: "Area") { value in
                    
                container.filter({$0.writing?.operationArea == value}).count
            }
        
        MyFilterRow(
            allCases: HOOperationType.allCases,
            filterProperty: $filterCore.filterProperties.tipologia,
            selectionColor: Color.white.opacity(0.5),
            imageOrEmoji: "storefront",
            label: "Tipologia") { value in
                    
                container.filter({$0.writing?.type == value}).count
            }
        
        MyFilterRow(
            allCases: HOImputationAccount.allCases,
            filterProperty: $filterCore.filterProperties.imputazione,
            selectionColor: Color.yellow.opacity(0.5),
            imageOrEmoji: "storefront",
            label: "Conto Imputazione") { value in
                    
                container.filter({$0.writing?.imputationAccount == value}).count
            }
        
        MyFilterRow(
            allCases: HOObjectCategory.allCases,
            filterProperty: $filterCore.filterProperties.categoria,
            selectionColor: Color.cyan.opacity(0.5),
            imageOrEmoji: "storefront",
            label: "Categoria") { value in
                    
                container.filter({$0.writing?.oggetto?.getCategoryCase() == value}).count
            }
        
        MyFilterRow(
            allCases: HOObjectSubCategory.allCases,
            filterProperty: $filterCore.filterProperties.subCategoria,
            selectionColor: Color.orange.opacity(0.5),
            imageOrEmoji: "storefront",
            label: "Sub Categoria") { value in
                    
                container.filter({$0.writing?.oggetto?.getSubCategoryCase() == value}).count
            }
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
