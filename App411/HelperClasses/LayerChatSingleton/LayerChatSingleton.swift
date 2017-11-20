//
//  LayerChatSingleton.swift
//  App411
//
//  Created by osvinuser on 7/24/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import LayerKit
import Atlas

let layerAppID = "layer:///apps/staging/b9099d48-6dd3-11e7-b7ae-9b2e994c87aa"

// MARK: - LayerChatSingleton
open class LayerChatSingleton {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let sharedInstance = LayerChatSingleton()
    
    
    // MARK: - connect Layer Client Bool.
    func connectLayerClientBool(layerClient: LYRClient) {
        
        if (layerClient.isConnected) {
            
            print("Layer Client already coonected.")
            
        } else {

            self.connectLayerClient(layerClient: layerClient)

        }
        
    }
    
    // MARK: - connect Layer Client.
    func connectLayerClient(layerClient: LYRClient) {
    
        layerClient.connect(completion: {(_ success: Bool, _ error: Error?) -> Void in
            
            if !success {
                
                print("Failed connection to Layer with error: \(String(describing: error?.localizedDescription))")
                
            } else {
                
                print("Successfully connected to Layer!")
                
                self.authenticateLayerWithUserID(layerClient: layerClient, completion: { (success, error) in
                    
                    if !success {
                        print("Failed Authenticating Layer Client with error:\(String(describing: error))")
                    } else {
                        print("successfully authenticated")
                    }
                    
                })
                
            }
        })
        
    }
    
    
    // MARK - Layer Authentication Methods
    
    func authenticateLayerWithUserID(layerClient: LYRClient, completion: @escaping ((_ success: Bool, _ error: NSError?) -> Void)) {
        
        if layerClient.authenticatedUser?.userID != nil {
            print("Layer Authenticated as User \(String(describing: layerClient.authenticatedUser?.userID))")
            return
        }
        
        
        /*
         * 1. Request an authentication Nonce from Layer
         */
        layerClient.requestAuthenticationNonce(completion: { (nonce, error) in
            
            print(nonce ?? "Data not found")
            
            if nonce == nil {
                completion(false, error! as NSError)
                return
            }
            
            /*
             * 2. Acquire identity Token from Layer Identity Service
             */
            self.requestIdentityTokenForUserID(appID: layerClient.appID.absoluteString, nonce: nonce!, completion: { (identityToken, error) in
                
                if identityToken.isEmpty {
                    completion(false, error)
                    return
                }
                
                /*
                 * 3. Submit identity token to Layer for validation
                 */
                layerClient.authenticate(withIdentityToken: identityToken, completion: { (authenticatedUserID, error) in
                    
                    if error != nil {
                        completion(false, error! as NSError)
                    } else {
                        
                        print(authenticatedUserID?.userID ?? "No User ID Found")
                        
                        print("Layer Authenticated as User: \(String(describing: authenticatedUserID?.userID))")
                        completion(true, nil)
                    }
                    
                })
                
            })
            
        })
        
    }
    
    // MARK: - Request Identity Token For UserID.
    
