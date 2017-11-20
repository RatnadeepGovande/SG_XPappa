//
//  AUserInfoModel.swift
//  App411
//
//  Created by osvinuser on 6/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class AUserInfoModel: Mappable {
    
    var id: Int?
    var email: String?
    var fullname: String?
    var image: String?
    var description_bio: String?
    var device_token: String?
    var authentication_token: String?
    var dob: String?
    var email_verified_flag: String?
    var facebook_uid: String?
    var thumbnail: String?
    var latitute: String?
    var longitute: String?
    var hostStatus: Bool?
    var channelId: Int?
    var userFriendStatus: Int?
   

    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                   <- map["id"]
        email                <- map["email"]
        fullname             <- map["fullname"]
        image                <- map["image"]
        description_bio      <- map["description"]
        email_verified_flag  <- map["email_verified_flag"]
        authentication_token <- map["authentication_token"]
        dob                  <- map["dob"]
        facebook_uid         <- map["facebook_uid"]
        latitute             <- map["latitute"]
        longitute            <- map["longitute"]
        device_token         <- map["device_token"]
        thumbnail            <- map["thumbnail"]
        hostStatus           <- map["host_status"]
        channelId            <- map["channel_id"]
        userFriendStatus     <- map["friend_status"]

    }
    
    init(id: Int) {
        self.id = id
    }
    
}
