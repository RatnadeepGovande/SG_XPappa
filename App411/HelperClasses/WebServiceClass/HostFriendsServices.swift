//
//  HostFriendsServices.swift
//  App411
//
//  Created by osvinuser on 8/2/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension HostNameFriendListViewController {
    
    // Get Friend Request List.
    func getFriendRequestList() {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.friendList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let friendList = jsonResult["user"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                        
                                        print(friendInfoMapperObj.email ?? "")
                                        self.array_FriendList.append(friendInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            self.tableView_Main.reloadData()
                            //self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            
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
                
                self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    // Get Friend Request List.
    func getHostsListForEvent(event_Id: String) {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // auth_token,event_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(event_Id)"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.hostsList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let friendList = jsonResult["host_name"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                        
                                        print(friendInfoMapperObj.email ?? "")
                                        self.array_FriendList.append(friendInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            self.tableView_Main.reloadData()
                            //self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            
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
                
                self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    
    func sendInvitationForEvent(inviteUserIds: String, event_Id: String) {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_id=\(inviteUserIds)&event_id=\(event_Id)"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.event_invite, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            // Get View Controller
                            for viewController in (self.navigationController?.viewControllers)! {
                                if viewController is HomeEventsViewController {
                                    self.navigationController?.popToViewController(viewController, animated: false)
                                }
                            }
                            
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
    
    func addHostsForEvent(inviteUserIds: String, event_Id: String, hostStatus: Bool = true) {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        // auth_token,event_id,host_id,status =0 for remove host 1 for add host
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&host_id=\(inviteUserIds)&event_id=\(event_Id)&status=\(hostStatus == true ? 1 : 0)"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.addHostsToEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
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
