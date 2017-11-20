//
//  ChannelEditServices.swift
//  App411
//
//  Created by osvinuser on 8/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Cloudinary

extension ChannelDetailsViewController {

    internal func uploadAvatarImageToCloudinary(flagValue ofImage: Int8, avatarImage: UIImage) {
        
        //Upload Cover Image or Channel Image To Server
        
        /*
         Note: If Flag value is "1", that means user has request to change his Profile image of channel or Vice - Versa.
         */
        
        let randomIDTimelinePost = flagValue ==  1 ? "channelProfileImage".randomString(length: 60) : "channelBackgroundImage".randomString(length: 60)
        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
            let cloudinary = CLDCloudinary(configuration: config!)
            
            let params = CLDUploadRequestParams()
            params.setTransformation(CLDTransformation().setGravity(.northWest))
            params.setPublicId(randomIDTimelinePost)
            
            let progressHud = Methods.sharedInstance.showPercentageLoader()
            
            cloudinary.createUploader().signedUpload(data: UIImageJPEGRepresentation(avatarImage, 1.0)!, params: params, progress: { (progress) in
                
                progressHud.progress = Float(progress.fractionCompleted)
                
            }, completionHandler: { (respone, error) in
                
                if error != nil {
                    
                    progressHud.hide(animated: true)
                    self.showAlert(error?.localizedDescription ?? "")
                    
                } else {
                    
                    progressHud.hide(animated: true)
                    
                    print(respone ?? "Not Found")
                    
                    if let cldUploadResult: CLDUploadResult = respone {
                        
                        self.sendAvatarImageToServer(authToken:userInfoModel.authentication_token! , imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
                        
                    }
                    
                }
                
            })
            
        }
        
    }
    
    internal func sendAvatarImageToServer(authToken: String,imageName: String, imageURL:String) {
        
        //Upload Cover Image or Channel Image To Server
        
        /*
         Note: If Flag value is "1", that means user has request to change his Profile image of channel or Vice - Versa.
         */
        var parameterDict = [String : String]()
        
        if self.flagValue == 1 {
            
                parameterDict = ["auth_token" : authToken,
                "image_name" : imageName,
                "image_link" : imageURL,
                "cover_image_name":"",
                "cover_image_link":"",
                "status" :"\(self.flagValue)"

            ]
            
        } else {
            
            parameterDict = ["auth_token" : authToken,
                             "image_name" : "",
                             "image_link" : "",
                             "cover_image_name":imageName,
                             "cover_image_link":imageURL,
                             "status" :"\(0)"
            ]
            
        }
        
        let paramString = self.convertDictionaryIntoString(paramDict: parameterDict as Dictionary<String, AnyObject>)
        
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.channelImageUpdate, method: "POST", params: paramString) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadChannelDataAPINotification"), object: self, userInfo: ["":""])

                    }
                    
                } else {
                    
                    print("Worng data found.")
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    
    internal func updateContentOfChannelServiceFunction() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            
            print("User Info Not Found")
            return
        }
        
        let paramDict = ["auth_token" : userInfoModel.authentication_token ?? "",
                         "name" : self.channelDetailDict["channelName"] as AnyObject,
                         "description" : self.channelDetailDict["channelDescription"] as AnyObject,
                         "public_flag":self.channelDetailDict["channelPrivacy"] as AnyObject
            ] as [String : AnyObject]
        
        let paramString = self.convertDictionaryIntoString(paramDict: paramDict)
        
        //auth_token,name,description,public_flag
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.channelContentUpdate, method: "POST", params: paramString) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadChannelDataAPINotification"), object: self, userInfo: ["":""])
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        let indexPath = IndexPath(row: 1, section: 0)
                        self.tableView_Main.reloadRows(at: [indexPath], with: .none)
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                    }
                    
                } else {
                    
                    print("Worng data found.")
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
