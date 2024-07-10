//
//  HONewReservationBuilderVM.swift
//  hoster
//
//  Created by Calogero Friscia on 09/07/24.
//

import Foundation
import MyPackView

final class HONewReservationBuilderVM:ObservableObject {
    
    @Published var unitOnFocus:HOUnitModel?
    
    @Published var reservation: HOReservation
    var storedReservation: HOReservation
    
    
    init(reservation:HOReservation) {
        
        self.reservation = reservation
        self.storedReservation = reservation
    }
    
}


/// unitOnFocus Logic
extension HONewReservationBuilderVM {
    
    /// se il valore è true vuol dire che vi è un errore
    func checkUnitValidation() -> Bool {
        
        guard let unitOnFocus else { return true }
        
        let paxIn = self.reservation.pax ?? 0
        
        return paxIn > (unitOnFocus.pax ?? 0)
        
    }
    
   private func checkUnitOnFocusValidation() throws -> Bool {
        // se la unitOnFocus è assente throwiamo un errore. Se è presente controlliamo se vi è conformità fra la paxIn e la paxMax dell'unità. Non throwiamo nessun errore ma grazie ad una escaping mandiamo il warning visivo e chiediamo attenzione nella descrizione prima del salvataggio. Quindi il salvataggio sarà permesso.
        guard let unitOnFocus else {
            
            throw HOCustomError.erroreGenerico(problem: "Nessuna unità selezionata", reason: nil, solution: nil)
        }
        
        let paxIn = self.reservation.pax ?? 0
        
        return paxIn > (unitOnFocus.pax ?? 0)
        
    }
    
    
    func initUnitOnFocus(vm:HOViewModel) {
        
        guard let ws = vm.db.currentWorkSpace else {
            
            let alert = AlertModel(
                title: "Errore",
                message: "Current WorkSpace corrupted")
            vm.sendAlertMessage(alert: alert)
            return
        }
        
        switch ws.wsType {
       
        case .wholeUnit:
            let main = ws.wsUnit.main
            self.unitOnFocus = main
        case .withSub:
            self.unitOnFocus = nil
        }
        
    }

    
}

/// logica Validation data
extension HONewReservationBuilderVM {
    
    /// attraverso la escaping ritorna un valore per eseguire un warning skippando l'errore. Utile quando si vuole avvertire di una inconformità non vincolante
    func checkValidation(skip:@escaping(_ :Bool) -> () ) throws  {
     
        let unitValidation = try checkUnitOnFocusValidation()
        
        skip(unitValidation)
        
        try checkReservationField()
        
        guard !checkGuestType() else {
            
            throw HOCustomError.erroreGenerico(problem: "I campi Guest (type & pax) sono incompleti o incoerenti", reason: nil, solution: nil)
            
        }
        
        guard !errorCheckIn() else {
            
            throw HOCustomError.erroreGenerico(problem: "Campo Check-in incompleto", reason: nil, solution: nil)
        }
        
       let isBedCoerent = try self.reservation.isBedDispoCoerentToPaxThrowing()
        
        skip(!isBedCoerent)
        
        
        
        return
   }
    
    
     func errorCheckIn() -> Bool {
        
        guard self.reservation.dataArrivo != nil,
              let notti = self.reservation.notti,
              notti > 0 else { return true }
        return false
        
    }
    
    
     func checkGuestType() -> Bool {
        
        guard let type = self.reservation.guestType else {
            return true
        }
        
        guard let pax = self.reservation.pax else { 
            return true }
        
        let typePax = type.getPaxLimit()
        
        switch typePax.limit {
            
        case .exact:
            let condition = (pax == typePax.value)
            return !condition
            
        case .minimum:
            let condition = (pax >= typePax.value)
            return !condition
            
        }
    }
    
    private func checkReservationField() throws {
        
       guard self.reservation.dataArrivo != nil &&
        self.reservation.guestName != nil &&
        self.reservation.guestType != nil &&
        self.reservation.notti != nil &&
        self.reservation.disposizione != nil else {
            
           throw HOCustomError.erroreGenerico(problem: "Modulo incompleto", reason: nil, solution: nil)
           
        }
        
        return
        
    }
    
}

/// logica salvataggio
extension HONewReservationBuilderVM {
    
    func publishOperation(mainVM:HOViewModel,refreshPath:HODestinationPath?) {
        
       /* let mainOPT = compileMainOperation()
        let associatedOPT = compileAssociatedOperation()
        
        mainVM.publishBatch(
            from: mainOPT,associatedOPT,
            syncroDataPath: \.workSpaceOperations,
            refreshVMPath: refreshPath) */
        
        let current:HOReservation = {
            
            var cr = self.reservation
            cr.refUnit = unitOnFocus?.uid
            cr.refOperations = ["ciaciao"]
            return cr
        }()
        
        mainVM.publishData(from:current, syncroDataPath: \.workSpaceReservations, refreshVMPath: refreshPath)
    }
    
    
    
    
}

/// logica description
extension HONewReservationBuilderVM {
    
    func shortDescription() -> String {
        
        return "short"
    }
    
    func longDescription() -> String {
        
        let warning_0:String = {
            let unitValidation = self.checkUnitValidation()
            
            if unitValidation {
                
                return "! WARNING: Il numero di ospiti potrebbe eccedere la capienza massima dell'unità.\n"
            } else {
                return ""
            }
            
        }()
        
        let warning_1:String = {
            
            let bedValidation = self.reservation.isBedDispoCoerentToPax()
            
            if !bedValidation {
                
                return "!! WARNING: Il numero di ospiti potrebbe eccedere la capienza massima delle unità letto.\n"
            } else {
                return ""
            }
            
        }()
        
        
        
        return "\(warning_0)\(warning_1)"
    }
    
}
