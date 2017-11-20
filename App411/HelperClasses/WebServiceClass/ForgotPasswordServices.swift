//
//  ForgotPasswordServices.swift
//  App411
//
//  Created by osvinuser on 8/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension ForgotPasswordViewController {

    //MARK:- resend OTP at email.
    internal func sendEmailForForgotPassword() {
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "email=\(self.params["email"] ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.forgotPassword, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            })
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
    }
    
}
