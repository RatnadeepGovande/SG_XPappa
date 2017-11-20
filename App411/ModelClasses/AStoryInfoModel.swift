//
//  AStoryInfoModel.swift
//  App411
//
//  Created by osvinuser on 8/21/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class AStoryInfoModel: Mappable {
    
    var id: Int?
    var userId: Int?
    var latitute: String?
    var longitute: String?
    var video_flag: String?
    var image_name: String?
    var image_link: Bool?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id            <- map["id"]
        userId        <- map["user_id"]
        latitute      <- map["latitute"]
        longitute     <- map["longitute"]
        video_flag    <- map["video_flag"]
        image_name    <- map["image_name"]
        image_link    <- map["image_link"]
        
    }
    
}
