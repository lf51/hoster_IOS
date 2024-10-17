//
//  WorkSpaceReservation.swift
//  hoster
//
//  Created by Calogero Friscia on 22/03/24.
//

import Foundation

struct HOWsReservations:HOProStarterPack {
    
    let uid: String
    
    var all: [HOReservation]
    
    init(focusUid:String,allReservation:[HOReservation] = []) {
        
        self.uid = focusUid
        self.all = allReservation
    }
    
    /// Nel caso di prenotazioni a cavallo fra due mesi o fra due anni, il valore incassato sarà normalizzato per i giorni effettivi dentro il mese di riferimento, o dentro l'anno di riferimento
    /// - Parameters:
    ///   - year: anno di riferimento
    ///   - month: mese di riferimento
    ///   - sub: sotto unità da investigare
    ///   - viewModel: viewModel
    /// - Returns: ritorna il conto degli arrivi, le notti totali, il numero di ospiti, e il valore incassato
    func getInformation(year:Int,month:Int?,sub:String?,viewModel:HOViewModel)  -> (arrivalCount:Int,totalNight:Int,totalGuest:Int,tassoOccupazioneNotti:Double) {
  
        // tutte le prenotazioni che hanno il check-in e il check-out nel mese e nell'anno di riferimento
        let filtered:[HOReservation] = self.getAllFiltered(year: year,subRef: sub,notConsiderCheckOut: false)
        
        let baseDate = DateComponents(calendar: viewModel.localCalendar,year: year, month: month).date ?? Date()
        
        let baseInterval:DateInterval? = {
            
            if let _ = month {
              
                return viewModel.localCalendar.dateInterval(of: .month, for: baseDate)
                
            } else {
                
                return viewModel.localCalendar.dateInterval(of: .year, for: baseDate)
            }
            
        }()
        
        guard let baseInterval else { return (0,0,0,0) }
        
        let reservationInvolved = filtered.filter({
            
            $0.occupacyInterval?.intersects(baseInterval) ?? false
        })
        
        let involvedIn = reservationInvolved.filter({
            
            if let dataArrivo = $0.dataArrivo {
                
                if let month {
                    let mm = viewModel.localCalendar.component(.month, from: dataArrivo)
                    return mm == month
                    
                } else {
                    let yy = viewModel.localCalendar.component(.year, from: dataArrivo)
                    return yy == year
                    
                }

            } else { return false }
        })
        
        let arrivalCount = involvedIn.count // first Info
        
        // il numero di guest è preso solo dagli arrivi
        let guests = involvedIn.reduce(into:0) { partialResult, reservation in
             
             partialResult += (reservation.pax ?? 0)
         } // third info
        
        
        let occupacy = reservationInvolved.compactMap({
            
            $0.occupacyInterval?.intersection(with: baseInterval)
            
        })
        
        let nights = occupacy.reduce(into:0) { partial, interval in
            
            let lengh = viewModel.localCalendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
            
           // let lengh = interval.duration / 86400 // nn giorni
            partial += lengh
            
        } // second info
   
       // let income = getIncomeDDbased(from: reservationInvolved, monthInterval: baseInterval, viewModel: viewModel) // fourth info
        
        // tasso di occupazine
        // notti / notti disponibili
        
        let subUnitCount:Int = {
            
            guard sub == nil else { return 1 }
          
            let count = viewModel.subUnitCount == 0 ? 1 : viewModel.subUnitCount
            return count
            
        }()
        
        let nottiAvaible:Int = {
           
            var dd:Int = 0
            
            if let month {
                
                dd = viewModel.getDDOn(monthOrdinal: month)
            }
            else {
                dd = viewModel.currentDDOnFetchYY }
            
            return dd * subUnitCount
        }()
        
        let tassoOccNotti = Double(nights) / Double(nottiAvaible)

        return (arrivalCount,nights,guests,tassoOccNotti)
        
    }
    
