//
//  HOGuestType.swift
//  hoster
//
//  Created by Calogero Friscia on 06/04/24.
//

import Foundation

enum HOGuestType:Int {
    
    case single = 0
    case couple
    case group
    case family
    
}

extension HOGuestType:Codable { }
