//
//  HOCheckIn.swift
//  hoster
//
//  Created by Calogero Friscia on 22/03/24.
//

import Foundation
import MyFilterPack
import MyPackView
import SwiftUI

struct HOReservation:HOProStarterPack {
    
    let uid:String
    let regolamento:Date
    var statoPagamento:HOReservationPayamentStatus
    
    var refUnit:String? //
    var refOperations:[String]? // operazioni associate // vendita servizio pernottamento, vendita servizio colazione transfer etc. Associabili in fase di creazione attraverso un default che possiamo fare impostare all'utente, con i servizi inclusi nella reservation, e possiamo associare in seguito ad esempio per il sopravvenire di regali e mance.
    
    var labelPortale:String? //
    
    var dataArrivo:Date? //
    var guestName:String? //
    var guestType:HOGuestType? //
    var pax:Int? //
    var notti:Int? //
    var disposizione:[HOBedUnit]? //
    
    var scheduleCache:Int? // salvato su firebase in caso di schedule forzata// 0 manuale - nil è automatico
    
    var note:String? //
    
    
    
    init() {
        self.uid = UUID().uuidString
        self.regolamento = Date()
        self.statoPagamento = .inPagamento
    }
}

/// miscellaneus
extension HOReservation {
    
    var calendar:Calendar { Locale.current.calendar }
    /// tupla con l'anno di checkIn e checkOut
    var yearIn:(yyIn:Int,yyOut:Int)? { self.getYearIn() }
    /// tupla con gli ordinali del mese di checkIn e checkOut
    var monthInOrdinal:(mmIn:Int,mmOut:Int)? { self.getMonthInOrdinal() }
    
    var monthIn:HOMonthObject? { self.getMonthIn() } // oggetto utile per il filtro. Fare update del myFilterPack ed eliminare quest'oggetto sostibuile con il valore ordinale del mese o il suo valore stringa
    
    private func getYearIn() -> (Int,Int)? {
        
        guard let dataArrivo else { return nil }
        
        let yearIn = calendar.component(.year, from: dataArrivo)
        let yearOut = calendar.component(.year, from: checkOut)
        
        return (yearIn,yearOut)
        
    }
    
    private func getMonthIn() -> HOMonthObject? { // deprecata
        
        guard let dataArrivo else { return nil }
       
      // let calendar = Locale.current.calendar
        
        let month = calendar.component(.month, from: dataArrivo)
        let monthValue = csMonthString(from: month)//calendar.monthSymbols[month - 1]

        return HOMonthObject.month(monthValue)
    }
    
    private func getMonthInOrdinal() -> (Int,Int)? {
        
        guard let dataArrivo else { return nil }

        let monthIn = calendar.component(.month, from: dataArrivo)
        let monthOut = calendar.component(.month, from: checkOut)
        
        
        return (monthIn,monthOut)
    }
    
}

/// campi string per le proprietà. Utile nei salvataggi singleValue. Possibile elevazione a protocollo
/*extension HOReservation {
    
    enum InternalPropertyStringValue:String {
        
        case scheduleCache = "schedule_cache"
        case statoPagamento = "stato_pagamento"
        case dataArrivo = "data_arrivo"
    }
    
}*/

/// visual Logic
extension HOReservation {
    
    @ViewBuilder func vbInteractiveMenu(viewModel:HOViewModel) -> some View {
        
        VStack {
            
            // eventuale edit/modifica
            
            // cambio stato pagamento
            vbStatoPagamento(viewModel: viewModel)
            // force scheduleStatus
            
            // Rimborso Parziale
            
            // noShow
           // vbNoShowLogic(viewModel: viewModel)
            

        }
        
    }
    
    @ViewBuilder private func vbStatoPagamento(viewModel:HOViewModel) -> some View {
        
        Menu {
            
            vbPayed(viewModel: viewModel)
            
            vbCancelled(viewModel: viewModel)
           
            vbPartialPayed(viewModel: viewModel)
            
            vbNoShowLogic(viewModel: viewModel)
            
            vbPayamentDescription()
            
        } label: {
            Text("Stato Pagamento")
        }

    }
    