    /// Nel caso di prenotazioni a cavallo fra due mesi o fra due anni, il valore incassato sarà normalizzato per i giorni effettivi dentro il mese di riferimento, o dentro l'anno di riferimento
    /// - Parameters:
    ///   - year: anno di riferimento
    ///   - month: mese di riferimento
    ///   - sub: sotto unità da investigare
    ///   - viewModel: viewModel
    /// - Returns: ritorna il conto degli arrivi, le notti totali, il numero di ospiti, e il valore incassato
   /* func getInformationDEPRECATA(year:Int,month:Int?,sub:String?,viewModel:HOViewModel)  -> (arrivalCount:Int,totalNight:Int,totalGuest:Int,incomeAggregato:Double,tassoOccupazioneNotti:Double) {
  
        // tutte le prenotazioni che hanno il check-in e il check-out nel mese e nell'anno di riferimento
        let filtered:[HOReservation] = self.getAllFiltered(for: year, month: month,subRef: sub,notConsiderCheckOut: false)
        // isoliamo le prenotazioni che hanno il checkIn uguale al base value
        let byCheckIn = filtered.filter({
          
            guard let involved = $0.yyMMInvolved else { return false }
            
            if let month {
               return involved.in == (year,month)
            }
            else {
               return involved.in.yy == year
            }

        })
        // isoliamo le prenotazioni che hanno il checkOut uguale al base value
        let byCheckOut = filtered.filter({
            
            guard let involved = $0.yyMMInvolved else { return false }
            
            if let month {
                return involved.out == (year,month)
            }
            else {
                return involved.out.yy == year
            }
        })
        // recuperiamo il primo valore. Il numero di arrivi associati al base value
        let arrivalCount = byCheckIn.count // first Info
        
        // prendiamo il numero di notti involved nel mese di checkIn
        let nightsFromCheckIn = byCheckIn.reduce(into:0) { partialResult, reservation in
             
             partialResult += (reservation.ddInvolvedPerMonth?.mmIn ?? 0)
         }
        // prendiamo il numero di notti involved nel mese di checkOUT
        let nightsFromCheckOut = byCheckOut.reduce(into:0) { partialResult, reservation in
            
            partialResult += (reservation.ddInvolvedPerMonth?.mmOut ?? 0)
        }
        // anche se il report è annuale, nel caso di cavalli ci saranno due mesi diversi e quindi il valore ritorna corretto
        let nights = nightsFromCheckIn + nightsFromCheckOut // second Info
        
        // il numero di guest è preso solo dagli arrivi
        let guests = byCheckIn.reduce(into:0) { partialResult, reservation in
             
             partialResult += (reservation.pax ?? 0)
         } // third info
        
        let incomeByCheckIn = getIncomeDDbased(from: byCheckIn, on: \.ddInvolvedPerMonth?.mmIn, viewModel: viewModel)
        
        let incomeByCheckOut = getIncomeDDbased(from: byCheckOut, on: \.ddInvolvedPerMonth?.mmOut, viewModel: viewModel)
        
        let income = incomeByCheckIn + incomeByCheckOut
        
        // tasso di occupazine
        // notti / notti disponibili
        
        let subUnitCount:Int = {
            
            guard sub == nil else { return 1}
            // in teoria essendoci un valore diverso da nil il count dal viewModel non può tornare zero
            return viewModel.subUnitCount
            
        }()
        
        let nottiAvaible:Int = {
           
            var dd:Int = 0
            
            if let month {
                
                dd = viewModel.getDDOn(monthOrdinal: month)
            }
            else {
                dd = viewModel.currentDDOnFetchYY }
            
            return dd * subUnitCount
        }()
        
        let tassoOccNotti = Double(nights) / Double(nottiAvaible)
       
        
        // pernottamenti / pernottamenti possibili
        
        
        return (arrivalCount,nights,guests,income,tassoOccNotti)
        

    } */// possibile deprecazione
    /// Con il path bisogna indicare su quali giorni, se quelli coinvolti nel checkIn o quelli coinvolti nel checkOut, si vuole prendere in considerazione. L'array delle prenotazioni deve essere coerente, e quindi deve contenere prenotazione selezionate in base al checkIn o in base al checkOut
    /// - Parameters:
    ///   - reservations: prenotazioni da iterare
    ///   - path: il path dei giorni coinvolti da considerare
    ///   - viewModel: viewModel
    /// - Returns: ritorna il valore delle entrate normalizzato su base giornaliera
    private func getIncomeDDbased(from reservations:[HOReservation],monthInterval:DateInterval,viewModel:HOViewModel) -> Double {
        
        var income:Double = 0
        
        for eachArrival in reservations {
            
            let optAssociated = viewModel.getOperation(from: eachArrival.refOperations ?? [])
            
            let valueReser = optAssociated?.first(where: {$0.writing?.imputationAccount == .pernottamento})
            
            if let pricePerNigh = valueReser?.amount?.pricePerUnit,
               let interval = eachArrival.occupacyInterval?.intersection(with: monthInterval) {
                
                let ddInvolved = viewModel.localCalendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
                
               // let night = duration / 86400
                let imponibile = pricePerNigh * Double(ddInvolved)
                income += imponibile
            } else { continue }
        }
        
        return income
    } // 14.10.24 non in uso
    
   /* private func getIncomeDDbasedDEPRECATA(from reservations:[HOReservation],on dailyPath:KeyPath<HOReservation,Int?>,viewModel:HOViewModel) -> Double {
        
        var income:Double = 0
        
        for eachArrival in reservations {
            
            let optAssociated = viewModel.getOperation(from: eachArrival.refOperations ?? [])
            
            let valueReser = optAssociated?.first(where: {$0.writing?.imputationAccount == .pernottamento})
            
            if let pricePerNigh = valueReser?.amount?.pricePerUnit,
               let nighsIn = eachArrival[keyPath: dailyPath] {
               
                let imponibile = pricePerNigh * Double(nighsIn)
                
                income += imponibile
            } else { continue }

        }
        
        return income
    }*/
    
