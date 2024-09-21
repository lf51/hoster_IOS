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
    
    
    /* func getAggregateOperationRef() -> [String] {
     
     let aggregate = self.all.compactMap({$0.refOperations})
     
     let joined = aggregate.flatMap({$0})
     
     return joined
     } */
    
    func getDatesOccupies(for year:Int?,month:Int?,sub:String?) {
        
     //   let reserv = self.getAllFiltered(for: year, month: month)
        
        
    }
    
    func getInformation(for year:Int?,month:Int?,sub:String?) -> (count:Int,totalNight:Int,totalGuest:Int,optAssociatedRef:[String]) {
        
        let filteredOne:[HOReservation] = self.getAllFiltered(for: year, month: month,unitRef: sub)
        
        let filtered = filteredOne.filter({
            
            guard let sub else { return true }
            return $0.refUnit == sub
        })
        
        let parzialCount = filtered.count
        let nights = filtered.reduce(into:0) { partialResult, reservation in
            
            partialResult += (reservation.notti ?? 0)
        }
        
        let guests = filtered.reduce(into:0) { partialResult, reservation in
            
            partialResult += (reservation.pax ?? 0)
        }
        
        let optRefAsso = filtered.compactMap({$0.refOperations}).flatMap({$0})
        
        return (parzialCount,nights,guests,optRefAsso)
        
    }
    
    private func getAllFiltered(for sub:String?) -> [HOReservation] {
        return []
    }
    /// se il booleano notConsiderCheckOut è false viene considerato l'anno e il mese di checkIn e checkOut. Di default è true e quindi filtrerà solo per anno e mese di checkIn
    func getAllFiltered(for year:Int?,month:Int?,unitRef:String?,notConsiderCheckOut:Bool = true) -> [HOReservation] {
        
            guard let year else { return self.all }
            
            let filterByYear = self.all.filter({
                
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


