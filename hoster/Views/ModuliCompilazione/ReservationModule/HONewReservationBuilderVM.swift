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
    
    @Published var portale:HOOTAChannel?

    @Published var commissionable:Double?
    @Published var transazioneValue:Double?
    @Published var ivaValue:Double?
    
  // private var optAssociated:[HOOperationUnit]?
    
    init(reservation:HOReservation) {
        
        self.reservation = reservation
        self.storedReservation = reservation
    }

}

extension HONewReservationBuilderVM {

    func initOnAppear(to vm:HOViewModel) {
        // nota 30.07.24
       /* switch self.reservation.refUnit {
            
        case nil: initNewReservation(vm: vm)
        default: initExistingReservation(vm: vm)
            
        }*/
        initNewReservation(vm: vm)
        
        self.mainVM = vm
        
    }
    
    private func initNewReservation(vm:HOViewModel) {
        //print("[INIT]_NewReservation")
        
        self.transazioneValue = vm.getCostiTransazione()
       
        if !vm.getIvaSubject() {
            self.ivaValue = 22
        }

        initUnitOnFocus(vm: vm)
        
    }
    
    
   /* private func initExistingReservation(vm:HOViewModel) {
        
        print("[INIT]_ExistingReservation-\(self.reservation.guestName ?? "no name")")
        
        guard let refUnit = self.reservation.refUnit,
        let refOptAssociated = self.reservation.refOperations else { return }
        
        self.unitOnFocus = vm.getUnitModel(from: refUnit)
        let optAssociated = vm.getOperation(from: refOptAssociated)
        
        initFieldConnectedToOpt(optAssociated: optAssociated)
        
    }*/
    
    
   /* private func initFieldConnectedToOpt(optAssociated:[HOOperationUnit]?) {
        
        guard let optAssociated else { return }
        
        // pernottamenti esenti city tax
        
       if let cityTaxOpt = optAssociated.first(where: {
             $0.writing?.imputationAccount == HOImputationAccount.cityTax
       }) {
           
           let tassati = cityTaxOpt.amount?.quantity ?? 0
           
           self.pernottamentiEsentiCityTax = self.reservation.pernottamenti - Int(tassati)
           
       }
        
       if let commissionabileOpt = optAssociated.first(where: {
             $0.writing?.imputationAccount == HOImputationAccount.pernottamento
       }) {
           
           self.commissionable = commissionabileOpt.amount?.imponibile
           
       }
        
       if let commissioneOTA = optAssociated.first(where: {
             $0.writing?.imputationAccount == HOImputationAccount.ota
       }) {
           
           let labelPortale = self.reservation.labelPortale
           let value = commissioneOTA.amount?.quantity
           
           self.portale = HOOTAChannel(label: labelPortale, commissionValue: value)
        
       }
        
       if let transazioneOpt = optAssociated.first(where: {
            $0.writing?.oggetto?.getSubCategoryCase() == .bancarie
       }) {
           
           let valuePercent = transazioneOpt.amount?.quantity ?? 0
           let value = valuePercent * 100
           
           self.transazioneValue = value
       }
        
       if let ivaAsCost = optAssociated.first(where: {
            $0.writing?.oggetto?.getSubCategoryCase() == .vat
       }) {
           
           let valuePercent = ivaAsCost.amount?.quantity ?? 0
           let value = valuePercent * 100
           
           self.ivaValue = value
           
           
       }
    } */
    
    
   private func initUnitOnFocus(vm:HOViewModel) {
        
        guard let ws = vm.db.currentWorkSpace else {
            
            let alert = AlertModel(
                title: "Errore",
                message: "Current WorkSpace corrupted. Uscire e rientrare.")
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

/// logica commissionable
extension HONewReservationBuilderVM {
    
    var pricePerNight:Double { self.getPricePerNight() }
    var costoCommissione:Double { self.getCostoCommissione() }
    
    var transazionePercent:Double? {
        guard let transazioneValue else { return nil }
            
        return transazioneValue / 100
    }
    var costoTransazione:Double { self.getCostoTransazione() }
    
    var ivaPercent:Double? {
        
        guard let ivaValue else { return nil }
        return ivaValue / 100
    }
    var ivaAsCost:Double { self.getCostoIva() }
    
    var costoCommPlusTrans:Double {
        self.costoCommissione + self.costoTransazione
    }
    var netIncome:Double { self.getNetIncome() }
    
    private func getNetIncome() -> Double {
        
        guard let commissionable else { return 0 }
        
        let allCost = self.costoCommPlusTrans + self.ivaAsCost
        
        return commissionable - allCost
        
    }
    private func getCostoIva() -> Double {
        
        guard let ivaPercent else { return 0 }
        
       // let imponibile = costoCommissione + costoTransazione
        return self.costoCommPlusTrans * ivaPercent
        
    }
    
    private func getCostoTransazione() -> Double {
        
        guard let commissionable,
              let transazionePercent else { return 0 }
        
        return commissionable * transazionePercent
    }
    
    private func getCostoCommissione() -> Double {
        
        guard let commissionable,
              let portale else { return 0 }
        
        return commissionable * portale.commissionPercent
        
        
    }
    
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

/// computed di conformità valori
extension HONewReservationBuilderVM {
    
    var paxIsConformToUnit:Bool { self.getPaxUnitConformity() }
    var paxIsConformToBeds:Bool {  self.reservation.isBedDispoCoerentToPax() }
    
    private func getPaxUnitConformity() -> Bool {
        
        let paxIn = self.reservation.pax ?? 0
        let maxPax = self.unitOnFocus?.pax ?? 0
        
        return paxIn <= maxPax
    }
    
}

/// logica Validation data
extension HONewReservationBuilderVM {
    
     /// Controlla tutti i campi mandatory
    func checkValidation(focusOn:@escaping(_ :HOReservation.FocusField) -> ()) throws {
     
       // try checkUnitOnFocusValidation()
        
       // skip(unitValidation)
        
       // try checkReservationField()
         
        guard self.reservation.guestName != nil else {
              
             focusOn(.guest)
             throw HOCustomError.erroreGenerico(problem: "Nome Ospite assente", reason: nil, solution: nil)
             
          }
        
        guard self.checkUnitOnFocusValidation() else {
             
             throw HOCustomError.erroreGenerico(problem: "Nessuna unità selezionata", reason: nil, solution: nil)
         }
         
        guard checkGuestType() else {
            
            throw HOCustomError.erroreGenerico(problem: "I campi Guest (type & pax) sono incompleti o incoerenti", reason: nil, solution: nil)
            
        }
        
        guard checkDateAndNight() else {
            
            throw HOCustomError.erroreGenerico(problem: "Campo Check-in incompleto", reason: nil, solution: nil)
        }
        
        guard self.checkDispo() else {
            
            throw HOCustomError.erroreGenerico(problem: "Disposizione letti incompleta", reason: nil, solution: nil)
        }
        
       // skip(!isBedCoerent)
        
        guard let _ = portale else {
            
            throw HOCustomError.erroreGenerico(problem:"Canale prenotazione non indicato", reason: nil, solution:nil)
        }
        
        guard let _ = commissionable else {
            
            focusOn(.commisionabile)
            throw HOCustomError.erroreGenerico(problem: "Importo incassato mancante", reason: nil, solution: nil)
        }
        
        return
   }
    
     func checkUnitOnFocusValidation() -> Bool {
         
         return self.unitOnFocus != nil
     }
    
     func checkDateAndNight() -> Bool {
        
        guard self.reservation.dataArrivo != nil,
              let notti = self.reservation.notti,
              notti > 0 else { return false }
        return true
        
    }
    
     func checkGuestType() -> Bool {
        
        guard let type = self.reservation.guestType else {
            return false
        }
        
        guard let pax = self.reservation.pax else { 
            return false }
        
        let typePax = type.getPaxLimit()
        
        switch typePax.limit {
            
        case .exact:
            let condition = (pax == typePax.value)
            return condition
            
        case .minimum:
            let condition = (pax >= typePax.value)
            return condition
            
        }
    }
    
     func checkDispo() -> Bool {
        
        guard let dispo = self.reservation.disposizione,
              !dispo.isEmpty else { return false }
        
        return true
    }
    
}

/// logica salvataggio
extension HONewReservationBuilderVM {
    
    private func buildSideOperations() -> [HOOperationUnit]? {
        
        guard let timeImputation = self.buildTimeImputation() else {
            return nil
        }
    
        // riscossione cityTax
        let cityTaxOPT:HOOperationUnit? = {
        
            guard self.cityTax > 0 else { return nil }
            
           var current = HOOperationUnit()
           
            let dare = HOImputationAccount.cityTax.getIDCode()
            let avere = HOAreaAccount.tributi.getIDCode()
            
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: Double(self.pernottamentiTassati),
                pricePerUnit: self.cityTax)
            
            let writingObject:HOWritingObject = HOWritingObject(category: .imposte, subCategory: .cityTax, specification: self.reservation.specificationLabel)
        
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
        // commissioni ota
        let commissione:HOOperationUnit? = {
   
            guard let portale,
                  let value = portale.commissionValue,
                  value > 0 else { return nil }
            
            var current = HOOperationUnit()
           
            let avere = HOImputationAccount.ota.getIDCode()
            let dare = HOAreaAccount.corrente.getIDCode()
            
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: portale.commissionPercent,
                pricePerUnit: self.commissionable)
            
            let incipit = portale.label != nil ? "[\(portale.label!)]" : "[ota missed]"
            
            let spec = (incipit) + " - " + (self.reservation.specificationLabel ?? "")
            
            let writingObject:HOWritingObject = HOWritingObject(category: .commissioni,subCategory:.agenzia, specification: spec)
            
            let writing:HOWritingAccount = HOWritingAccount(type: .pagamento, dare: dare, avere: avere, oggetto: writingObject)
            
            current.writing = writing
            
            return current
        }()
        // commissioni bancarie
        let transazione:HOOperationUnit? = {
   
            guard let transazioneValue,
                  transazioneValue > 0 else { return nil }
            
           var current = HOOperationUnit()
           
            let avere = HOImputationAccount.diversi.getIDCode()
            let dare = HOAreaAccount.corrente.getIDCode()
            
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: self.transazionePercent,
                pricePerUnit: self.commissionable)
            
            let writingObject:HOWritingObject = HOWritingObject(category: .commissioni,subCategory:.bancarie, specification: self.reservation.specificationLabel)
            
            let writing:HOWritingAccount = HOWritingAccount(type: .pagamento, dare: dare, avere: avere, oggetto: writingObject)
            
            current.writing = writing
            
            return current
        }()
        // iva come costo
        let ivaAsCost:HOOperationUnit? = {
   
            guard let ivaValue,
                  self.costoCommPlusTrans > 0,
                  ivaValue > 0 else { return nil }
            
           var current = HOOperationUnit()
            
            let dare = HOAreaAccount.tributi.getIDCode()
            let avere = HOImputationAccount.diversi.getIDCode()
          
            current.regolamento = self.reservation.regolamento
            current.timeImputation = timeImputation
            current.amount = HOOperationAmount(
                quantity: self.ivaPercent,
                pricePerUnit: self.costoCommPlusTrans)
            
            let writingObject:HOWritingObject = HOWritingObject(category: .imposte,subCategory:.vat, specification: self.reservation.specificationLabel)
            
            let writing:HOWritingAccount = HOWritingAccount(type: .pagamento, dare: dare, avere: avere, oggetto: writingObject)
            
            current.writing = writing
            
            return current
        }()
        
        let optAssociated:[HOOperationUnit?] = [cityTaxOPT,commissionabile,commissione,transazione,ivaAsCost]
        
        let optValide:[HOOperationUnit] = optAssociated.compactMap({$0})
        
        return optValide
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
    
    func publishOperation(refreshPath:HODestinationPath?) {
        
        guard let mainVM else { return }
        
        guard let sideOpt = buildSideOperations() else { return } // una operazione deve esserci sicuramente, quella del commissionabile
        
        let refOpt = sideOpt.map({$0.uid})
        
        let currentReservation:HOReservation = {
            
            var cr = self.reservation
            cr.refUnit = unitOnFocus?.uid
            cr.refOperations = refOpt
            cr.labelPortale = portale?.label
            return cr
        }()
        
        mainVM.plublishBatchTwiceObject(
            object_A: (currentReservation,\.workSpaceReservations),
            objects_C: (sideOpt,\.workSpaceOperations),refreshVMPath: refreshPath)
    }

}

/// logica description
extension HONewReservationBuilderVM {
    
    func shortDescription() -> String {
        
         let warning_0:String = {
             
             if !self.paxIsConformToUnit {
                 
                 return "\n• Il numero di ospiti potrebbe eccedere la capienza massima dell'unità locata."
             } else {
                 return ""
             }
             
         }()
        
        let warning_1:String = {
            
            if !self.paxIsConformToBeds {
                
                return "\n• Il numero di ospiti potrebbe eccedere la capienza massima delle unità letto."
            } else {
                return ""
            }
            
        }()
        
        let condition = warning_0.isEmpty && warning_1.isEmpty
        let incipit = condition ? "" : "WARNING:"
        
        return "\(incipit)\(warning_0)\(warning_1)"
    }
    
    func longDescription() -> String {
     
        guard let guest = self.reservation.guestName,
              let pax = self.reservation.pax,
              let notti = self.reservation.notti,
              let arrivo = self.reservation.dataArrivo,
              let commissionable else { return "no enought data" }
        
        
        let checkIN = csTimeFormatter(style: .long).data.string(from: arrivo)
        let night = csSwitchSingolarePlurale(checkNumber: notti, wordSingolare: "notte", wordPlurale: "notti")
        
        let price = commissionable.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
        
        return "\(guest)\nArrivo il \(checkIN)\n\(notti) \(night) - \(pax) pax\n\(price)"
     
        
     
    }
    
}
