//
//  HOCloudData.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation

struct HOCloudData {
    
    var currentUser:HOUserDataModel
    var currentWorkSpace:WorkSpaceModel?
    
    init(userAuthUid:String) {
        
        self.currentUser = HOUserDataModel(uid: userAuthUid)
        
    }
    /// Verifica che l'id del current user sia lo stesso dello user arrivato dal publisher. Se affermativo aggiorna il currentUser, in caso contrario Throw
    mutating func checkUidCoerenceAndUpdate(for updatedDate:HOUserDataModel) throws {
    
        guard updatedDate.uid == currentUser.uid else {
            // vi è un errore poichè l'uid con cui abbiamo init non coincide con l'uid che ci ritorna dal server
            throw HOCustomError.erroreGenerico(
                problem: "Dati Corrotti. Id di autentica diverso da id su firebase",
                reason: "Errore di salvataggio dei dati",
                solution: "Eliminare account e riprovare da zero")
        }
        self.currentUser = updatedDate
    }
}
