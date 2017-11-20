//
//  ANotificationInfoModel.swift
//  App411
//
//  Created by osvinuser on 7/18/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class ANotificationInfoModel: Mappable {
    
    var id: Int?
    var image: String?
    var notification_content: String?
    var notification_message: String?
    var notification_title: String?
    var event: Dictionary<String, AnyObject>?
    var user: Dictionary<String, AnyObject>?
    var updated_at: String?

    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                    <- map["id"]
        image                 <- map["image"]
        notification_content  <- map["notification_content"]
        notification_message  <- map["notification_message"]
        notification_title    <- map["notification_title"]
        updated_at            <- map["updated_at"]
        user                  <- map["user"]
        event                 <- map["event"]
        
    }
    
}
