//
//  CreatePostServices.swift
//  App411
//
//  Created by osvinuser on 8/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import Cloudinary
import ObjectMapper
import AVFoundation


extension CreatePostController {

    
    // MARK: - Upload Image By Data on cloudinary
    
    internal func uploadImageOnCloudinaryByData(APIUrl: String, authToken: String, postDataText: String, publicID: String, imageData: Data, imageWidth: String, imageHeight: String, isVideo: String, postUploadAtType: PostUploadType) {
    
        // Configuration.
        let configuration = CloudinarySingletonClass.sharedInstance.configurationOfCloudinary(publicID: publicID, resourceType: .image)
        let cloudinary: CLDCloudinary = configuration.cloudinary
        let params: CLDUploadRequestParams = configuration.params
        
        cloudinary.createUploader().signedUpload(data: imageData , params: params, progress: { (progress) in
            
            print(progress)
            
        }, completionHandler: { (respone, error) in
            
            if error != nil {
                
                Methods.sharedInstance.hideLoader()
                self.showAlert(error?.localizedDescription ?? "No Error Found")
                
            } else {
                
                if let cldUploadResult: CLDUploadResult = respone {
                
                    if let url = cldUploadResult.url {
                        
                        if postUploadAtType.rawValue == 1 {
                            
                            // Using for event post.
                            self.postUploadOnEventByUserToken(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: "", postDataPublicID: publicID, postDataURL: url, isVideo: isVideo, eventID: String(self.eventId ?? 0), imageWidth: imageWidth, imageHeight: imageHeight)
                            
                        } else if postUploadAtType.rawValue == 2 {
                            
                            // Upload Data on our server.
                            self.postUploadOnTimeLineByUserToken(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: "", postDataPublicID: publicID, postDataURL: url, isVideo: isVideo, imageWidth: imageWidth, imageHeight: imageHeight)
                            
                        } else if postUploadAtType.rawValue == 3 {
                            
                            // Using for Channel post.
                            self.postUploadOnChannelByUserToken(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: "", postDataPublicID: publicID, postDataURL: url, isVideo: isVideo, imageWidth: imageWidth, imageHeight: imageHeight)

                        }
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    
    // MARK: - Upload Video By URL on Cloudinary
    // Upload Video Thumbnail
    
    func uploadVideoOnCloudinaryByURL(APIUrl: String, authToken: String, postDataText: String, videoThumbnailPublicID: String, publicID: String, fileURL: URL, isVideo: String, postUploadAtType: PostUploadType) {
        
        // Configuration.
        let configurationThumbnail = CloudinarySingletonClass.sharedInstance.configurationOfCloudinary(publicID: videoThumbnailPublicID, resourceType: .image)
        let cloudinaryThumbnail: CLDCloudinary = configurationThumbnail.cloudinary
        let paramsThumbnail: CLDUploadRequestParams = configurationThumbnail.params
        
        if let image = self.generateThumnail(url: fileURL) {
        
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            
            cloudinaryThumbnail.createUploader().signedUpload(data: imageData!, params: paramsThumbnail, progress: { (progress) in
                print(progress)
            }, completionHandler: { (respone, error) in
                
                if error != nil {
                    
                    Methods.sharedInstance.hideLoader()
                    self.showAlert(error?.localizedDescription ?? "No Error Found")
                    
                } else {
                    
                    if let cldUploadResult: CLDUploadResult = respone {
                        
                        if let videoThumnailURL = cldUploadResult.url {
                            
                            self.uploadVideoOnCloudinaryByURL(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: videoThumnailURL, publicID: publicID, fileURL: fileURL, isVideo: isVideo, postUploadAtType: postUploadAtType)
                            
                            
                        } else {
                        
                            print("Video Thumbnail Not Found.")
                            
                        }
                        
                    } else {
                    
                        print("Video Thumbnail Not Found.")

                    }
                    
                }
                
            })
        
        } else {
        
            print("Video Thumbnail Not Found.")
            
        }
    }
    
   
    // MARK: - Upload Video After thumbnail
    
    func uploadVideoOnCloudinaryByURL(APIUrl: String, authToken: String, postDataText: String, videoThumbnailURL: String, publicID: String, fileURL: URL, isVideo: String, postUploadAtType: PostUploadType) {
    
        // Configuration.
        let configuration = CloudinarySingletonClass.sharedInstance.configurationOfCloudinary(publicID: publicID, resourceType: .video)
        let cloudinary: CLDCloudinary = configuration.cloudinary
        let params: CLDUploadRequestParams = configuration.params
        
        cloudinary.createUploader().signedUpload(url: fileURL, params: params, progress: { (progress) in
            
            print(progress)
            
        }) { (respone, error) in
            
            print(respone ?? "Not Found")
            
            if error != nil {
                
                Methods.sharedInstance.hideLoader()
                self.showAlert(error?.localizedDescription ?? "No Error Found")
                
            } else {
                
                if let cldUploadResult: CLDUploadResult = respone {
                    
                    if let url = cldUploadResult.url {
                        
                        if postUploadAtType.rawValue == 1 {
                            
                            // Using for event post.
                            self.postUploadOnEventByUserToken(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: videoThumbnailURL, postDataPublicID: publicID, postDataURL: url, isVideo: isVideo, eventID: String(self.eventId ?? 0), imageWidth: "0", imageHeight: "0")
                            
                        } else if postUploadAtType.rawValue == 2 {
                            
                            // Upload Data on our server.
                            self.postUploadOnTimeLineByUserToken(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: videoThumbnailURL, postDataPublicID: publicID, postDataURL: url, isVideo: isVideo, imageWidth: "0", imageHeight: "0")
                            
                        } else if postUploadAtType.rawValue == 3 {
                            
                            // Using for Channel post.
                            self.postUploadOnChannelByUserToken(APIUrl: APIUrl, authToken: authToken, postDataText: postDataText, videoThumbnailURL: videoThumbnailURL, postDataPublicID: publicID, postDataURL: url, isVideo: isVideo, imageWidth: "0", imageHeight: "0")
                            
                        }
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    

    
    // MARK: - Post upload on Timeline.
    
    internal func postUploadOnTimeLineByUserToken(APIUrl: String, authToken: String, postDataText: String, videoThumbnailURL: String, postDataPublicID: String, postDataURL: String, isVideo: String, imageWidth: String, imageHeight: String) {
        // auth_token,content,image_url,image_name,video_flag
        
        // If uploaded Text only then flag 2
        // If uploaded Text and Video then flag 1
        // If uploaded Text and Image then flag 0
        
        // add Params.
        let params = "auth_token=\(authToken)&content=\(postDataText)&image_name=\(postDataPublicID)&image_url=\(postDataURL)&thumbnail=\(videoThumbnailURL)&video_flag=\(isVideo)&image_width=\(imageWidth)&image_height=\(imageHeight)"
        print(params)
        
        // Call Upload Data WebService
        WebServiceClass.sharedInstance.dataTask(urlName: APIUrl, method: "POST", params: params) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshManually"), object: self, userInfo: ["":""])

                        self.navigationController?.popViewController(animated: true)
                        // self.showAlert("Your post successfully created.")
                        
                    } else {
                        self.showAlert(jsonResult["message"] as! String)
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    
    
    //MARK : - Create Post For A Particular Event
    
    internal func postUploadOnEventByUserToken(APIUrl: String, authToken: String, postDataText: String, videoThumbnailURL: String, postDataPublicID: String, postDataURL: String, isVideo: String, eventID: String,  imageWidth: String, imageHeight: String) {
        // auth_token,content,image_url,image_name,video_flag
        
        // If uploaded Text only then flag 2
        // If uploaded Text and Video then flag 1
        // If uploaded Text and Image then flag 0
        
        // add Params.
        let params = "auth_token=\(authToken)&event_id=\(eventID)&content=\(postDataText)&image_name=\(postDataPublicID)&image_url=\(postDataURL)&thumbnail=\(videoThumbnailURL)&video_flag=\(isVideo)&image_width=\(imageWidth)&image_height=\(imageHeight)"
        print(params)
        
        // Call Upload Data WebService
        WebServiceClass.sharedInstance.dataTask(urlName: APIUrl, method: "POST", params: params) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                print(response)

                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        self.delegate?.isCreatePost!(isSuccess: true)
                        self.navigationController?.popViewController(animated: true)
                        self.showAlert("Your post successfully created.")
                        
                    } else {
                        self.showAlert(jsonResult["message"] as! String)
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    
    // MARK: - Post Upload on Channel
    
    internal func postUploadOnChannelByUserToken(APIUrl: String, authToken: String, postDataText: String, videoThumbnailURL: String, postDataPublicID: String, postDataURL: String, isVideo: String,  imageWidth: String, imageHeight: String) {
        // auth_token,content,image_url,image_name,video_flag
        
        // If uploaded Text only then flag 2
        // If uploaded Text and Video then flag 1
        // If uploaded Text and Image then flag 0
        
        // add Params.
        let params = "auth_token=\(authToken)&content=\(postDataText)&image_name=\(postDataPublicID)&image_url=\(postDataURL)&thumbnail=\(videoThumbnailURL)&video_flag=\(isVideo)&image_width=\(imageWidth)&image_height=\(imageHeight)"
        print(params)
        
        // Call Upload Data WebService
        WebServiceClass.sharedInstance.dataTask(urlName: APIUrl, method: "POST", params: params) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                print(response)
                
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        self.navigationController?.popViewController(animated: true)
                        self.showAlert("Your post successfully created.")
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadChannelDataAPINotification"), object: self, userInfo: ["":""])
                        
                    } else {
                        self.showAlert(jsonResult["message"] as! String)
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    
}
