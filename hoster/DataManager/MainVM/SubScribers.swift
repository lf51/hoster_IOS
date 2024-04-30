//
//  SubScribers.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import Combine
import SwiftUI
import MyPackView

/// subscriber
extension HOViewModel {
    
     func addLoadingSubscriber() {
        
        self.dbManager
            .loadingPublisher
            .sink { _ in
                //
            } receiveValue: { [weak self] isLoading in
                
                guard let self,
                let isLoading else {
                    return
                }

                switch isLoading.log {
                    
                case .active:
                    
                    self.callOnMainQueque {
                        withAnimation {
                            self.loadStatus.append(isLoading)
                        }
                    }
                    
                case .completed:

                    self.callOnMainQueque {
                        
                        withAnimation {
                            self.loadStatus.removeAll(where: {$0.uid == isLoading.uid})
                        }
                    }
                }
                
            }.store(in: &cancellables)

    }
    
     func addUserDataSubscriber()  {
       // 1° Publisher
        self.dbManager
            .userData
            .publisher
           // .last()
            .sink { _ in
   
            } receiveValue: { [weak self] userData in
               print("[START]_addUserManagerSubscriber")
                
                guard let self else {
                    print("[SELF_is_WEAK]_addCurrentUserSubscriber")
                    return
                }
                guard let userData else {
  
                    self.callOnMainQueque {
                        
                        let stringLog = self.authData.email == nil ? "NO Logged in" : "Logged as \(self.authData.email!)"
                        
                        let alert = AlertModel(title: stringLog, message: "Necessario registrare un WorkSpace")
                        self.alertItem = alert
                    }
 
                    return
                }

                do {
                    
                    try self.db.checkUidCoerenceAndUpdate(for: userData)

                    guard let ref = userData.wsFocusUnitRef,
                          !ref.isEmpty else {
                        
                        self.callOnMainQueque {
                            self.db.currentWorkSpace = nil
                        }
                        
                        throw HOCustomError.erroreGenerico(
                            problem: "Focus su WorkSpace Assente",
                            reason: "Possibile mancato salvataggio",
                            solution: "Provare a crearne uno nuovo")
        
                    }
                 
                    // controlliamo se è stato modificato il focus
                    
                    let pastFocus = self.db.currentWorkSpace?.uid
                    
                    if pastFocus != ref {
                        // se differente facciamo il refetch del workspace
                       
                        self.db.currentWorkSpace = WorkSpaceModel(focusUid: ref)
                        
                        try self.dbManager.fetchAndListenWorkSpaceModel(wsFocusUID: ref)
                    } else {
                        
                       // self.setLoading(to: .end)
                    }
 
                } catch let error {
                    
                    self.callOnMainQueque {
                        self.logMessage = error.localizedDescription
                    }

                    return
                }
                
                print("[END]_addUserManagerSubscriber")
                
            }.store(in: &cancellables)

    }
    
     func addWsDataSubscriber() {
        
        self.dbManager
            .workSpaceData
            .publisher
          //  .last()
            .sink { _ in
            
            } receiveValue: { [weak self] workSpaceData in
                print("[START]_addWsDataSubscriber")
                guard let self,
                      let workSpaceData else {
                    
                    self?.callOnMainQueque {
                              self?.logMessage = "[EPIC_FAIL]_Collegamento al database corrotto. Riavviare"
                          }
 
                    return
                }
                
                self.callOnMainQueque {
                    do {
    
                        try self.db.currentWorkSpace?.updateWs(with: workSpaceData, in: \.wsData)
                       // try self.db.currentWorkSpace?.updateWsData(to: workSpaceData)
                        
                    } catch let error {
                       // self.db.currentWorkSpace = nil
                        self.logMessage = "WsDataCorrotto - \(error.localizedDescription)"
                    }
                }
                
                print("[END]_addWsDataSubscriber")
                
            }.store(in: &cancellables)
    }
    
     func addWsUnitSubscriber() {
        
        self.dbManager
            .workSpaceUnits
            .publisher
            .sink { _ in
                
            } receiveValue: { [weak self] docId,allUnit in
                
                print("[START]_addWsUnitSubscriber\n_docId\(docId ?? "noDoc")\n_allUnitCount:\(allUnit?.count ?? 999)")
                
                guard let self,
                      let docId,
                      let allUnit else {
                    
                    self?.callOnMainQueque {
                              self?.logMessage = "[EPIC_FAIL]_Collegamento al database corrotto. Riavviare"
                          }
 
                    return
                }
                
                self.callOnMainQueque {
                    
                    do {
                        
                        print("DocID from collection UnitModel:\(docId)")
                        
                        let newWsUnit = WorkSpaceUnit(focusUid: docId, allUnit: allUnit)
                        try self.db.currentWorkSpace?.updateWs(with: newWsUnit, in: \.wsUnit)
                       // try self.db.currentWorkSpace?.updateWsUnit(to: newWsUnit)
                        print("[END]_addWsUnitSubscriber")
                        
                    } catch let error {
                       // self.db.currentWorkSpace = nil
                        self.logMessage = "WsUnit Corrotto - \(error.localizedDescription)"
                    }
                    
                }
               
            }.store(in: &cancellables)
    }
    
     func addWsBooksSubscriber() {
       
       self.dbManager
           .workSpaceReservations
           .publisher
           .sink { _ in
               
           } receiveValue: { [weak self] docId,allReservations in
               
               print("[START]_addWsBooksSubscriber\n_docId\(docId ?? "noDoc")\n_allBooksCount:\(allReservations?.count ?? 999)")
               
               guard let self,
                     let docId,
                     let allReservations else {
                   
                   self?.callOnMainQueque {
                             self?.logMessage = "[EPIC_FAIL]_Collegamento al database corrotto. Riavviare"
                         }

                   return
               }
               
               self.callOnMainQueque {
                   
                   do {
                       
                       print("DocID from collection HOReservation:\(docId)")
                       
                       let newWsReservation = HOWsReservations(focusUid: docId,allReservation: allReservations) // WorkSpaceUnit(focusUid: docId, allUnit: allUnit)
                       try self.db.currentWorkSpace?.updateWs(with: newWsReservation, in: \.wsReservations)//.updateWsUnit(to: newWsUnit)
                       print("[END]_addWsReservationSubscriber")
                       
                   } catch let error {
                      // self.db.currentWorkSpace = nil
                       self.logMessage = "WsUnit Corrotto - \(error.localizedDescription)"
                   }
                   
               }
              
           }.store(in: &cancellables)
   }
}
