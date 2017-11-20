//
//  UserProfileServices.swift
//  App411
//
//  Created by osvinuser on 8/14/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Cloudinary


extension MyProfileViewController {
    

    internal func someOtherUserServiceFunction() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        //auth_token,user_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_id=\(selectedUserProfile?.id ?? 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.otherUserProfile, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        if let userInfoObj = Mapper<AUserInfoModel>().map(JSONObject: jsonResult["user"]) {
                            
                            self.selectedUserProfile = userInfoObj
                            
                            self.createEventInfoParams["AboutMe"] = userInfoObj.description_bio as AnyObject
                            self.createEventInfoParams["Name"] = userInfoObj.fullname as AnyObject
                            self.createEventInfoParams["DateOfBirth"] = userInfoObj.dob as AnyObject
                            self.createEventInfoParams["userImage"] = userInfoObj.image as AnyObject
                            self.createEventInfoParams["Email"] = userInfoObj.email as AnyObject
                            
                            self.title = "\(userInfoObj.fullname ?? "")"
                            
                        }
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            
                            let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                            
                            view_NoData.label_Text.text = "No Data Found"
                            
                            self.tableView_Main.backgroundView = view_NoData
                            
                        })
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView_Main.reloadData()
                    }
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
    }
    
    //MARK:- send Profile Details on Server.
    internal func sendProfileDetailsOnServer(authToken: String, imageName: String, imageURL: String, description: String, dob:String, full_name:String) {
        
        let paramsStr = "auth_token=\(authToken)&image_name=\(imageName)&image_url=\(imageURL)&description=\(description)&date_of_birth=\(dob)&full_name=\(full_name)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.updateProfile, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        if responeCode == true {
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONObject: jsonResult["user"]) {
                                
                                if let JSONString = Mapper().toJSONString(userInfoObj, prettyPrint: true) {
                                    
                                    //User Info
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                    UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProfilePic"), object: self, userInfo: ["":""])

                                    
                                }
                                self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            }
                        } else {
                            
                            self.showAlert(jsonResult["message"] as? String ?? "")
                            
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                self.showAlert(errorMsg)
                
            }
            
        }
    }
    
    internal func uploadProfilePicName(imageName: String) {
        
        Methods.sharedInstance.showLoader()
        
        let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
        let cloudinary = CLDCloudinary(configuration: config!)
        
        let params = CLDUploadRequestParams()
        params.setTransformation(CLDTransformation().setGravity(.northWest))
        params.setPublicId(imageName)
        
        let cell: TableViewProfileCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewProfileCell

        
        cloudinary.createUploader().signedUpload(data: UIImageJPEGRepresentation(cell.imageView_Image.image!, 1.0)!, params: params, progress: { (progress) in
            
            print(progress)
            
        }, completionHandler: { (respone, error) in
            
            if error != nil {
                
                Methods.sharedInstance.hideLoader()
                
            } else {
                
                print(respone ?? "Not Found")
                
                if let cldUploadResult: CLDUploadResult = respone {
                    
                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                    
                    if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                        
                        self.sendProfileDetailsOnServer(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!,description: self.createEventInfoParams["AboutMe"] as? String ?? "", dob:self.createEventInfoParams["DateOfBirth"] as? String ?? "",full_name:self.createEventInfoParams["Name"] as? String ?? "")
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    //MARK:- send Friend Request API.
    internal func sendFriendRequestAPI(friendId: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_ids=\(friendId)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.friendRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
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
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    internal func blockUserRequestApi(friendId: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //block_user
        Methods.sharedInstance.showLoader()
        
        //auth_token,friend_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(friendId)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.blockUserRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
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
    
    internal func reportSpamUserRequestApi(friendId: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        //auth_token,user_id,content
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_id=\(friendId)&content=hgsadga"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.userSpam, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
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
    
    internal func unFriendUserRequestAPI(friendId: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(String(friendId))"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.unfriendUser, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        DispatchQueue.main.async(execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
                        if responeCode == true {
                            
                            DispatchQueue.main.async(execute: { 
                                
                                self.navigationController?.popViewController(animated: true)
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
