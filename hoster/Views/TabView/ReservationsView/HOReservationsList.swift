//
//  HOReservationsView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView
import MyFilterPack

struct Test:Property_FPC_Mappable {
    var id: String
    
    func imageAssociated() -> String {
        return "circle"
    }
    
    func simpleDescription() -> String {
        return "not yet defined"
    }
    
    func returnTypeCase() -> Test {
        return self
    }
    
    func orderAndStorageValue() -> Int {
        return 0
    }
    
    
}

struct HOReservationsList: View {
    
    @EnvironmentObject var viewModel:HOViewModel
  // let backgroundColorView: Color
    
    @State private var mapTree:MapTree<HOReservation,Test>?
    @State private var filterCore:CoreFilter<HOReservation> = CoreFilter()
    
    var body: some View {
      
        NavigationStack(path: $viewModel.reservationsPath) {
            
            let container:[HOReservation] = {
               
                guard let _ = self.viewModel.db.currentWorkSpace else { return [] }
                
                return self.viewModel.ricercaFiltra(containerPath: \.db.currentWorkSpace!.wsReservations.all, coreFilter: filterCore)
            }()
            
            let generalDisable:Bool = {
                
                let condition_1 = container.isEmpty
              //  let condition_2 = self.filterCore.countChange == 0
              //  let condition_3 = self.filterCore.stringaRicerca == ""
                
              //  return condition_1 && condition_2 && condition_3
                return false 
            }()
            
        FiltrableContainerView(
            backgroundColorView: Color.hoBackGround,
            title: "All Books \(container.count)",
            filterCore: $filterCore,
            placeHolderBarraRicerca: "Cerca per nome guest, o data arrivo",
            buttonColor: Color.hoAccent,
            elementContainer: container,
            mapTree: mapTree,
            generalDisable: generalDisable,
            onChangeValue: self.viewModel.resetScroll) { proxy in
                if self.viewModel.currentPathSelection == .reservations {
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
            } elementView: { reservation in
                
                Text(reservation.guestName ?? "noName")
     
                
                
            } onRefreshAction: {
                //
            }
            .navigationDestination(for: HODestinationView.self, destination: { destination in
                destination.destinationAdress(destinationPath: .reservations, readOnlyViewModel: viewModel)
            })

            
        }
        
        
    }
    
    // ViewBuilder
    
    @ViewBuilder private func vbTrailing() -> some View {
        
        Button {
            self.viewModel.addToThePath(
                destinationPath: .reservations,
                destinationView: .reservation(HOReservation()))
        } label: {
            HStack {
                Text("Add New")
                Image(systemName: "circle")
                   
                
            }
            .foregroundStyle(Color.hoAccent)
        }
        
       /* Menu {
            
           /* NavigationButtonBasic(
                label: "Crea Nuovo",
                systemImage: "square.and.pencil",
                navigationPath: .dishList,
                destination: .piatto(ProductModel()))
            
            NavigationButtonBasic(
                label: "Crea in blocco",
                systemImage: "doc.on.doc",
                navigationPath: .dishList,
                destination: .moduloCreaInBloccoPiattiEIngredienti)*/
   
        } label: {
           /* LargeBar_Text(
                title: "Nuovo Prodotto",
                font: .callout,
                imageBack: .seaTurtle_2,
                imageFore: Color.white) */
        }*/
        
    }
    
    @ViewBuilder private func vbFilterView(container:[HOReservation]) -> some View {
        
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
            localSortCondition: .dataArrivo,
            coloreScelta: Color.yellow)
        
     
    }
}

#Preview {
    HOReservationsList()
}
