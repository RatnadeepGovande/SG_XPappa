//
//  BlockUserServices.swift
//  App411
//
//  Created by osvinuser on 8/30/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


extension BlockedListViewController {


    // MARK: - Blocked User List API.
    
    internal func blockUserListAPI() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.blockListRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    self.arrayBlockedList.removeAll()
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let notificationList = jsonResult["user"] as? [Dictionary<String, AnyObject>] {
                                
                                for notificationInfoObj in notificationList {
                                    
                                    if let notificationInfoMapperObj = Mapper<AUserInfoModel>().map(JSONObject: notificationInfoObj) {
                                        
                                        self.arrayBlockedList.append(notificationInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            self.tableView_Main.setBackGroundOfTableView(arrayBlockedList: self.arrayBlockedList)
                            
                        }
                        
                        self.tableView_Main.reloadData()
                        
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
    
    
    
    internal func unBlockUserRequestApi(friendId: String, indexRemove: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //block_user
        Methods.sharedInstance.showLoader()
        
        //auth_token,friend_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(friendId)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.unblockUserRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        self.arrayBlockedList.remove(at: indexRemove)
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                    }
                    
                } else {
                    
                    print("Worng data found.")
                }
                
                self.tableView_Main.setBackGroundOfTableView(arrayBlockedList: self.arrayBlockedList)
                
                self.tableView_Main.reloadData()
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
}
