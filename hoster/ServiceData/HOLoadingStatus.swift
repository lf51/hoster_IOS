//
//  HOLoadingStatus.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
// Valutare spostamento su framwork
enum HOLoadingCase {
    
    case inFullScreen
    case inBackground
    
}

struct HOLoadingStatus {
    
    let uid:String
    
    private(set) var loadCase:HOLoadingCase?
    private(set) var loadDescription:String?
    
    var log:LoadingLog {
        
        guard let _ = loadCase,
              let _ = loadDescription else { return .completed}
        return .active
    }
    
    init(loadCase:HOLoadingCase,description:String) {
        self.uid = UUID().uuidString
        self.loadCase = loadCase
        self.loadDescription = description
    }
    
    mutating func nullStatus() {
        
        self.loadCase = nil
        self.loadDescription = nil
        
    }
    
    enum LoadingLog {
        case completed,active
    }
}
