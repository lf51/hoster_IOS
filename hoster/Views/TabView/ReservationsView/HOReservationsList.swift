//
//  HOReservationsView.swift
//  hoster
//
//  Created by Calogero Friscia on 30/04/24.
//

import SwiftUI
import MyPackView
import MyFilterPack
/*
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
*/
struct HOReservationsList: View {
    
    @EnvironmentObject var viewModel:HOViewModel

    @State private var mapTree:MapTree<HOReservation,HOReservationSchedule>?
    @State private var filterCore:CoreFilter<HOReservation> = CoreFilter()
    
    var body: some View {
      
        NavigationStack(path: $viewModel.reservationsPath) {
            
            let container:[HOReservation] = {
               
                guard let _ = self.viewModel.db.currentWorkSpace else { return [] }
                
                return self.viewModel.ricercaFiltra(containerPath: \.db.currentWorkSpace!.wsReservations.all, coreFilter: filterCore)
            }()
            
            let generalDisable:Bool = {
                
                let condition_1 = container.isEmpty
                let condition_2 = self.filterCore.countChange == 0
                let condition_3 = self.filterCore.stringaRicerca == ""
                
                return condition_1 && condition_2 && condition_3
            }()
            
        FiltrableContainerView(
            backgroundColorView: Color.hoBackGround,
            title: "All Books (\(container.count))",
            filterCore: $filterCore,
            placeHolderBarraRicerca: "Cerca per nome guest",
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
                mapButtonAction()
            } trailingView: {
                vbTrailing()
            } filterView: {
                vbFilterView(container: container)
            } sorterView: {
                vbSorterView()
            } elementView: { reservation in
                
                HOReservationRowView(
                    reservation: reservation)

            } onRefreshAction: {
                //
            }
            .navigationDestination(for: HODestinationView.self, destination: { destination in
                destination.destinationAdress(destinationPath: .reservations, readOnlyViewModel: viewModel)
            })

        }
        
    }
    
    private func mapButtonAction() {
        
        if mapTree == nil {
 
            let allCases = HOReservationSchedule.allCases.sorted(by: {$0.orderAndStorageValue() < $1.orderAndStorageValue() })
            
            self.mapTree = MapTree(
                mapProperties: allCases,
                kpPropertyInObject: \.scheduleStatus.id,
                labelColor: Color.scooter_p53,
                labelOpacity: 0.3)
            
            
        } else {
            
            self.mapTree = nil
        }
    }
    
    // ViewBuilder
    
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
                    destinationPath: .reservations,
                    destinationView: .reservation(HOReservation()))
            } label: {
                
                HStack {
                    Image(systemName: "doc.badge.plus")
                        .imageScale(.large)
                }
                .foregroundStyle(Color.hoAccent)
            }
        }
        
    }
    
    @ViewBuilder private func vbFilterView(container:[HOReservation]) -> some View {
  
        if let sub = self.viewModel.getSubs() {
            
            MyFilterRow(
                allCases: sub,
                filterProperty: $filterCore.filterProperties.unitModel,
                selectionColor: Color.blue.opacity(0.5),
                imageOrEmoji: "house",
                label: "Alloggio") { value in
                        
                    container.filter({$0.refUnit == value.uid}).count
                }
            
        }
        
        let ota = self.viewModel.getOTAChannels()
        
        MyFilterRow(
            allCases: ota,
            filterProperty: $filterCore.filterProperties.portale,
            selectionColor: Color.white.opacity(0.5),
            imageOrEmoji: "storefront",
            label: "OTA") { value in
                    
                container.filter({$0.labelPortale == value.label}).count
            }
       
        MyFilterRow(
            allCases: HOReservationPayamentStatus.allCases,
            filterProperty: $filterCore.filterProperties.statoPagamento,
            selectionColor: Color.white.opacity(0.5),
            imageOrEmoji: "dollarsign",
            label: "Regolamento") { value in
                    
                container.filter({$0.statoPagamento == value}).count
            }
            
        MyFilterRow(
            allCases: HOGuestType.allCases,
            filterProperty: $filterCore.filterProperties.guestType,
            selectionColor: Color.yellow.opacity(0.5),
            imageOrEmoji: "person",
            label: "Tipo Ospite") { value in
                
                container.filter({$0.guestType == value}).count
            }
        
        MyFilterRow(
            allCases: HOMonthObject.allCases,
            filterProperty: $filterCore.filterProperties.monthIn,
            selectionColor: Color.orange.opacity(0.5),
            imageOrEmoji: "calendar.badge.clock.rtl",
            label: "Mese Check-In") { value in
                
                container.filter({$0.monthIn == value}).count
            }
    }
    
    @ViewBuilder private func vbSorterView() -> some View {
        
        MySortRow(
            sortCondition: $filterCore.sortConditions,
            localSortCondition: .schedule,
            coloreScelta: Color.orange)
       // .disabled(true)
        
    }
}

#Preview {
    HOReservationsList()
        .environmentObject(testViewModel)
}
