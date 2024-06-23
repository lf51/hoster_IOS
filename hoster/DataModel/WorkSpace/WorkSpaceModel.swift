//
//  WorkSpaceModel.swift
//  hoster
//
//  Created by Calogero Friscia on 06/03/24.
//

import Foundation
/// i dati sono articolati in sottoStruct per permettere un aggiornamento disgiunto dal firebase
struct WorkSpaceModel {
    
    var wsData:WorkSpaceData
    var wsUnit:WorkSpaceUnit
    
    var wsReservations:HOWsReservations
    var wsOperations:HOWsOperations

    var uid:String { self.wsData.uid }

    var wsType:WorkSpaceType { get { self.getWsType() } }
    var paxMax:Int { get { self.getMaxPax() } }
    
    var wsLabel:String {
        get { return self.wsUnit.main.label }
        set { self.wsUnit.main.label = newValue }
    }
    
    init(focusUid:String? = nil) {
        
        let uid = focusUid == nil ? UUID().uuidString : focusUid!
        
        self.wsData = WorkSpaceData(focusUid: uid)
        self.wsUnit = WorkSpaceUnit(focusUid: uid)
        
        self.wsReservations = HOWsReservations(focusUid: uid)
        self.wsOperations = HOWsOperations(focusUid: uid)
        
    }
    
    
    mutating func updateWs<D:HOProStarterPack>(with newData:D,in path:WritableKeyPath<Self,D>) throws {
        
        guard newData.uid == self.uid else {
            throw HOCustomError.erroreGenerico()
        }
        
        self[keyPath: path] = newData
       // self.wsData = newWsData
        
    }
    
   /* mutating func updateWsData(to newWsData:WorkSpaceData) throws {
        
        guard newWsData.uid == self.uid else {
            throw HOCustomError.erroreGenerico()
        }
        
        self.wsData = newWsData
        
    }
    
    mutating func updateWsUnit(to newWsUnit:WorkSpaceUnit) throws {
        
        guard newWsUnit.uid == self.uid else {
            throw HOCustomError.erroreGenerico()
        }
        
        self.wsUnit = newWsUnit
        
    } */
    
}

/// Logica PaxMax
extension WorkSpaceModel {
    
    private func getMaxPax() -> Int {
        
        if let subUnits = wsUnit.subs {
            
            let subUnitMax = subUnits.compactMap({$0.pax}).reduce(into: 0) { partialResult, pax in
                partialResult += pax
                
            }
            return subUnitMax
        } else {
            return wsUnit.main.pax ?? 0
        }
        
        
    }
}

/// Logica UnitType
extension WorkSpaceModel {
    
    private func getWsType() -> WorkSpaceType {
        
        if wsUnit.subs != nil { return .withSub }
        else { return .wholeUnit }
    }
    
}