    @ViewBuilder private func vbPartialPayed(viewModel:HOViewModel) -> some View {
        
        /*let key = InternalPropertyStringValue.statoPagamento.rawValue
        let value = HOReservationPayamentStatus.partiallyPayed.rawValue
        
        let pathPartial:[String:Any] = [key:value]
        
        let general = self.statoPagamento != .inPagamento*/ // oscurate perchè con il disabilita non servono

        let partialConditio = self.statoPagamento == .partiallyPayed
        
        Button {
          //  viewModel.publishSingleField(from: self, syncroDataPath: \.workSpaceReservations, valuePath: pathPartial)
        } label: {
            HStack {
                
                Text("Parzialmente Rimborsato")
                Image(systemName: partialConditio ? "checkmark.circle" : "circle")
            }
        }
        .disabled(true)
        .opacity(0.6)
        //.disabled(general)
        //.opacity(general ? 0.6 : 1.0)
      // Disabilitato da sviluppare vedi NOTA 08.08.24
        
    }
    
    @ViewBuilder private func vbCancelled(viewModel:HOViewModel) -> some View {
        
      /*  let key = InternalPropertyStringValue.statoPagamento.rawValue
        let value = HOReservationPayamentStatus.cancelled.rawValue
        
        let pathCancelled:[String:Any] = [key:value]
        
        let general = self.statoPagamento != .inPagamento
*/ // oscurate perchè con il disabilita non servono
        let cancelConditio = self.statoPagamento == .cancelled
        
        Button {
          //  viewModel.publishSingleField(from: self, syncroDataPath: \.workSpaceReservations, valuePath: pathCancelled)
        } label: {
            HStack {
                
                Text("Cancellato")
                Image(systemName: cancelConditio ? "checkmark.circle" : "circle")
            }
        }
        .disabled(true)
        .opacity(0.6)
       // .disabled(general)
       // .opacity(general ? 0.6 : 1.0)
      // Disabilitato da sviluppare vedi NOTA 08.08.24
        
    }
    
    @ViewBuilder private func vbPayed(viewModel:HOViewModel) -> some View {
        
        let key = InternalPropertyStringValue.statoPagamento.rawValue
        let value = HOReservationPayamentStatus.payed.rawValue
        let pathPayed:[String:Any] = [key:value]

        let general = self.statoPagamento == .payed
        
        Button {
            viewModel.publishSingleField(from: self, syncroDataPath: \.workSpaceReservations, valuePath: pathPayed)
        } label: {
            HStack {
                
                Text("Incassato")
                Image(systemName: general ? "checkmark.circle" : "circle")
            }
        }
        .disabled(general)
        .opacity(general ? 0.6 : 1.0)

    }
    
    @ViewBuilder private func vbPayamentDescription() -> some View {
        
        let description = self.scheduleStatus.getDescriptionAssociated(to: self.statoPagamento)
        
        Text("''\(description)''")

    }
    
    @ViewBuilder private func vbNoShowLogic(viewModel:HOViewModel) -> some View {
        
        let disabilitaValue = (self.statoPagamento == .cancelled) || (self.statoPagamento == .inPagamento)
        
        let key = InternalPropertyStringValue.scheduleCache.rawValue
        let update:(value:Int?,label:String) = {
           
            if self.scheduleStatus == .noShow {
                return (nil,"Cancella No-Show")
            }
            else {
               
                return (HOReservationSchedule.noShow.rawValue,"Segnala come No-Show") }
        }()
        
        let valuePath:[String:Any] = [key:update.value as Any]
        
        let descriptioAssociated = "Clicca per confermare il seguente risultato:\n\(self.statoPagamento.getDescriptionAssociated(to: update.value))"
        
        Button(update.label,role:.destructive,action: {

            viewModel.sendAlertMessage(alert: AlertModel(title: update.label, message: descriptioAssociated, actionPlus: ActionModel(title: .conferma, action: {
                viewModel.publishSingleField(from: self, syncroDataPath: \.workSpaceReservations, valuePath: valuePath)
            })))

        })
        .disabled(disabilitaValue)
        .opacity(disabilitaValue ? 0.6 : 1.0)
        
    }
    
    
}

/// schedule logic
extension HOReservation {
    
    /// valore semiAutomatico
    var scheduleStatus:HOReservationSchedule { self.getSchedulStatus() }
    
    private func getSchedulStatus() -> HOReservationSchedule {
        
        guard self.statoPagamento != .cancelled else { return .noShow }
        
        if let scheduleCache,
           scheduleCache == 0 { return .noShow }
        
        guard let dataArrivo else { return .inArrivo } // valutare se inserire un caso apposito. Cmq la data seppur optional è un valore mandatory
        
        let today = Date()
        
        let compareToArrivo = today.compare(dataArrivo)
        
        if compareToArrivo.rawValue == -1 { return .inArrivo }
        
        let compareToCheckOut = today.compare(self.checkOut)
        
        if compareToCheckOut.rawValue == -1 { return .inCorso }
        else { return .completata }
        
        
    }
    
