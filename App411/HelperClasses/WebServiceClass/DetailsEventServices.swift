//
//  DetailsEventServices.swift
//  App411
//
//  Created by osvinuser on 8/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper
import AVFoundation

extension EventDetailViewController {

    // MARK: - WebService Functions
    
    internal func showEventDetail(eventId: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
       
        }
        
        // auth_token, event_id,
        // Favourite status = 1 & Unfavourite status = 0
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)"
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
                                    
                                    if let joinArray = eventInfoObj["join"]?["user"] as? [Dictionary<String, AnyObject>] {
                                        
                                        self.eventData.event_JoinArray.removeAll()
                                        
                                        for userInfoObject in joinArray {

                                            if let userInfoMapperObj = Mapper<AUserInfoModel>().map(JSONObject: userInfoObject) {
                                               
                                                if userInfoMapperObj.hostStatus == false {
                                                    
                                                    self.eventData.event_JoinArray.append(userInfoMapperObj)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if let isUserHost = self.eventData.host_flag, isUserHost {
                                        
                                        self.cameraButton.isHidden = false
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
                            
                            self.initialSetupForUberRides()
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
    
    internal func joinEventForUser(eventId:Int, isEventJoin:Bool, completionHandler:@escaping CallBackMethods.SourceCompletionHandler) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,event_id,status if status 1 means join and status 0 means disjoint
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isEventJoin == false ? 1 : 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.eventJoin, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        self.eventData.event_join = !isEventJoin
                        
                         if let userData = jsonResult["user"] as? Dictionary<String, AnyObject> {
                         
                             if let userInfoObject = Mapper<AUserInfoModel>().map(JSONObject: userData) {
                                
                                self.eventData.event_JoinArray.append(userInfoObject)
                                
                             }
                         }
                        
                        completionHandler(true as AnyObject)
                        
                    } else {
                        
                        print("Worng data found.")
                        completionHandler(false as AnyObject)

                    }
                    
                    self.showAlert(jsonResult["message"] as? String ?? "")

                    if let isEventNew = self.eventData.event_join, !isEventNew {

                        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
                            
                            if self.eventData.event_JoinArray.contains(where:{ $0.id == userInfoModel.id }) {
                                
                            _ = self.eventData.event_JoinArray.index(where: { $0.id ==  userInfoModel.id }).map({ (Index) in
                                self.eventData.event_JoinArray.remove(at: Index)
                            })
                                
                           }
                        }
                        
                    }
                    
                    self.tableView_Main.beginUpdates()
                    let indexPath = IndexPath(row: 0, section: 4)
                    self.tableView_Main.reloadRows(at: [indexPath], with: .none)
                    self.tableView_Main.endUpdates()
                } else {
                    
                    completionHandler(false as AnyObject)

                }
                
            } else {
                
                self.showAlert(errorMsg)
                completionHandler(false as AnyObject)

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
                        
                        self.eventData.event_favorite = isSavedEvent
                        
                        let indexOfPerson1 = Singleton.sharedInstance.array_eventList.index(where: {$0.id == self.eventData.id})
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSaveEvent"), object: self, userInfo: ["indexOfObject": indexOfPerson1 ?? 0, "event_favorite": isSavedEvent])

                        
                        let cell: EventDetailProfileCell = self.tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! EventDetailProfileCell
                        
                        cell.eventSaveButton.isSelected = isSavedEvent
                        
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
    
    internal func deleteEvent(eventId:Int) {
        
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
    
    internal func postLikeAndDisLike(event_ID: Int, post_ID: Int, status_isLiked: Int, postObj: AEventPostInfoModel, selectedTag: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(event_ID)&content=staticdata&post_id=\(post_ID)&status=\(status_isLiked)"
        print(paramsStr)
        
        
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.event_post_like, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        // print(self.eventData.event_postArray)
                        self.eventData.event_postArray[selectedTag].like_status = status_isLiked
                        // print(self.eventData.event_postArray)
                        // self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                        
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
