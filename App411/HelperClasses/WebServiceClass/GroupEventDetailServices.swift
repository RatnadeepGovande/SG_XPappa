//
//  GroupEventDetailServices.swift
//  App411
//
//  Created by osvinuser on 8/17/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension GroupEventDetailViewController {

    internal func reportOrSpamGroupServiceFunction() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,group_id,content
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&group_id=\(groupId ?? 0)&content=jhsfksdfdks"
        print(paramsStr)
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.groupReportSpam, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    self.showAlert("Your group has been deleted.")
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        self.showAlertWithActions("Thanks for your feedback. Admin will take actions on this group.")
                        
                    }
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
        
    }
    
    internal func deleteGroupServiceFunction() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,group_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&group_id=\(groupId ?? 0)"
        print(paramsStr)
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.groupDelete, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        self.showAlertWithActions("Your group has been deleted.")

                    } else {
                        
                        self.showAlert(jsonResult["message"] as? String ?? "")
  
                    }
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
        
    }
    
    
    internal func joinOrUnjoinGroupServiceFunction() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,group_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&group_id=\(groupId ?? 0)"
        print(paramsStr)
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.existGroup, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        self.showAlertWithActions(jsonResult["message"] as? String ?? "")

                    } else {
                        
                        self.showAlert(jsonResult["message"] as? String ?? "")

                    }
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
        
    }
    
    internal func showGroupEventDetailServiceFunction() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,group_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&group_id=\(groupId ?? 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.groupDetailEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        if let eventList = jsonResult["detail"] as? Dictionary<String, AnyObject> {
                            
                            if let groupEventMapperObj = Mapper<AGroupEventInfoModel>().map(JSONObject: eventList) {
                                
                                self.groupEventData = groupEventMapperObj
                            }
                        }
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            
                            let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                            
                            view_NoData.label_Text.text = "No Data Found"
                            
                            self.tableView_Main.backgroundView = view_NoData
                            
                        })
                        
                    }

                    self.tableView_Main.reloadData()
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
    }


}
