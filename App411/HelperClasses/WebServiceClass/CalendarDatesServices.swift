//
//  CalendarDatesServices.swift
//  App411
//
//  Created by osvinuser on 8/14/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


extension CalendarViewController {

    //MARK:- Get Flyer.
    func getCalendarDatesServiceFunction(month: String, yearInt: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&month_name=\(month)&year=\(yearInt)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.calendarListRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        self.dateArray.removeAll()
                        
                        if responeCode == true {
                            
                            if let friendList = jsonResult["date_list"] as? [Dictionary<String, AnyObject>] {
                                
                                for datesDict in friendList {
                                    
                                    self.dateArray.append(datesDict["date"] as AnyObject)
                                }
                            }
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                        }
                        
                        self.calender_view.reloadData()
                        
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
    
    //MARK:- Get Particular Date Event Functions
    func getParticularDateEventFunction(date: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,date
        Methods.sharedInstance.showLoader()
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&date=\(date)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.calendarListDetailRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        self.eventsArray.removeAll()
                        
                        if responeCode == true {
                            
                            if let eventList = jsonResult["event"] as? [Dictionary<String, AnyObject>] {
                                
                                for eventInfoObj in eventList {
                                    
                                    if let eventInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: eventInfoObj) {
                                        
                                        self.eventsArray.append(eventInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                        }
                        
                        self.calenderTableView.reloadData()
                        
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
