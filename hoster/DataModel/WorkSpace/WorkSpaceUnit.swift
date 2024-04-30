//
//  WorkSpaceUnit.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

/// Contiene le unità che compongono un WorkSpace. Dati salvati in subcollection, dentro il documento, ma fuori il body del workspace
struct WorkSpaceUnit:HOProStarterPack {
    
    let uid:String
    
    var all:[HOUnitModel]
    /// la label corrisponde alla label dell'intero workspace per entrambi i type
    var main:HOUnitModel {
        get { self.getMainUnit() }
        set { self.setMainUnit(to: newValue) }
    }
    
    var subs:[HOUnitModel]? {
        get { self.getSubUnits() }
        set { self.setSubUnits(to: newValue) }
    }
   
    init(focusUid:String,allUnit:[HOUnitModel] = []) {
       // self.uid = UUID().uuidString
        self.uid = focusUid
        self.all = allUnit
       // self.service = WorkSpaceInternalService()
       // self.wholeUnit = UnitModel()
    }

}

/// Managing subUnits
extension WorkSpaceUnit {
    
    private func getSubUnits() -> [HOUnitModel]? {
        
        guard !self.all.isEmpty else { return nil }
        
        let subs = self.all.filter({$0.unitType == .sub})
       
        guard !subs.isEmpty else { return nil }
        
        return subs
        
    }
    
    mutating private func setSubUnits(to newArray:[HOUnitModel]?) {
        
        self.all.removeAll(where: { $0.unitType == .sub })
        
        if let newArray {
            
            self.all.append(contentsOf: newArray)
            
        } else { return }
        
    }
}
/// Managing Main Unit
extension WorkSpaceUnit {
    
    private func getMainUnit() -> HOUnitModel {
        
        guard !self.all.isEmpty,
              let main = self.all.first(where: {$0.unitType == .main}) else {
            return HOUnitModel(type: .main)
        }
        
        return main
    }
    
    mutating private func setMainUnit(to newValue:HOUnitModel) {
        
        guard newValue.unitType == .main else { return } // verifica che il valore sia main
        
        guard !self.all.isEmpty else {
            self.all = [newValue]
            return
        }
        
        let existingValue = self.all.first(where: {$0.uid == newValue.uid})
        
        guard existingValue != nil else {
            self.all.append(newValue)
            return
        }
        
        self.all.removeAll(where: {$0.uid == newValue.uid})
        self.all.append(newValue)
        
    }
}