    func requestIdentityTokenForUserID(appID: String, nonce: String, completion: @escaping ((_ identityToken: String, _ error: NSError?) -> Void)) {
        
        //identify_token
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let userID: String = "\(userInfoModel.id ?? 0)"
        let firstName: String = userInfoModel.fullname!
        let lastName: String = userInfoModel.fullname!
        let displayName: String = userInfoModel.fullname!
        var dispalyImageUrl: String = ""
        
        if let profileImageUrl = userInfoModel.image {
            dispalyImageUrl = profileImageUrl
        } else {
            dispalyImageUrl = "http://xyphr.herokuapp.com/chat.png"
        }
        
        
        let paramsStr = "user_id=\(userID)&nonce=\(nonce)&first_name=\(firstName)&last_name=\(lastName)&display_name=\(displayName)&avatar_url=\(dispalyImageUrl)"
        print(paramsStr)
        
        
        WebServiceClass.sharedInstance.dataTask(urlName: "http://xyphr.herokuapp.com/api/v1/identify_token", method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                //Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            completion(jsonResult["token"] as! String, nil)
                            
                        } else {
                            
                            print("auth code not found.")
                            completion("", nil)
                            
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                let errorMsg = NSError(domain:"", code: 401, userInfo:nil)
                // print(errorMsg)
                completion("", errorMsg)
                
            }
        }
    }

    
    // MARK: - Deauthenticate Current User.
    
    func deauthenticateCurrentUser(layerClient: LYRClient) {
        
        layerClient.deauthenticate { (success, error) in
            
            if !success {
                print("Failed to deauthenticate user: \(String(describing: error))")
                
            } else {
                
                print("User was deauthenticated")
                layerClient.disconnect()
                
            }
            
        }
        
    }
    
    
    // MARK: - Create Meta Data
    
    func createMetaDataOfSingleConversation(participant: ATLParticipant) -> [AnyHashable: Any] {
    
        // Get Admin user data
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return [:]
        }
        
        // Get user image.
        let userAvtarImage: String = self.checkAvatarImageURL(imageURL: participant.avatarImageURL)
        
        // Get user Admin image.
        let userAdminAvtarImage: String = self.checkAvatarImageURLString(imageStrURL: userInfoModel.image)

        // Get admin user id.
        let authUserID: String = String(userInfoModel.id ?? 0)
        if authUserID == "0" { return [:] }
        
        print(authUserID)
        
        // This meta data using for single conversation
        let metadata: [AnyHashable: Any] = ["title": "My Conversation",
                                           "conversation_type": "1",
                                           "user": ["user_id": participant.userID,
                                                     "user_display_name": participant.displayName,
                                                     "avatar_image": userAvtarImage
                                                    ],
                                           "user_Admin": ["user_id": authUserID,
                                                          "user_display_name": userInfoModel.fullname ?? "No Name",
                                                          "avatar_image": userAdminAvtarImage
                                                         ]
                                            ]
        
        print(metadata)
        
        return metadata
        
    }
    
    
    // MARK: - create set for group participants
    func createSetForGroupParticipants(authenticatedUser: String, participants: [AnyHashable]) -> Set<String> {
    
        // Create Random Group id
        let randomGroupID = "groupID_".randomString(length: 60)
        print(randomGroupID)

        // Get participantsIds
        var participantsIds = Set<String>()
        
        participantsIds.insert(authenticatedUser) // Add Admin user.
        participantsIds.insert(randomGroupID) // Add Random user id. Note:- This ID using for create the new group again and again.
        
        for i in 0..<participants.count {
            
            let participant: ATLParticipant = participants[i] as! ATLParticipant
            participantsIds.insert(participant.userID)
            
        }
        
        return participantsIds
    }
    
    
    
    // MARK: - Create Meta Data
    
    func createMetaDataOfGroupConversation(participants: [AnyHashable], groupTitle: String, groupImageName: String, groupImageURL: String) -> [AnyHashable: Any] {
        
        // Get Admin user data
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return [:]
        }
        
        // Get admin user id.
        let authUserID: String = String(userInfoModel.id ?? 0)
        if  authUserID == "0" { return [:] }
        
        // Get user Admin image.
        let userAdminAvtarImage: String = self.checkAvatarImageURLString(imageStrURL: userInfoModel.image)
        
        // Create Admin dict.
        var group_Admin_dict = Dictionary<String, AnyObject>()
        group_Admin_dict["user_id"] = authUserID as AnyObject
        group_Admin_dict["user_display_name"] = userInfoModel.fullname as AnyObject
        group_Admin_dict["avatar_image"] = userAdminAvtarImage as AnyObject
        
        
        // Create all participants user.
        var array_UserData = [Dictionary<String, AnyObject>]()
        
        for i in 0..<participants.count {
            
            let participant: ATLParticipant = participants[i] as! ATLParticipant

            // Get user image.
            let userAvtarImage: String = self.checkAvatarImageURL(imageURL: participant.avatarImageURL)
            
            // Create participants user dict.
            var user_dict = Dictionary<String, AnyObject>()
            user_dict["user_id"] = participant.userID as AnyObject
            user_dict["user_display_name"] = participant.displayName as AnyObject
            user_dict["avatar_image"] = userAvtarImage as AnyObject
            
            array_UserData.append(user_dict as Dictionary<String, AnyObject>)
            
        }
        
        // Get users json data.
        let data = try! JSONSerialization.data(withJSONObject: array_UserData, options: .prettyPrinted)
        print(data) /* convert array to data */
        
        let users_JSONObject = String(data: data as Data, encoding: String.Encoding.utf8)
        // try! JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
        print(users_JSONObject ?? "Data No Found") /* convert data to json */
        
        
        // This meta data using for Group conversation
        var metadata = [AnyHashable: Any]()
        
        metadata["title"] = groupTitle
        metadata["conversation_type"] = "2"
        metadata["group_imageName"] = groupImageName
        metadata["group_imageURL"] = groupImageURL
        metadata["user_Admin"]  = group_Admin_dict as Dictionary<String, AnyObject>
        metadata["users"] = users_JSONObject
        
        print(metadata)
        
        return metadata
        
    }
    
    
    
    
    
    // MARK: - check image with url
    
    func checkAvatarImageURL(imageURL: URL?) -> String {
    
        var avatarImageURL: String = ""
        
        if let url = imageURL {
            
            avatarImageURL = url.absoluteString
            
        } else {
            
            avatarImageURL = "http://xyphr.herokuapp.com/chat.png"
            
        }
        
        return avatarImageURL
    }
    
    
    // MARK: - check image with string

    func checkAvatarImageURLString(imageStrURL: String?) -> String {
        
        var avatarImageURL: String = ""
        
        if let imageURL = imageStrURL {
            
            avatarImageURL = imageURL
            
        } else {
            
            avatarImageURL = "http://xyphr.herokuapp.com/chat.png"
            
        }
     
        return avatarImageURL
    }
    
    
    // MARK: - convert data into json
    
    func convertUserDataToJson(users_dict: [Dictionary<String, AnyObject>]) -> Any  {
    
        let data = try! JSONSerialization.data(withJSONObject: users_dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        print(data) /* convert array to data */
        
        let users_JSONObject = try! JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
        print(users_JSONObject) /* convert data to json */
        
        return  users_JSONObject
        
    }
    
    
    
    // MARK: - Show mata data.
    // MARK: - Get Conversation title
    func getConversationTitle(conversation: LYRConversation) -> (title: String, dict: Dictionary<String, String>?, isSingleChat: Bool, groupDict: [String : Any]?) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return (title: "Personal Conversation", dict: nil, isSingleChat: true, groupDict: nil)
        }
        
        let authUserID: String = String(userInfoModel.id ?? 0)
        if authUserID == "0" { return (title: "Personal Conversation", dict: nil, isSingleChat: true, groupDict: nil)  }
        
        print(authUserID)
        
        let conversationType = conversation.metadata!["conversation_type"] as? String
        
        if conversationType == "1" {
            
            // Get user display name.
            let user = conversation.metadata!["user"] as! Dictionary<String, String>
            
            print(user)
            
            if authUserID != user["user_id"]! {
                
                return (title: user["user_display_name"]!, dict: user, isSingleChat: true, groupDict: nil)
                // return user["user_display_name"]!
                
            } else {
                
                let user_Admin = conversation.metadata!["user_Admin"] as! Dictionary<String, String>

                return (title: user_Admin["user_display_name"]!, dict: user_Admin, isSingleChat: true, groupDict: nil)
                // return user_Admin["user_display_name"]!
                
            }
            
            
        } else if conversationType == "2"  {
            
            print(conversation.metadata ?? "Data")
            
            return (title: conversation.metadata!["title"] as! String, dict: nil, isSingleChat: false, groupDict: conversation.metadata!)
            // return conversation.metadata!["title"] as! String
            
        }
        
        return (title: "Personal Conversation", dict: nil, isSingleChat: true, groupDict: nil)
        
    }
    
    // MARK: - Get Conversation Image
    func getConversationImage(conversation: LYRConversation) -> String  {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return "http://xyphr.herokuapp.com/chat.png"
        }
        
        let authUserID: String = String(userInfoModel.id ?? 0)
        if authUserID == "0" { return "http://xyphr.herokuapp.com/chat.png" }
        
        print(authUserID)
        
        let conversationType = conversation.metadata!["conversation_type"] as? String
        
        print(conversation.metadata ?? "data")
        
        if conversationType == "1" {
            
            // Get user display name.
            let user = conversation.metadata!["user"] as! Dictionary<String, String>
            
            if authUserID != user["user_id"]! {
                
                return user["avatar_image"]!
                
            } else {
                
                let user_Admin = conversation.metadata!["user_Admin"] as! Dictionary<String, String>
                return user_Admin["avatar_image"]!
                
            }
            
        } else if conversationType == "2"  {
            
            return conversation.metadata!["group_imageURL"] as! String
            
        }
        
        return "http://xyphr.herokuapp.com/chat.png"
        
    }
    
    
    func checkConversationGroupOrSingle(conversation: LYRConversation) -> Bool {
    
        let conversationType = conversation.metadata!["conversation_type"] as? String
        
        return conversationType == "1" ? true : false
        
    }
    
    
}
