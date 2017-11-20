//
//  SignUpViewServices.swift
//  App411
//
//  Created by osvinuser on 8/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


extension SignUpPasswordViewController {

    // MARK:- Call Sign Up API
    
    func callSignUpAPI() {
        
        Methods.sharedInstance.showLoader()
        
        let deviceToken: String = UserDefaults.standard.value(forKey: "device_token") as? String ?? ""
        
        let paramsStr = "email=\(self.params["email"] ?? "")&password=\(self.params["password"] ?? "")&fullname=\(self.params["fullname"] ?? "")&dob=\(self.params["dob"] ?? "")&latitute=\(appDelegateShared.userCurrentLocation.latitude)&longitute=\(appDelegateShared.userCurrentLocation.longitude)&device_token=\(deviceToken)"
        
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.signUpFunction, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.signUpVerifyView = UIViewSignUPVerificationView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                            
                            self.signUpVerifyView.delegate = self;
                            
                            self.signUpVerifyView.textField_Verification.delegate = self
                            
                            self.signUpVerifyView.label_ShowVerfiyMsg.text = "Enter it below to verify " + self.params["email"]!
                            
                            self.view.addSubview(self.signUpVerifyView)
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                        /*
                         let user = Mapper<AUserInfoModel>().map(JSONString: response as! String)
                         print(user?.email ?? "email not found")
                         */
                        
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
    
    
    internal func sendOTPForVerification() {
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "otp=" + strOTP
        
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.verifyEmail, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONObject: jsonResult["user"]) {
                                
                                print(userInfoObj.email ?? "email Not Found")
                                
                                if let JSONString = Mapper().toJSONString(userInfoObj, prettyPrint: true) {
                                    
                                    //User Info
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                    UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                    
                                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                                    
                                    print(userDataStr)
                                    
                                }
                                
                            }
                            
                            // Create login session.
                            UserDefaults.standard.set(true, forKey: "loginsession")
                            
                            self.performSegue(withIdentifier: "segueUploadPic", sender: self)
                            
                            appDelegateShared.allocLayerClient()
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                    } else {
                        
                        print("Wrong data found.")
                        
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
    
    
    //MARK:- resend OTP at email.
    internal func resendOTPToUserOnEmail() {
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = ""
        
        // print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.resentOTP, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
                        
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
