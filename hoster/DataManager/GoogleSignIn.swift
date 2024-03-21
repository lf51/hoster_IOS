//
//  GoogleSignIn.swift
//  hoster
//
//  Created by Calogero Friscia on 21/03/24.
//

import Foundation
import Firebase
import GoogleSignIn
///Google SignIn
extension HOAuthManager {
    
     func startSignInWithGoogle() {
        
        Task {
            do {
                try await googleFlowSignIn()
            } catch let error {
                self.isLoading = nil
                print("[CATCH ERROR]_\(error.localizedDescription)")
               // throw URLError(.badURL) // da customizzare
               // throw error
            }
            
        }
    }
    
    private func googleFlowSignIn() async throws {
        
        print("[CALL]_googleFlowSignIn")
     
        guard let topVC = CSUtilities.shared.topViewController() else {
            // throw
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            print("[ERROR]_noTokenID")
            throw URLError(.cannotConnectToHost)
        }
    
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken)
    
        print("credential Provider:\(credential.provider)")
        
        try await self.signIn(with: credential, from: .google)
        
    }
}
