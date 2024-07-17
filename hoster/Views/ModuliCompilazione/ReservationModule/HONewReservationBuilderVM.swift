//
//  HONewReservationBuilderVM.swift
//  hoster
//
//  Created by Calogero Friscia on 09/07/24.
//

import Foundation
import MyPackView

final class HONewReservationBuilderVM:ObservableObject {
    
    private var mainVM:HOViewModel?
    
    @Published var unitOnFocus:HOUnitModel?
    
    @Published var reservation: HOReservation
    var storedReservation: HOReservation
    
    @Published var pernottamentiEsentiCityTax:Int?
    @Published var commissionable:Double?
    @Published var costoCommissione:Double?
    
    init(reservation:HOReservation) {
        
        self.reservation = reservation
        self.storedReservation = reservation
    }

    func setMainVM(to vm:HOViewModel) {
        
        self.mainVM = vm
    }
}

/// logica commissionable
extension HONewReservationBuilderVM {
    
    var pricePerNight:Double { self.getPricePerNight() }
    
    private func getPricePerNight() -> Double {
        
        guard let commissionable,
              let night = self.reservation.notti else { return 0.0 }
        
        return commissionable / Double(night)
    }
}

/// logica cityTax
extension HONewReservationBuilderVM {
    
    var cityTax:Double {
        self.mainVM?.getCityTaxPerPerson() ?? 0.0
    }
    
    var pernottamentiTassati:Int {
        
        get { self.getPernottamentiTassati() }
    } // salvato come q per la tassa di soggiorno
    
    
   private func getPernottamentiTassati() -> Int {
       self.reservation.pernottamenti - (self.pernottamentiEsentiCityTax ?? 0)
    
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
    
    func buildSideOperations() {
        
        guard let timeImputation = self.buildTimeImputation() else {
            return
        }
        // riscossione cityTax
        let cityTaxOPT:HOOperationUnit = {
        
           var current = HOOperationUnit()
           
            let dare = HOImputationAccount.pernottamento.getIDCode()
            let avere = HOAreaAccount.tributi.getIDCode()
            
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: Double(self.pernottamentiTassati),
                pricePerUnit: self.cityTax)
            
            let writingObject:HOWritingObject = HOWritingObject(category: .cityTax, subCategory: nil, specification: self.reservation.guestName)
        
            let writing:HOWritingAccount = HOWritingAccount(type: .riscossione, dare: dare, avere:avere, oggetto: writingObject)
            
            current.writing = writing
            
            return current
        }()
        // incasso al lordo
        let commissionabile:HOOperationUnit = {
            
            var current = HOOperationUnit()
            
            let dare = HOImputationAccount.pernottamento.getIDCode()
            let avere = HOAreaAccount.corrente.getIDCode()
            
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: Double(self.reservation.notti ?? 0),
                pricePerUnit: self.pricePerNight)
            
            let writingObject:HOWritingObject = HOWritingObject(category: .servizi,subCategory:.interno, specification: self.reservation.specificationLabel)
            
            let writing:HOWritingAccount = HOWritingAccount(type: .vendita, dare: dare, avere: avere, oggetto: writingObject)
            
            current.writing = writing
            
            return current
        }()
        // pagamento commissioni
        let commissione:HOOperationUnit = {
        // da completare
           var current = HOOperationUnit()
           
            let avere = HOImputationAccount.pernottamento.getIDCode()
            let dare = HOAreaAccount.corrente.getIDCode()
            
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: 1,
                pricePerUnit: self.costoCommissione)
            
            let writingObject:HOWritingObject = HOWritingObject(category: .commissioni,subCategory:nil, specification: self.reservation.specificationLabel)
            
            let writing:HOWritingAccount = HOWritingAccount(type: .pagamento, dare: dare, avere: avere, oggetto: writingObject)
            
            current.writing = writing
            
            return current
        }()
        
        
        
        
        
    }
    
    private func buildTimeImputation() -> HOTimeImputation? {
        
        guard let checkIn = self.reservation.dataArrivo else {
            return nil
        }
        
        let imputationComponent = Locale.current.calendar.dateComponents([.month,.year], from: checkIn)
        
        let monthImputation = HOMonthImputation(startMM: imputationComponent.month, advancingMM: 1)
        
        let timeImputation = HOTimeImputation(startYY: imputationComponent.year, monthImputation: monthImputation)
        
        return timeImputation
    }
    
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