   /* func getInformation(for year:Int?,month:Int?,sub:String?) -> (count:Int,totalNight:Int,totalGuest:Int,optAssociatedRef:[String]) {
        
        let filtered:[HOReservation] = self.getAllFiltered(for: year, month: month,subRef: sub)
        
        /*let filtered = filteredOne.filter({
            
            guard let sub else { return true }
            return $0.refUnit == sub
        })*/
        
        let parzialCount = filtered.count
        let nights = filtered.reduce(into:0) { partialResult, reservation in
            
            partialResult += (reservation.notti ?? 0)
        }
        
        let guests = filtered.reduce(into:0) { partialResult, reservation in
            
            partialResult += (reservation.pax ?? 0)
        }
        
        let optRefAsso = filtered.compactMap({$0.refOperations}).flatMap({$0})
        
        return (parzialCount,nights,guests,optRefAsso)
        
    }*/ // deprecata per update
    
   /* private func getAllFiltered(for sub:String?) -> [HOReservation] {
        return []
    }*/
    
    private func getAllFilteredBy(year:Int,notConsiderCheckOut:Bool) -> [HOReservation] {
        // non potranno esserci prenotazioni superiori l'anno. Probabilmente il cap sarà molto meno.
        if notConsiderCheckOut {
            
            let value = self.all.filter({
                
                $0.yyInvolved?.in == year
            })
            
            return value
            
        } else {
            
            let value = self.all.filter({
               
               year == $0.yyInvolved?.in ||
               year == $0.yyInvolved?.out
                    
            })
            
            return value
        }
        
    }
    
    /*private func getAllFilteredBy(yyMM:(Int,Int),base:[HOReservation],notConsiderCheckOut:Bool) -> [HOReservation] {
        
        if notConsiderCheckOut {
            
            let value = base.filter({
                
                if let involved = $0.yyMMInvolved?.in {
                    return involved == yyMM
                } else { return false }
            })
            
            return value
            
        } else {
            
            let value = base.filter({
                
             
                
               if let involved = $0.yyMMInvolved {
                    
                   return involved.in == yyMM ||
                        involved.out == yyMM
                    
                } else {
                    return false
                }
            })
            
            return value
        }
        
    }*/ // deprecata
    
    /// se il booleano notConsiderCheckOut è false viene considerato l'anno e il mese di checkIn e checkOut. Di default è true e quindi filtrerà solo per anno e mese di checkIn. Si può filtrare per singoli parametri, ma per il mese è necessario anche l'anno.
    func getAllFiltered(year:Int,subRef:String?,notConsiderCheckOut:Bool = true) -> [HOReservation] {
            
        let base = self.getAllFilteredBy(year: year,notConsiderCheckOut: notConsiderCheckOut)
        
        guard let subRef else { return base }
        
        let baseByUnit:[HOReservation] = base.filter({$0.refUnit == subRef})
        
        return baseByUnit
        
        
      //  guard let year else { return base }
            
      //  guard let month else { return baseByUnit }
        
       // return self.getAllFilteredBy(yyMM: (year,month), base: baseByUnit, notConsiderCheckOut: notConsiderCheckOut)
                    
    }

    
   /* func getAllFiltered(for year:Int?,month:Int?,subRef:String?,notConsiderCheckOut:Bool = true) -> [HOReservation] {
            
        let base:[HOReservation] = {
            
            guard let subRef else { return self.all }
            let values = self.all.filter({$0.refUnit == subRef})
            return values
        }()
            
            guard let year else { return base }
            
            let filterByYear = base.filter({
                
                if let current = $0.yearIn {
                    
                    if notConsiderCheckOut { return year == current.yyIn  }
                    else { return year == current.yyIn || year == current.yyOut }
                    
                } else { return false }

            })
            
            guard let month else { return filterByYear }
            
            let filteredByMonth = filterByYear.filter({
                
                if let value = $0.monthInOrdinal {
                    
                    if notConsiderCheckOut { return month == value.mmIn }
                    else { return month == value.mmIn || month == value.mmOut }
                
                } else { return false }
                
            })
            
            return filteredByMonth
            
    }
   */ // chiusa per update 24.09.24
    /// l'anno è mandatory e poi si può filtrare per mese
   /* private func getAllFiltered(for year:Int?,month:String?) -> [HOReservation] {
        /// da modificare una volta sistemano il filterPack
            guard let year else { return self.all }
            
            let filterByYear = self.all.filter({
                
                if let current = $0.yearIn {
                    return year == current.yyIn || year == current.yyOut
                } else { return false }
                
            })
            
            guard let month else { return filterByYear }
            
            let filteredByMonth = filterByYear.filter({
                
                if let value = $0.monthIn?.simpleDescription() {
                    
                    return value == month
                } else { return false }
                
            })
            
            return filteredByMonth
            
    }*/ // deprecata
}


