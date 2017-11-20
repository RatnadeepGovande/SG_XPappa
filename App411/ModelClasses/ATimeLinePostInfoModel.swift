//
//  ATimeLinePostInfoModel.swift
//  App411
//
//  Created by osvinuser on 8/8/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class ATimeLinePostInfoModel: Mappable {
    
    var id: Int?
    var user_id: Int?
    var content: String?
    var event_flag: Int?
    var image_height: String?
    var image_width: String?
    var image_name: String?
    var image_url: String?
    var user: AUserInfoModel?
    var video_flag: Int?
    var updated_at: String?
    var comment: Int?
    var like: Int?
    var like_flag: Int?
    var thumbnail: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                    <- map["id"]
        user_id               <- map["user_id"]
        content               <- map["content"]
        event_flag            <- map["event_flag"]
        image_height          <- map["image_height"]
        image_width           <- map["image_width"]
        image_name            <- map["image_name"]
        image_url             <- map["image_url"]
        user                  <- map["user"]
        video_flag            <- map["video_flag"]
        updated_at            <- map["updated_at"]
        comment               <- map["comment"]
        like                  <- map["like"]
        like_flag             <- map["like_flag"]
        thumbnail             <- map["thumbnail"]
    }
    
}
