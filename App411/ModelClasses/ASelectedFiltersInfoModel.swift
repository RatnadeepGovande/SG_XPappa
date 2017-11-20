//
//  ASelectedFiltersInfoModel.swift
//  App411
//
//  Created by osvinuser on 8/23/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper


class ASelectedFiltersInfoModel: Mappable {
    
    var id: Int?
    var event_category_id: Int?
    var user_id: Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        id                   <- map["id"]
        event_category_id    <- map["event_category_id"]
        user_id              <- map["user_id"]
    }
    
    init(id: Int?, event_category_id: Int?, user_id: Int?) {
        self.id                   = id
        self.event_category_id    = event_category_id
        self.user_id              = user_id
    }
    
}
