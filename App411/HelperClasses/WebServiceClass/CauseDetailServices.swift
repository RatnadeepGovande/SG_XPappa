//
//  CauseDetailServices.swift
//  App411
//
//  Created by osvinuser on 9/15/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper
import AVFoundation

extension CauseDetailViewController {
    
    // MARK: - WebService Functions
    
    internal func showCauseDetailFor(causeID: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
            
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(causeID)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.eventDetail, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        if let eventList = jsonResult["event"] as? [Dictionary<String, AnyObject>] {
                            
                            for eventInfoObj in eventList {
                                
                                if let eventInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: eventInfoObj) {
                                    
                                    self.eventData = eventInfoMapperObj
                                    
                                    if let donationArray = eventInfoObj["donation"] as? [Dictionary<String, AnyObject>] {
                                        
                                        self.eventData.donationArray.removeAll()
                                        for userInfoObject in donationArray {
                                            
                                            if let userInfoMapperObj = Mapper<DonationMoneyModel>().map(JSONObject: userInfoObject) {
                                                
                                                self.eventData.donationArray.append(userInfoMapperObj)
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        let array_CategoryList = Singleton.sharedInstance.categoryListInfo
                        
                        if array_CategoryList.contains(where: { $0.id == self.eventData.event_category_id }) {
                            
                            _ = array_CategoryList.index(where: { $0.id ==  self.eventData.event_category_id }).map({ (Index) in
                                let arrayDict = array_CategoryList[Index]
                                self.categoryName = arrayDict.event_name
                            })
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                            self.tableView_Main.dataSource = self
                            self.tableView_Main.delegate = self
                            self.tableView_Main.reloadData()
                        })
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    internal func saveEventForUser(eventId:Int, isSavedEvent:Bool) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //auth_token,event_id,status =1 favourite status =0 for unfavourite
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isSavedEvent == false ? 0 : 1)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.saveEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        self.eventData.event_favorite = !isSavedEvent

                        let cell: EventDetailProfileCell = self.tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! EventDetailProfileCell
                        
                        cell.eventSaveButton.isSelected = isSavedEvent
                        
                        let indexOfPerson1 = Singleton.sharedInstance.array_eventList.index(where: {$0.id == self.eventData.id})
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSaveEvent"), object: self, userInfo: ["indexOfObject": indexOfPerson1 ?? 0, "event_favorite": isSavedEvent])
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                    self.showAlert(jsonResult["message"] as? String ?? "")
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
    }
    
    internal func deleteCauseByUser(eventId:Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //auth_token,event_id
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)"
        print(paramsStr)
        
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.deleteEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventListAPIReloadNotification"), object: self, userInfo: ["":""])
                        
                        self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                        
                    } else {
                        
                        print("Worng data found.")
                        self.showAlert(jsonResult["message"] as? String ?? "")
                        
                    }
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    internal func spamOrReportEvent(eventId:Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //auth_token,event_id,content
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&content=staticdata"
        print(paramsStr)
        
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.spamEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                        
                    } else {
                        
                        print("Worng data found.")
                        self.showAlert(jsonResult["message"] as? String ?? "")
                        
                    }
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
}
