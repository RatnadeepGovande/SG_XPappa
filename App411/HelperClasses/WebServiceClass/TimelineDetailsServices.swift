//
//  TimelineDetailsServices.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


extension TimelineDetailViewController {
    
    
    // MARK: - Get Time line post data.
    internal func getTimePostDetailDataFromAPI(post_id: String) {
        
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&post_id=\(post_id)"
        print(paramsStr)
        
        
        // Time line web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.timeline_post_detail, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                // self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    self.array_Comments.removeAll()
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let commentList = jsonResult["post_detail"]?["comment_list"] as? [Dictionary<String, AnyObject>] {
                                
                                for commentInfoObj in commentList {
                                    
                                    if let commentInfoModel = Mapper<ATimeLineCommentInfoModel>().map(JSONObject: commentInfoObj) {
                                        self.array_Comments.append(commentInfoModel)
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                             
                                self.showAlert(jsonResult["message"] as? String ?? "")
                           
                            })
                            
                        }
                        
                        self.collectionView_Main.reloadSections(IndexSet(integer: 1))
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                // self.refreshControl.endRefreshing()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    
}
