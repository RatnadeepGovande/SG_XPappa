//
//  FiltersApplyServices.swift
//  App411
//
//  Created by osvinuser on 8/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension FilterViewController {

    func applicationFiltersSelectedCategories(selectedCategories: [AFilterCategoriesInfoModel], radius: Int) {
    
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // Get selected categories ids.
        let ids = selectedCategories.flatMap { String($0.id ?? 0) }
        print("Get Friends Ids:- \(ids)")
        
        let joinIdsString = ids.joined(separator: ",")
        
        
        Methods.sharedInstance.showLoader()
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_category_ids=\(joinIdsString)&distance=\(radius)&latitute=\(appDelegateShared.userCurrentLocation.latitude)&longitute=\(appDelegateShared.userCurrentLocation.longitude)"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.applyFliter, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            // Get Old User data.
                            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                                
                                // Update auth token.
                                userInfoObj.authentication_token = jsonResult["auth_token"] as? String ?? ""
                                
                                // create json string.
                                if let JSONString = Mapper().toJSONString(userInfoObj, prettyPrint: true) {
                                    
                                    // save new user data.
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                    UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                    
                                    // get user data.
                                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                                    
                                    print(userDataStr)
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventListAPIReloadNotification"), object: self, userInfo: ["":""])
                                    
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
                        
                                                
                            self.dismiss(animated: true, completion: nil)
                            
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