    func visualScheduleDescription() -> (internalImage: String, internalColor: Color, externalColor: Color, description: String) {
        
        // dashed esterno lo status della schedule
        // colore interno lo stato del pagamento
        // immagine interna legata al pagamento
        
        let imageInternal = self.statoPagamento.getImageAssociated()
        let colorInternal = self.statoPagamento.getColorAssociated()
        let dashedColor = self.scheduleStatus.getColorAssociated()
        
        let statoPay = "Pagamento \(self.statoPagamento.getTapDescription())"
        let statoSched = "Soggiorno \(self.scheduleStatus.getTapDescription())"
 
        let descrizione = "\(statoPay)\n\(statoSched)"
        
        return (imageInternal,colorInternal,dashedColor,descrizione)
        
    }
    
}
/// validation Logic
extension HOReservation {
    
    func isBedDispoCoerentToPax() -> Bool {
        
        let maxPaxFromDispo = self.getMaxPaxFromDisposizione() ?? 0
        let pax = self.pax ?? 0
        
        return pax <= maxPaxFromDispo
 
    }
    
    
    private func getMaxPaxFromDisposizione() -> Int? {
        
        guard let disposizione,
              !disposizione.isEmpty else { return nil }
        
            var max:Int = 0
            
            for eachBed in disposizione {
                
                let maxPax = eachBed.bedType?.getMaxCapability() ?? 0
                
                let value = maxPax * (eachBed.number ?? 0)
                max += value
            }
            
            return max

    }
}

extension HOReservation:Hashable {
    
    static func == (lhs: HOReservation, rhs: HOReservation) -> Bool {
        lhs.uid == rhs.uid &&
        lhs.regolamento == rhs.regolamento &&
        lhs.refUnit == rhs.refUnit &&
        lhs.refOperations == rhs.refOperations &&
        lhs.guestType == rhs.guestType &&
        lhs.guestName == rhs.guestName &&
        lhs.pax == rhs.pax &&
        lhs.dataArrivo == rhs.dataArrivo &&
        lhs.notti == rhs.notti &&
        lhs.disposizione == rhs.disposizione &&
        lhs.labelPortale == rhs.labelPortale &&
        lhs.note == rhs.note &&
        lhs.statoPagamento == rhs.statoPagamento &&
        lhs.scheduleCache == rhs.scheduleCache
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.uid)
    }
    
    
}
/// logica pernottamento
extension HOReservation {
    
    var pernottamenti:Int { getPernottamenti() }
   // var pernottamentiTassati:Int? { (self.pernottamenti) - (self.pernottamentiEsentiCityTax ?? 0) } // forse inutile
    var checkOut:Date { getCheckOut() }
    
    private func getPernottamenti() -> Int {
        
        guard let pax,
              let notti else { return 0 }
        
        return pax * notti
    }
    
    private func getCheckOut() -> Date {
        
        guard let dataArrivo else {
            
            let out = Date().addingTimeInterval(86400) // + one day
            return out }
        
        guard let notti else {
            
            let out = dataArrivo.addingTimeInterval(86400)
            return out
        }
        
        let nightInterval = TimeInterval(86400 * notti)
        
        return dataArrivo.addingTimeInterval(nightInterval)
            
    }
    
}

extension HOReservation:Codable { }

extension HOReservation:Object_FPC {
  
    typealias VM = HOViewModel
    var id: String { self.uid }
  
    static func sortModelInstance(lhs: HOReservation, rhs: HOReservation, condition: SortCondition?, readOnlyVM: HOViewModel) -> Bool {
        
        switch condition {
        case .schedule:
            return schedulSortCondition(lhs: lhs, rhs: rhs)
        default:
            return false
        }
        
    }
    
    private static func schedulSortCondition(lhs:HOReservation,rhs:HOReservation) -> Bool {
        
        guard let rhsArrive = rhs.dataArrivo,
              let lhsArrive = lhs.dataArrivo else { return false }
        
        let lhsStatus = lhs.scheduleStatus
        let rhsStatus = rhs.scheduleStatus
        
        switch lhsStatus {
            
        case rhsStatus:
            
            switch lhsStatus {
            case .noShow,.completata:
                return lhsArrive > rhsArrive
            case .inArrivo,.inCorso:
                return lhsArrive < rhsArrive
           
            }
        
        default:
            return lhsStatus.orderAndStorageValue() < rhsStatus.orderAndStorageValue()

        }
    
    }
    
    
    func stringResearch(string: String, readOnlyVM: HOViewModel?) -> Bool {
        
        let ricerca = string.lowercased()
        let campo_uno = self.guestName?.lowercased() ?? ""
        
        let check = campo_uno.contains(ricerca)
        return check
        
    }
    
