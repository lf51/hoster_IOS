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
    
     func addYYSubscriber() {
        
        $yyFetchData
            .sink { _ in
                //
            } receiveValue: { [weak self] yyCurrent in
                print("[START]_addYYSubscriber")
                guard let self,
               // let yyCurrent,
                yyCurrent != self.yyFetchData else { return }
                // vedi Nota 29.08.24
                do {
                    print("YY_Subscriber:\nNewValue is \(yyCurrent.description)\nOld Value is \(self.yyFetchData.description)")
                    let t0 = yyCurrent - 1
                    let yy:[Int] = {
                        return [yyCurrent,t0]
                    }()
                    
                    try self.dbManager.fetchAndListenReservationAndOperations(filteredBy: yy)
                    
                } catch let error {
                    
                    self.callOnMainQueque {
                        
                        let message = HOSystemMessage(vector:.log,title: "Error", body: .custom(error.localizedDescription))
                        self.sendSystemMessage(message: message)

                    }
                    
                }
                
            }.store(in: &cancellables)

    }
    
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
                        
                        self.sendAlertMessage(alert: alert)
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
                        
                        let yy:[Int] = {
                           // return [self.yyFetchData]
                            let t0 = self.currentYY - 1
                            return [self.currentYY,t0]
                        }()
                        
                        try self.dbManager.fetchAndListenWorkSpaceModel(wsFocusUID: ref, filteredBy:yy)
                    } else {
                        
                       // self.setLoading(to: .end)
                    }
 
                } catch let error {
                    
                    self.callOnMainQueque {
                        
                        let message = HOSystemMessage(vector:.log,title: "Error", body: .custom(error.localizedDescription))
                        self.sendSystemMessage(message: message)
                      //  self.logMessage = error.localizedDescription
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
            .sink { _ in
            
            } receiveValue: { [weak self] workSpaceData in
                print("[START]_addWsDataSubscriber")
                guard let self,
                      let workSpaceData else {
                    
                    self?.callOnMainQueque {
                        
                        let message = HOSystemMessage(vector:.log,title: "[EPIC_FAIL]", body: .custom("Collegamento al database corrotto. Riavviare"))
                        
                        self?.sendSystemMessage(message: message)
                            //  self?.logMessage = "[EPIC_FAIL]_Collegamento al database corrotto. Riavviare"
                          }
 
                    return
                }
                
                self.callOnMainQueque {
                    do {
    
                        try self.db.currentWorkSpace?.updateWs(with: workSpaceData, in: \.wsData)
                       // try self.db.currentWorkSpace?.updateWsData(to: workSpaceData)
                        
                    } catch let error {
                       // self.db.currentWorkSpace = nil
                      //  self.logMessage = "WsDataCorrotto - \(error.localizedDescription)"
                        let message = HOSystemMessage(vector:.log,title: "WsDataCorrotto", body: .custom(error.localizedDescription))
                        
                        self.sendSystemMessage(message: message)
                        
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
                           //  self?.logMessage = "[EPIC_FAIL]_Collegamento al database corrotto. Riavviare"
                        
                        let message = HOSystemMessage(vector:.log,title: "[EPIC_FAIL]", body: .custom("Collegamento al database corrotto. Riavviare"))
                        self?.sendSystemMessage(message: message)
                        
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
                       // self.logMessage = "WsUnit Corrotto - \(error.localizedDescription)"
                        let message = HOSystemMessage(vector:.log,title: "WsUnit Corrotto", body: .custom(error.localizedDescription))
                        
                        self.sendSystemMessage(message: message)
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
                           //  self?.logMessage = "[EPIC_FAIL]_Collegamento al database corrotto. Riavviare"
                       let message = HOSystemMessage(vector:.log,title: "[EPIC_FAIL]", body: .custom("Collegamento al database corrotto. Riavviare"))
                       
                       self?.sendSystemMessage(message: message)
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
                      // self.logMessage = "WsUnit Corrotto - \(error.localizedDescription)"
                       let message = HOSystemMessage(vector:.log,title: "WsReservations Corrotto", body: .custom(error.localizedDescription))
                       
                       self.sendSystemMessage(message: message)
                       
                   }
                   
               }
              
           }.store(in: &cancellables)
   }
    
     func addWsOperationsSubscriber() {
        
        self.dbManager
            .workSpaceOperations
            .publisher
            .sink { _ in
                
            } receiveValue: { [weak self] docId, allOperations in
                
                print("[START]_addWsOperationsSubscriber\n_docId\(docId ?? "noDoc")\n_allOperationsCount:\(allOperations?.count ?? 999)")
                
                guard let self,
                        let docId,
                        let allOperations else {
                    
                    self?.callOnMainQueque {
                        
                        let message = HOSystemMessage(vector:.log,title: "[EPIC_FAIL]", body: .custom("Collegamento al database Operations corrotto. Riavviare"))
                        
                        self?.sendSystemMessage(message: message)
                            }

                    return
                }
                
                self.callOnMainQueque {
                    
                    do {
                        
                        print("DocID from collection HOOperations:\(docId)")
                        
                        let newWsOperations = HOWsOperations(focusUid: docId,allOperations: allOperations)
                        
                        try self.db.currentWorkSpace?.updateWs(with: newWsOperations, in: \.wsOperations)
                        print("[END]_addWsOperationsSubscriber")
                        
                    } catch let error {
                    
                        let message = HOSystemMessage(vector:.log,title: "WsOperations Corrotto", body: .custom(error.localizedDescription))
                        
                        self.sendSystemMessage(message: message)
                        
                    }
                    
                }
                
            }.store(in: &cancellables)
    }
}
