//
//  HOCustomError.swift
//  hoster
//
//  Created by Calogero Friscia on 18/03/24.
//

import Foundation

enum HOCustomError:Error,LocalizedError {
    
    case mainRefCorrotto
    case erroreGenerico(problem:String? = nil,reason:String? = nil,solution:String? = nil)
    
    var errorDescription: String? {
        
        switch self {
            
        case .mainRefCorrotto:
            return NSLocalizedString("Collezione di riferimento mancante. Fetch dei dati non possibile", comment: "Collegamento Database Corrotto")
            
        case .erroreGenerico(let problem,let reason,let solution):
    
            guard (problem != nil) ||
                  (reason != nil) ||
                  (solution != nil) else {
                
                return NSLocalizedString("ERRORE GENERICO", comment: "Errore non specificato")
            }
            
            let problem = problem == nil ? "" : "[PROBLEMA]: \(problem!)"
            let reason = reason == nil ? "" : "[MOTIVO]: \(reason!)"
            let solution = solution == nil ? "" : "[SOLUZIONE]: \(solution!)"
            
            return NSLocalizedString("\(problem)\n\(reason)\n\(solution)", comment: "Errore Generico")
       
        }
        
    }
    
   /* var errorDescription: String? {
        
        switch self {
        case .mainRefCorrotto:
            return NSLocalizedString("Collezione di riferimento mancante. Fetch dei dati non possibile", comment: "Collegamento Database Corrotto")
            
        case .erroreGenerico(let problem,let reason,let solution):
    
            let stringTitle = {
                
                guard (problem != nil) ||
                      (reason != nil) ||
                      (solution != nil) else {
                    return "ERRORE GENERICO"
                }
                
                return "ERRORE"
            }()
            
            let problem = problem == nil ? "" : "[PROBLEM]:\(problem!)"
            let reason = reason == nil ? "" : "[REASON]:\(reason!)"
            let solution = solution == nil ? "" : "[SOLUTION]:\(solution!)"
            
            return NSLocalizedString("\(stringTitle)\n\(problem)\n\(reason)\n\(solution)", comment: "Errore Generico")
       
        }
        
    }*/
}


