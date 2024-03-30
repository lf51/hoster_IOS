//
//  HOPortale.swift
//  hoster
//
//  Created by Calogero Friscia on 22/03/24.
//

import Foundation

enum HOPortaleCases {
    
    case booking
    case airbnb
    case direct
    
    case custom(_ name:String)
    
    func label() -> String {
        
        switch self {
        case .booking:
            return "booking.com"
        case .airbnb:
            return "airbnb"
        case .direct:
            return "direct book"
        case .custom(let label):
            return label
        }
        
    }
}


struct HOPortaleModel {
    
    let uid:String
    
    let label:String
    
    let rateoCommissione:CGFloat
    let rateoTransazione:CGFloat
    let rateoVAT:CGFloat
    
    
    
    
    
    
}