    func propertyCompare(coreFilter: CoreFilter<Self>, readOnlyVM: HOViewModel) -> Bool {
       
        let filterProperties = coreFilter.filterProperties
        let guestTipo = self.guestType ?? .single
        let month = self.monthIn ?? HOMonthObject.month("no value")
        let unitRef = self.refUnit ?? ""
        let normalizedUnitRefParameter:[String]? = {
            
            guard let unitModel = filterProperties.unitModel else { return nil }
            
            return [unitModel.uid]
            
        }()
        
        let otaLabel = self.labelPortale ?? "no ota"
        let normalizedOTAParameter:[String]? = {
            
            guard let ota = filterProperties.portale,
                  let label = ota.label else { return nil }
            
            return [label]
            
        }()
        
        let stringResult:Bool = {
            
            let stringa = coreFilter.stringaRicerca
            guard stringa != "" else { return true }
            
            let result = self.stringResearch(string: stringa, readOnlyVM: nil)
            return coreFilter.tipologiaFiltro.normalizeBoolValue(value: result)
            
        }()
        
       return stringResult &&
        coreFilter.comparePropertyToProperty(localProperty: self.statoPagamento, filterProperty: filterProperties.statoPagamento) &&
        coreFilter.comparePropertyToProperty(localProperty: guestTipo, filterProperty: filterProperties.guestType) &&
        coreFilter.comparePropertyToProperty(localProperty: month, filterProperty: filterProperties.monthIn) &&
        coreFilter.compareRifToCollectionRif(localPropertyRif:unitRef, filterCollection: normalizedUnitRefParameter) &&
        coreFilter.compareRifToCollectionRif(localPropertyRif: otaLabel, filterCollection: normalizedOTAParameter)
        
    }
    
    struct FilterProperty:SubFilterObject_FPC {
        
        static func reportChange(old: FilterProperty, new: FilterProperty) -> Int {
            
            countManageSingle_FPC(newValue: new.statoPagamento, oldValue: old.statoPagamento) +
            countManageSingle_FPC(newValue: new.guestType, oldValue: old.guestType) +
            countManageSingle_FPC(newValue: new.monthIn, oldValue: old.monthIn) +
            countManageSingle_FPC(newValue: new.unitModel, oldValue: old.unitModel) +
            countManageSingle_FPC(newValue: new.portale, oldValue: old.portale)
            
        }
        
        // pagamento
        var statoPagamento:HOReservationPayamentStatus? //
        // tipo ospite
        var guestType:HOGuestType?
        // portale
        var portale:HOOTAChannel?
        // subUnit
        var unitModel:HOUnitModel?
        // mese
        var monthIn:HOMonthObject?

    }
    
    enum SortCondition:SubSortObject_FPC {
        
        static var defaultValue: HOReservation.SortCondition = .schedule
        
        case schedule
        
        func simpleDescription() -> String {
            switch self {
   
            case .schedule:
                return "Stato Arrivo"
            }
        }
        
        func imageAssociated() -> String {
            return "calendar.circle"
        }
        
    }
   
}

extension HOReservation:HOProFocusField {
    
    enum FocusField:Int,Hashable {
        
        case refUnit = 0
        case refOperation
        case arrivo
        case guest
        case guestType
        
        case pax
        case notti
        case disposizione
        
      //  case pernottEsenti
        case note
        
        // focus su operazioni collegate
        case commisionabile
        case cityTax
        case vatDebito
        case vatCredito
        case commissione
        case transazione
        
        
    }
}

extension HOReservation:HOProNoteField { }

/// logica descrizion
extension HOReservation {
    
    /// ritorna il nome del guest se presente altrimenti -nuova prenotazione-
    var labelModCompile:String { getLabelModCompile() }
    /// Contiene il nome del guest e l'uid preceduto da #
    var specificationLabel:String? { self.getSpecification() }
    
    private func getLabelModCompile() -> String {
         
        guard let guestName else {
            
            return "Nuova Prenotazione"
        }
        
        return guestName
         
     }
    
    private func getSpecification() -> String? {
        
        guard let guestName else { return nil }
 
        return "\(guestName) #\(self.uid)"
        
        
    }
    

}
