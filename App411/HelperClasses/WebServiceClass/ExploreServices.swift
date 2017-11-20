//
//  ExploreServices.swift
//  App411
//
//  Created by osvinuser on 8/18/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Cloudinary


extension ExploreViewController {
    
    
    // MARK: - Get Store Data List
    
    internal func getStoresDataList() {
    
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        
        // Time line web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.explore_story_list, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                // self.refreshControl.endRefreshing()
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.array_StoryInfo.removeAll()
                            
                            if let storyList = jsonResult["stories"] as? [Dictionary<String, AnyObject>] {
                            
                                for storeInfoObj in storyList {
                                    if let storyDetailObj = Mapper<AStoryInfoModel>().map(JSONObject: storeInfoObj) {
                                        self.array_StoryInfo.append(storyDetailObj)
                                    }
                                }
                            }
                            
                            self.array_eventList.removeAll()
                            
                            if let eventList = jsonResult["events"] as? [Dictionary<String, AnyObject>] {
                                
                                for eventInfoObj in eventList {
                                    
                                    // step 1 : get the lat and long of a pin
                                    let eventlat = eventInfoObj["latitute"]?.doubleValue
                                    let eventlong = eventInfoObj["longitude"]?.doubleValue
                                    
                                    // step 2 : add the lat and long into cllocationcoordinate2d
                                    let location = CLLocationCoordinate2D(
                                        latitude: eventlat ?? 0.0, longitude: eventlong ?? 0.0)
                                    
                                    // step 3 : Add the location, certification_id, userid into AcademicAnnotation
                                    let annotationPin = ExploreEventModel(coordinate: location, eventDict: eventInfoObj)
                                    
                                    if annotationPin.event_category_id == 10 {
                                        
                                        //add ExploreEventModel Dict into Array
                                        self.array_eventList.append(annotationPin)
                                        
                                    } /*else {
                                        
                                        if let storyDetailObj = Mapper<AStoryInfoModel>().map(JSONObject: eventInfoObj) {
                                            
                                            self.array_StoryInfo.append(storyDetailObj)
                                        }
                                    }
 */
                                }
                            }
                            
                            if self.array_StoryInfo.count > 0 {
                            
                                self.heatmap = DTMHeatmap()
                                self.heatmap.setData(self.updatePointsOnMap())
                                self.mapView.add(self.heatmap)
                            }
                            
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
                
                // self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    
    
    
    
    
    // MARK: - Get Time line post data.
    internal func createStoreOnExplore(postDataPublicID: String, postDataURL: String, view: UIView) {
    
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        guard let latitude = userInfoModel.latitute else {
            return
        }
        
        guard let longitude = userInfoModel.longitute  else {
            return
        }
        
        
        
        // user authentication toker
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&image_name=\(postDataPublicID)&image_link=\(postDataURL)&latitute=\(latitude)&longitute=\(longitude)"
        print(paramsStr)
        
        
        // Time line web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.explore_story_create, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()

            
            if success == true {
                
                // self.refreshControl.endRefreshing()
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)

                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let storyDetailObj = jsonResult["story_detail"]as? Dictionary<String, AnyObject> {
                                
                                if let storyDetailInfoModel = Mapper<AStoryInfoModel>().map(JSONObject: storyDetailObj) {
                                    self.array_StoryInfo.append(storyDetailInfoModel)
                                    view.removeFromSuperview()
                                }
                                
                            }
                            
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
                
                // self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    
    
    
    // MARK: - Upload Image By Data on cloudinary
    
    internal func uploadImageOnCloudinaryByData(APIUrl: String, authToken: String, publicID: String, imageData: Data, imageWidth: String, imageHeight: String, isVideo: String, view: UIView) {
        
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
                        
                        // Upload Data on our server.
                        self.createStoreOnExplore(postDataPublicID: publicID, postDataURL: url, view: view)
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    
    // MARK: - Upload Video By URL on Cloudinary
    
    func uploadVideoOnCloudinaryByURL(APIUrl: String, authToken: String, publicID: String, fileURL: URL, isVideo: String, view: UIView) {
        
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
                        
                        // Upload Data on our server.
                        self.createStoreOnExplore(postDataPublicID: publicID, postDataURL: url, view: view)
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    internal func saveEventForUser(eventId:Int, isSavedEvent:Bool, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isSavedEvent == false ? 0 : 1)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.saveEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        completion(true)
                        
                    } else {
                        completion(false)
                        
                        print("Worng data found.")
                        
                    }
                    
                    self.showAlert(jsonResult["message"] as? String ?? "")
                }
            } else {
                completion(false)
                
                self.showAlert(errorMsg)
            }
        }
    }
    
    
    internal func joinEventForUser(eventId:Int, isEventJoin:Bool, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //auth_token,event_id,status if status 1 means join and status 0 means disjoint
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isEventJoin == false ? 1 : 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.eventJoin, method: "POST", params: paramsStr) { (
            success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        completion(true)
                        
                    } else {
                        completion(false)
                        
                        print("Worng data found.")
                    }
                    
                    self.showAlert(jsonResult["message"] as? String ?? "")
                }
            } else {
                completion(false)
                
                self.showAlert(errorMsg)
            }
        }
    }


}
