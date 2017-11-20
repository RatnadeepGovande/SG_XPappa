//
//  ATimeLineCommentInfoModel.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class ATimeLineCommentInfoModel: Mappable {
    
    var id: Int?
    var user_id: Int?
    var content: String?
    var updated_at: String?
    var user: AUserInfoModel?

    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                    <- map["id"]
        user_id               <- map["user_id"]
        content               <- map["content"]
        updated_at            <- map["updated_at"]
        user                  <- map["user"]
        
    }
    
}


