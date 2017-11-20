//
//  FindFriendServices.swift
//  App411
//
//  Created by osvinuser on 8/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension FindFriendViewController {

    //MARK:- send Friend Request API.
    internal func sendFriendRequestAPI() {
        
        let ids = array_SelectedFriendList.flatMap { String($0.id ?? 0) }
        print("Get Friends Ids:- \(ids)")
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let joinIdsString = ids.joined(separator: ",")
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_ids=\(joinIdsString)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.friendRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.array_SelectedFriendList.removeAll()
                            self.tableView_Main.reloadData()
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
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
    
    
    
    //MARK:- Search Friend API
    func searchFriendAPI(name: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        dataLoading = true
        tableView_Main.reloadData()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&search_letter=\(name)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.searchFriend, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                print(response)
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        self.array_FriendList.removeAll()
                        
                        if responeCode == true {
                            
                            if let friendList = jsonResult["user"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    if let friendInfoMapperObj = Mapper<AFindFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                        self.array_FriendList.append(friendInfoMapperObj)
                                    }
                                }
                            }
                            
                            print(self.array_FriendList)
                            
                        } else {
                            
                            print("Wrong data")
                            
                        }
                        
                        self.dataLoading = false
                        self.tableView_Main.reloadData()
                        
                    } else {
                        print("Worng data found.")
                    }
                    
                }
                
            } else {
                
                self.dataLoading = false
                self.tableView_Main.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    
}
