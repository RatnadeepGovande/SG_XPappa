//
//  MethodsClass.swift
//  App411
//
//  Created by osvinuser on 6/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import CoreGraphics
import ObjectMapper


class Methods {
    
    static let sharedInstance = Methods()
    
    func showPercentageLoader() -> MBProgressHUD {
        guard let window = UIApplication.shared.windows.last else {
            return MBProgressHUD()
        }
        
        let progressHud = MBProgressHUD.showAdded(to: window, animated: true)
        progressHud.mode = .annularDeterminate
        progressHud.label.text = "Uploading"
        
        return progressHud
    }
    
    func showLoader() {
        
        DispatchQueue.main.async(execute: {
            let window = UIApplication.shared.windows.last
            MBProgressHUD.showAdded(to: window!, animated: true)
        })
        
    }
    
    func hideLoader() {
        
        DispatchQueue.main.async(execute: {
            let window = UIApplication.shared.windows.last
            MBProgressHUD.hide(for: window!, animated: true)
        })
        
    }
    

    func getUserInfoData() -> AUserInfoModel? {
    
        let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
        let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
        
        guard let userInfoModel = Mapper<AUserInfoModel>().map(JSONString: userDataStr) else {
            return nil
        }

        return userInfoModel
        
    }
    
    
    //MARK:- User Logout.
    func userlogout() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController: HomeLoginTypeViewController = storyboard.instantiateViewController(withIdentifier: "HomeLoginTypeViewController") as! HomeLoginTypeViewController
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: loginViewController)
        
        appDelegateShared.window?.rootViewController? = navigationController

        
        // Deauthenticate user after logout.
        LayerChatSingleton.sharedInstance.deauthenticateCurrentUser(layerClient: appDelegateShared.layerClient)
        
        
        // Remove Current User Data from local Data.
        UserDefaults.standard.removeObject(forKey: "userinfo")
        
        // Create login session.
        UserDefaults.standard.set(false, forKey: "loginsession")
        
    }
    
    func openURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
}
