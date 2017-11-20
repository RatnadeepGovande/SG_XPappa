//
//  ActionCableClientSingleton.swift
//  App411
//
//  Created by osvinuser on 8/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ActionCableClient
import ObjectMapper

// MARK: - Singleton
final class ActionCableClientSingleton {
    
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let sharedInstance = ActionCableClientSingleton()


    
    
    
    /* Timeline like & dislike func */
    var roomChannel_PostLike: Channel!
    
    // MARK :- subscribePostLikeChannel
    
    internal func subscribePostLikeChannel() {
        
        // Channel name PostLike
        // param auth_token, status, post_id
        // Action timeline_post_like
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // let actionCableClient = ActionCableClient(url: URL(string: "wss://xyphr.herokuapp.com/cable")!)
        
        // The channel name must match the class name on the server
        // let roomChannel = appDelegateShared.actionCableClient.create("PostLikeChannel")
        // More advanced usage
        let room_identifier = ["auth_token" : userInfoModel.authentication_token ?? ""]
        roomChannel_PostLike = appDelegateShared.actionCableClient.create("PostLikeChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)
        
        
        // Receive a message from the server. Typically a Dictionary.
        roomChannel_PostLike.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON ?? "", error ?? "")
            
            if error != nil {
                print("Error post like: \(String(describing: error?.localizedDescription))")
                return
            }
            
            
            if let json = JSON as? Dictionary<String, AnyObject> {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadSubscribePostLikeChannelNotification"), object: self, userInfo: ["json": json])
                
            } else {
                
                print("This is not valid json........Post Like")
            }
            
        }
        
        // A channel has successfully been subscribed to.
        roomChannel_PostLike.onSubscribed = {
            print("successfully post like subscribed")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel_PostLike.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel_PostLike.onRejected = {
            print("Rejected")
        }
        
    }
    
    
    /* Timeline Comment func */
    var roomChannel_PostComment: Channel!
    
    // MARK :- subscribePostLikeChannel
    
    internal func subscribePostCommentChannel() {
        
        // Channel name PostLike
        // param auth_token, status, post_id
        // Action timeline_post_like
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // let actionCableClient = ActionCableClient(url: URL(string: "wss://xyphr.herokuapp.com/cable")!)
        
        // The channel name must match the class name on the server
        // let roomChannel = appDelegateShared.actionCableClient.create("PostLikeChannel")
        // More advanced usage
        let room_identifier = ["auth_token" : userInfoModel.authentication_token ?? ""]
        roomChannel_PostComment = appDelegateShared.actionCableClient.create("PostCommentChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)
        
        
        // Receive a message from the server. Typically a Dictionary.
        roomChannel_PostComment.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON ?? "", error ?? "")
            
            if error != nil {
                print("Error post like: \(String(describing: error?.localizedDescription))")
                return
            }
            
            
            if let json = JSON as? Dictionary<String, AnyObject> {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadSubscribePostCommentChannelNotification"), object: self, userInfo: ["json": json])
                
            } else {
                
                print("This is not valid json........Post Like")
            }
            
        }
        
        // A channel has successfully been subscribed to.
        roomChannel_PostComment.onSubscribed = {
            print("successfully post like subscribed")
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel_PostComment.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel_PostComment.onRejected = {
            print("Rejected")
        }
        
    }
    
    
}
