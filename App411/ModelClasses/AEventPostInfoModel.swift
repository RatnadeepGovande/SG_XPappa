//
//  AEventPostInfoModel.swift
//  App411
//
//  Created by osvinuser on 7/31/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper

class AEventPostInfoModel: Mappable {
    
    var id: Int?
    var postContent: String?
    var postImageHeight: String?
    var postImageWidth: String?
    var postEventId : Int?
    var postImageName: String?
    var postImageURL: String?
    var postImageThumbnail: String?
    var postCreatedDate: String?
    var postUserID: Int?
    var postVideoFlag: Int?
    var postUserDict: AUserInfoModel?
    var like_status: Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        id                      <- map["id"]
        postContent             <- map["content"]
        postImageHeight         <- map["image_height"]
        postImageWidth          <- map["image_width"]
        postEventId             <- map["event_id"]
        postImageName           <- map["image_name"]
        postImageURL            <- map["image_url"]
        postImageThumbnail      <- map["thumbnail"]
        postUserID              <- map["user_id"]
        postVideoFlag           <- map["video_flag"]
        postUserDict            <- map["user"]
        postCreatedDate         <- map["create_date"]
        like_status             <- map["like_status"]
    }
    
}
