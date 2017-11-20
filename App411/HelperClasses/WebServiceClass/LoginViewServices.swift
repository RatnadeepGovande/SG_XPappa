//
//  LoginViewServices.swift
//  App411
//
//  Created by osvinuser on 8/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension LoginViewController {

    //MARK:- user Login API.
    func userLoginAPI() {
        
        Methods.sharedInstance.showLoader()
        
        let deviceToken: String = UserDefaults.standard.value(forKey: "device_token") as? String ?? ""
        
        //let paramsStr = "email=\(self.params["email"] ?? "")&password=\(self.params["password"] ?? "")&device_token=\(deviceToken)"
        let paramsStr = "email=\(self.params["email"] ?? "")&password=\(self.params["password"] ?? "")&device_token=\(deviceToken)&latitute=\(appDelegateShared.userCurrentLocation.latitude)&longitute=\(appDelegateShared.userCurrentLocation.longitude)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.signIn, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        // print(responeCode)
                        
                        if responeCode == true {
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONObject: jsonResult["user"]) {
                                
                                if let JSONString = Mapper().toJSONString(userInfoObj, prettyPrint: true) {
                                    
                                    //User Info
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                    UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                    
                                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                                    
                                    print(userDataStr)
                                    
                                }
                                
                            }
                            
                            
                            if let filterInfoList = jsonResult["filter"] as? [Dictionary<String, AnyObject>] {
                            
                                Singleton.sharedInstance.filterSelectedListInfo.removeAll()

                                for filterInfoObj in filterInfoList {
                                    if let filterInfoMapperObj = Mapper<ASelectedFiltersInfoModel>().map(JSONObject: filterInfoObj) {
                                        Singleton.sharedInstance.filterSelectedListInfo.append(filterInfoMapperObj)
                                    }
                                }
                                
                                UserDefaults.standard.set(filterInfoList, forKey: "selectedFilter")
                                
                            }
                            
                            
                            if let distance = jsonResult["distance"] as? String {
                                Singleton.sharedInstance.filterDistance = distance
                                UserDefaults.standard.set(distance, forKey: "selectedDistance")
                            }
                            
                            // print(Singleton.sharedInstance.filterSelectedListInfo)
                            // print(Singleton.sharedInstance.filterDistance)

                            
                            // Create login session.
                            UserDefaults.standard.set(true, forKey: "loginsession")
                            
                            self.performSegue(withIdentifier: "segueLogIn", sender: self)
                            
                            appDelegateShared.allocLayerClient()
                            
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
