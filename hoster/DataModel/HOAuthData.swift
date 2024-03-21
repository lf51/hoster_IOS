//
//  HOAuthData.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import Firebase

struct HOAuthData {
    
    let uid:String
    let email:String?
    let userName:String?
    let photoUrl:URL?
    let dataRegistrazione:Date?
    let lastSignIn:Date?
    let providersID:[String]

    init(from user:User) {
      
        self.uid = user.uid
        self.email = user.email
        self.userName = user.displayName
        self.photoUrl = user.photoURL
    
        self.dataRegistrazione = user.metadata.creationDate
        self.lastSignIn = user.metadata.lastSignInDate
        self.providersID = user.providerData.map({$0.providerID})
        
    }

}
