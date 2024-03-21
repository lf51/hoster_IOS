//
//  AuthManager.swift
//  hoster
//
//  Created by Calogero Friscia on 28/02/24.
//

import Foundation
import Firebase
import MyPackView
// su github i file sono fuori la cartella authentication
@MainActor
final public class HOAuthManager:NSObject, ObservableObject {

    @Published private(set) var authData:HOAuthData?
    
    @Published var showAlert: Bool = false
    @Published var alertItem: AlertModel? {didSet {showAlert = true}}

    @Published var isLoading: Bool?
    
    /// necessaria per Apple Sign In
    /*fileprivate*/ var currentNonce: String?
    
     public override init() {
        print("[INIT]_Hoster_Authentication")
     // checkUserSignedIn()
        super.init()
       // signOutCurrentUser()
      // deleteCurrentUser()
         checkUserSignedIn()
       
    }
    /// send alert with Dispatch(0.5'')
   private func sendDispatchAlert(alertModel: AlertModel) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.alertItem = alertModel }
    }
    
//Fine Classe
}
/// log in - sign out - delete
extension HOAuthManager {
    
    private func checkUserSignedIn() {
        
         self.isLoading = true
        
         guard let user = Auth.auth().currentUser else {
             
             print("[AUTH_FAIL]_NO USER IN")
            // self.authCase = .noAuth
             self.isLoading = nil
             return
         }

        print("[AUTH]_USER IN")
        self.authData = HOAuthData(from: user)//AuthenticationObject(user: user)
       // self.userAuthData = UserAuthData(from: user)
        
       // self.userManager = UserManager(userAuthUID: user.uid) // da verificare posizionamento
       // withAnimation {
            self.isLoading = nil
       // }
         
     }

    func logOutUser() {
        
        self.alertItem = AlertModel(
            title: "Logout",
            message: "Desideri uscire dall'Applicazione?",
            actionPlus: ActionModel(
                title: .conferma,
                action: {
                    self.signOutCurrentUser()
                }))
    }
    /// permette di passare un'azione da eseguire dopo l'eliminazione dell'utente. Utile per eradere i dati nel cloud
    func eliminaAccount() {
        
        self.alertItem = AlertModel(
            title: "Eliminazione Account",
            message: "L'eliminazione dell'account è irreversibile e comporta la perdita di ogni dato.",
            actionPlus: ActionModel(
                title: .elimina,
                action: {
                    self.deleteCurrentUser()
                    
                }))
        
    }

    private func deleteCurrentUser() {
        
        if let user = Auth.auth().currentUser {
            
            user.delete { error in
                
                guard error == nil else {
                    
                    print("DeleteStage - Error:\(error?.localizedDescription ?? "")")
                    
                    self.alertItem = AlertModel(
                        title: "Autenticazione Necessaria",
                        message: "\(error?.localizedDescription ?? "")",
                        actionPlus: ActionModel(
                            title: .continua,
                            action: {
                                self.signOutCurrentUser()
                            })

                    )
                    return
                }
                // per eliminare il database implementaremo una extension su firebase. Nessuna azione manuale da implementare
                    self.authData = nil
                    self.deleteLastProvider()
                    
                    self.sendDispatchAlert(alertModel: AlertModel(
                        title: "Dispiace Salutarti :-(",
                        message: "Il tuo Account è stato correttamente eliminato."))
                
            }
        }
    }
    
   private func signOutCurrentUser() {
        
        print("SignOutStage")
        
       let firebaseAuth = Auth.auth()
        
        do {
            
            try firebaseAuth.signOut()
            self.authData = nil
           // self.userAuthData = UserAuthData()
           // self.userManager = nil
           // self.openSignInView = true
          //  self.currentUser = nil
         //   self.utenteCorrente = nil
            
           // self.authCase = .noAuth
    
            print("Sign-Out Successfully")
            
        } catch let signOutError as NSError {
            
            self.alertItem = AlertModel(
                title: "Errore Log-Out",
                message: "\(signOutError.localizedDescription)")
            print("Error signingOut: %@", signOutError)
        }
    }
}

/// General Sign in method
extension HOAuthManager {
    
    func signIn(with provider:HOProvidersOption) {
     
       print("[CALL]_signInWithProvider: \(provider.rawValue)")
       self.isLoading = true
        
       switch provider {
       case .google:
           startSignInWithGoogle()
       case .apple:
           startSignInWithAppleFlow()
       }

   }
    
    func signIn(with credential:AuthCredential,from provider:HOProvidersOption) async throws {
        print("[CALL]_signIN with credential and provider:\(provider.rawValue)")
       
        do {

            let authData = try await Auth.auth().signIn(with: credential)
            let user = authData.user

            self.authData = HOAuthData(from: user)//AuthenticationObject(user: user)
          
           // self.userAuthData = UserAuthData(from: user)
            // salviamo nello user default ultimo provider utilizzato per il log in
            self.setLastProvider(from: provider)
            
           // withAnimation {
                self.isLoading = nil
          //  }
            
        } catch let error {
            self.isLoading = nil
            self.authData = nil
            print("[SIGN_IN ERROR]_\(error.localizedDescription)") // da customizzare
        }

     }
    
    private func setLastProvider(from lastLoginOption:HOProvidersOption ) {
        
        UserDefaults.standard.set(lastLoginOption.rawValue, forKey: "LogInProvider")
    }
    
    func getLastProvider() -> HOProvidersOption? {
        
        let option = UserDefaults.standard.value(forKey: "LogInProvider") as? String
        
        guard let option else {
            
            return nil
        }
        
        let lastLogin = HOProvidersOption(rawValue: option)
    
        return lastLogin
    }
    
    func deleteLastProvider() {
        
        UserDefaults.standard.removeObject(forKey: "LogInProvider")
        
    }

}




