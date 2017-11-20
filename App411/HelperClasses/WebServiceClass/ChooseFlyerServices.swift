//
//  ChooseFlyerServices.swift
//  App411
//
//  Created by osvinuser on 8/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


extension ChooseFlyerViewController {

    //MARK:- Get Flyer.
    func getFlyerByCategoriesFromAPI(categoryId: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_category_id=\(categoryId)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.flyer_list, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        self.array_FlyerObjList.removeAll()
                        
                        if responeCode == true {
                            
                            if let friendList = jsonResult["flyer"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let flyerInfoModelObj = Mapper<AFlyerInfoModel>().map(JSONObject: friendInfoObj) {
                                        self.array_FlyerObjList.append(flyerInfoModelObj)
                                    }
                                    
                                }
                                
                            }
                            
                            self.collectionView_FlyerList.backgroundView = nil
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                //self.showAlert(jsonResult["message"] as? String ?? "")
                                
                                if self.array_FlyerObjList.count <= 0 {
                                    
                                    let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                    
                                    view_NoData.label_Text.text = "No Data Found"
                                    
                                    self.collectionView_FlyerList.backgroundView = view_NoData
                                    
                                } else {
                                    
                                    self.collectionView_FlyerList.backgroundView = nil
                                }
                                
                            })
                            
                        }
                        
                        self.collectionView_FlyerList.reloadData()
                        
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
