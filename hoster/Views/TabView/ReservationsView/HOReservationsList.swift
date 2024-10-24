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
            
           /* Button("DELETE") {
                
                let reserv = self.viewModel.db.currentWorkSpace?.wsReservations.all
                
                guard let reserv else { return }
                print("RESERVATION UPDATE: \(reserv.count)")
                let fields = ["check_out","data_arrivo"]
                
                for eachR in reserv {
                    self.viewModel.deleteSingleField(from: eachR, syncroDataPath: \.workSpaceReservations, fields: fields)
                }
                
                
                
            }*/
            
            
            
           /* Button("UPDATE") {
                
                let reserv = self.viewModel.db.currentWorkSpace?.wsReservations.all/*.first(where: {$0.uid == "039C92EA-4C44-4AA3-99BB-D81D01FD9719"})*/
                print("[UPDATE]_Reservation COUNT \(reserv?.count ?? 0)")
                guard let reserv else { return }
                
                let key = "imputation_period"
                
                for eachReser in reserv {
                    
                    guard let value = eachReser.imputationPeriod else { return }
                    
                    guard let updatePeriod = value.updateSelf() else { return }
                    
                    
                    let path:[String:Any] = [key:["start":updatePeriod.start,"end":updatePeriod.end]]
                    
                    guard let optAss = self.viewModel.getOperation(from: eachReser.refOperations ?? []) else { return }
                    
                    self.viewModel.publishSingleField(from: eachReser, syncroDataPath: \.workSpaceReservations, valuePath: path)
                    
                    for opt in optAss {
                        
                        self.viewModel.publishSingleField(from: opt, syncroDataPath: \.workSpaceOperations, valuePath: path)
                                            
                        
                    }

                }

            }*/
            
            
            
            
            vbCurrentYearView(viewModel: self.viewModel)

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
        
        MySortRow(
            sortCondition: $filterCore.sortConditions,
            localSortCondition: .dataArrivoCrescente,
            coloreScelta: Color.yellow)
        
        MySortRow(
            sortCondition: $filterCore.sortConditions,
            localSortCondition: .dataArrivoDecrescente,
            coloreScelta: Color.blue)
       // .disabled(true)
        
    }
}

#Preview {
    HOReservationsList()
        .environmentObject(testViewModel)
}
