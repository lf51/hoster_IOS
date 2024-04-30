//
//  Miscellaneus.swift
//  hoster
//
//  Created by Calogero Friscia on 27/04/24.
//

import Foundation

enum HOAccWritingPosition {
    
    case dare
    case avere
}

enum HOAccWritingSign {
    case plus
    case minus
}


enum HOOperationTypeClassification {
    
    case scorte
    case corrente
    case pluriennale
    
}

enum HOOperationType {
    
    case acquisto
    case pagamento
    case consumo
    case resoPassivo
    
    case ammortamento //
    
    case vendita
    case resoAttivo
    case riscossione
    case regaliEMance
}
