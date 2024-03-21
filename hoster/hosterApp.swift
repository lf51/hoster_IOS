//
//  hosterApp.swift
//  hoster
//
//  Created by Calogero Friscia on 28/02/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import GoogleSignIn

class AppDelegate:NSObject,UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
}

@main
struct hosterApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /*init() {
        
        FirebaseApp.configure()
        // disattivare raccolta dati
    }*/
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
