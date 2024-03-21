//
//  SignInView.swift
//  hoster
//
//  Created by Calogero Friscia on 28/02/24.
//

import SwiftUI
import Firebase
import MyPackView
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignInWithAppleButtonViewRepresentable:UIViewRepresentable {
   
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        //
    }
    
}

struct SignInView: View {
   
    @ObservedObject var authManager: HOAuthManager
  //  @State private var email:String = ""
    let backgroundColorView:Color
    
    var body: some View {

        ZStack {
            
            Rectangle()
                .fill(backgroundColorView.gradient)
                .edgesIgnoringSafeArea(.all)
                .zIndex(0)
  
          VStack(alignment: .center) {
              
              HStack(alignment:.top) {
                  
                  VStack(alignment:.leading,spacing: -5) {
                      
                      Text("Hoster!") // foodies // foodist // foodz / foodish / weFoodies / Foodies! / WeeFoodies / foodie
                            .font(.system(.largeTitle, design: .rounded,weight: .bold))
                            .foregroundStyle(Color.black)
                      Text("for manager")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.seaTurtle_4)
                  }
                  
                  Spacer()
 
              }

              VStack {
                  
                  let lastLogin = self.authManager.getLastProvider()
                  let disable:(google:Bool,apple:Bool) = {
                     
                      if let lastLogin {
                          
                          switch lastLogin {
                          case .google:
                              return (false,true)
                          case .apple:
                              return (true,false)
                          }
                          
                      } else {
                          return (false,false)
                      }
                      
                  }()
                  
                  Spacer()
                  
                  Image(systemName: "house")
                      .resizable()
                      .scaledToFit()
                      .foregroundStyle(Color.black)
                      .frame(maxWidth:500)
                      .padding(.vertical,60)
                  
                  Spacer()
                  
                  GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                       self.authManager.signIn(with: .google)
                  }
                  .disabled(disable.google)
                  .opacity(disable.google ? 0.6 : 1.0)
                  
                  Button(action: {
                       self.authManager.signIn(with:.apple) 
                  }, label: {
                      SignInWithAppleButtonViewRepresentable(type: .continue, style: .black)
                          .allowsHitTesting(false)
                  })
                  .disabled(disable.apple)
                  .opacity(disable.apple ? 0.6 : 1.0)
                  .frame(height: 55)
                  
                  VStack(spacing: 5) {
                      
                      Button(action: {sendProviderAlert()}, label: {
                          
                          HStack {
                              Text("Last login with: \(lastLogin?.rawValue ?? "never logged in")")
                                  .font(.system(.caption, design: .monospaced, weight: .black))
                                  .foregroundStyle(Color.black)
                                  .opacity(0.8)
                              
                              Image(systemName:"arrow.up.forward.square")
                                  .foregroundStyle(Color.black)
                                  .opacity(lastLogin == nil ? 0.4 : 1.0)
                              
                          }
                      }).disabled(lastLogin == nil)
                      
                      Button(action: {self.sendInfoAlert()}, label: {
                          
                          HStack {
                              
                              Text("Info Dati Raccolti")
                                  .font(.system(.subheadline, design: .monospaced, weight: .light))
                                  .foregroundStyle(Color.seaTurtle_4)
                              
                              Image(systemName:"info.circle")
                                  .foregroundStyle(Color.seaTurtle_4)
                          }
                          
                      })
                  }
                  
                  Spacer()
                  
                  Image(systemName: "house")
                      .resizable()
                      .scaledToFit()
                      .frame(width: 50, height: 50)
              }
              .frame(maxWidth:700)
              
          }
          .padding(.horizontal)
   
      }
        .csAlertModifier(isPresented: $authManager.showAlert, item: self.authManager.alertItem)

  }
    
    // Method
    
    private func sendInfoAlert() {
        
        let alert = AlertModel(
            title: "Privacy",
            message: "I dati ricevuti dal provider serviranno a creare un' identità utente univoca cui associare i dati salvati. Non sarà fatto nessun altro uso.\nImporteremo i seguenti dati:\n• Indirizzo email\n• userName\n• foto profilo")
        
        self.authManager.alertItem = alert
        
    }
    
    private func sendProviderAlert() {
        
        let alert = AlertModel(
            title: "Info Provider",
            message: "Le informazioni sull'ultimo login sono salvate sul device per permettere all'utente di ricordare il provider utilizzato. Clicca su 'elimina' per cancellare questa informazione e procedere all'autenticazione con altro provider.",
            actionPlus: ActionModel(title: .elimina, action: {
                self.authManager.deleteLastProvider()
            }))
        
        self.authManager.alertItem = alert
    }
    
}

/*#Preview {
    SignInView()
}*/
