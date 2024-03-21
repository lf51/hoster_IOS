//
//  CSUtilities.swift
//  hoster
//
//  Created by Calogero Friscia on 01/03/24.
//

import Foundation
import UIKit
import AuthenticationServices

final class CSUtilities {
    
    static let shared = CSUtilities()
    
    private init() { }
    
    @MainActor
    func topViewController(controller:UIViewController? = nil) -> UIViewController? {
        
       // let uiController = controller ?? UIApplication.shared.keyWindow?.rootViewController
        let uiController = controller ?? UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController}).last
            
        if let navigationController = uiController as? UINavigationController {
            
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = uiController as? UITabBarController {
            
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = uiController?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return uiController
        
    }
    
}
/// Necessaria per Apple sign In
extension UIViewController:ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}
