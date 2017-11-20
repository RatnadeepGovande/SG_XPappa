//
//  TimelineServices.swift
//  App411
//
//  Created by osvinuser on 8/8/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


extension TimelineCollectionViewController {

    
    // MARK: - Get Time line post data.
    internal func getTimePostDataFromAPI(count: String) {
    
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&count=\(count)"
        print(paramsStr)
        
        
        isAPILoaded = false
        
        // Time line web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.postListOnTimeline, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                self.refreshControlTop.endRefreshing()
                self.refreshControlBottom.endRefreshing()
                
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    self.isAPILoaded = true
                    
                    if count == "0" {
                        self.arrayPostData.removeAll()
                    }
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let postList = jsonResult["post"] as? [Dictionary<String, AnyObject>] {
                                
                                for postInfoObj in postList {
                                    
                                    if let timeLinePostInfoModel = Mapper<ATimeLinePostInfoModel>().map(JSONObject: postInfoObj) {
                                        self.arrayPostData.append(timeLinePostInfoModel)
                                    }
                                    
                                }
                                
                                if Singleton.sharedInstance.categoryListInfo.count == 0 {
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "categoryListReloadNotification"), object: self, userInfo: ["":""])
                                }

                                
                                DispatchQueue.main.async {
                                    self.collectionView?.reloadData()
                                }
                                
                            }
                                                        
                            
                        } else {
                            
//                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
//                                self.showAlert(jsonResult["message"] as? String ?? "")
//                            })
//                          
                            print("reload with null data")
                            
                        }
                        
                        
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                self.refreshControlTop.endRefreshing()
                self.refreshControlBottom.endRefreshing()

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }

    }
    
}
