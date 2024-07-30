//
//  WorkSpaceData.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

/// Contiene i dati del workSpace. Il body del documento su Firebase
struct WorkSpaceData:HOProStarterPack {
    
    static var defaultValue:WorkSpaceData { getDefaultValue() }
    
    let uid: String
    
   // var refPortali:[String]? // ??
    var otaChannels:[HOOTAChannel]? // setup utente
    var maxNightIn:Int? // setup utente
    var bedTypeIn:[HOBedType]? // setup utente
    var checkInTime:DateComponents? // setup utente
    
    var ivaSubject:Bool? // setup utente
    var cityTaxPerPerson:Double? // setup utente
    
    var costiTransazione:Double? // setup utente
    
    init(focusUid:String) {
        self.uid = focusUid
    }
    
    static private func getDefaultValue() -> Self {
        
        var defaultData = WorkSpaceData(focusUid: "Default_Value")
        
        defaultData.otaChannels = HOOTADefaultCase.getDefaultOTAChannel()
        defaultData.maxNightIn = 28
        defaultData.bedTypeIn = HOBedType.allCases 
        defaultData.checkInTime = DateComponents(hour:16,minute:0)
        defaultData.ivaSubject = false 
        defaultData.cityTaxPerPerson = 2.0//0.0
        defaultData.costiTransazione = 1.3
        
        return defaultData
        
    }
}

extension WorkSpaceData: Codable { }
