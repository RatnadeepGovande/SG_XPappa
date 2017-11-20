//
//  SignUpProfilePicService.swift
//  App411
//
//  Created by osvinuser on 8/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Cloudinary


extension SignUpProfilePicViewController {

    internal func uploadProfilePicName(imageName: String) {
        
        Methods.sharedInstance.showLoader()
        
        let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
        let cloudinary = CLDCloudinary(configuration: config!)
        
        let params = CLDUploadRequestParams()
        params.setTransformation(CLDTransformation().setGravity(.northWest))
        params.setPublicId(imageName)
        
        cloudinary.createUploader().signedUpload(data: UIImageJPEGRepresentation(imageThumbnailSize, 1.0)!, params: params, progress: { (progress) in
            
            print(progress)
            
        }, completionHandler: { (respone, error) in
            
            if error != nil {
                
                Methods.sharedInstance.hideLoader()
                
                self.showAlert(error?.localizedDescription ?? "No Error Found")
                
            } else {
                
                print(respone ?? "Not Found")
                
                if let cldUploadResult: CLDUploadResult = respone {
                    
                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                    
                    if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                        
                        self.sendProfileDetailsOnServer(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    
    //MARK:- send Profile Details on Server.
    internal func sendProfileDetailsOnServer(authToken: String, imageName: String, imageURL: String) {
        
        let paramsStr = "auth_token=\(authToken)&image_name=\(imageName)&image_url=\(imageURL)"
        
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.imageUpload, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                                return
                            }
                            
                            //print(userInfoModel.authentication_token ?? "dbadb")
                            userInfoModel.authentication_token = jsonResult["auth_token"] as? String
                            //print(userInfoModel.authentication_token ?? "dfbagb")
                            
                            
                            if let JSONString = Mapper().toJSONString(userInfoModel, prettyPrint: true) {
                                
                                //User Info
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                
                                let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                                let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                                
                                print(userDataStr)
                                
                            }
                            
                            self.performSegue(withIdentifier: "segueNextButton", sender: self)
                            
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
