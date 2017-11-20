//
//  AFlyerInfoModel.swift
//  App411
//
//  Created by osvinuser on 7/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class AFlyerInfoModel: Mappable {
    
    var id: Int?
    var event_category_id: Int?
    var created_at: String?
    var flyer_title: String?
    var updated_at: String?
    var flyer_image: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
    
        id                   <- map["id"]
        event_category_id    <- map["event_category_id"]
        created_at           <- map["created_at"]
        flyer_title          <- map["flyer_title"]
        updated_at           <- map["updated_at"]
        flyer_image          <- map["flyer_image"]
    
    }
    
}
