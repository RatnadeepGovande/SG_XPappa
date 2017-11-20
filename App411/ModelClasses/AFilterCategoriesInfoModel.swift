//
//  AFilterCategoriesInfoModel.swift
//  App411
//
//  Created by osvinuser on 7/10/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class AFilterCategoriesInfoModel: Mappable {
    
    var id: Int?
    var color_code: String?
    var created_at: String?
    var event_name: String?
    var status: String?
    var updated_at: String?

    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        id                   <- map["id"]
        color_code           <- map["color_code"]
        created_at           <- map["created_at"]
        event_name           <- map["event_name"]
        status               <- map["status"]
        updated_at           <- map["updated_at"]
    }
    
    
    init(id: Int?, color_code: String, created_at: String, event_name: String, status: String, updated_at: String) {
        self.id                   = id
        self.color_code           = color_code
        self.created_at           = created_at
        self.event_name           = event_name
        self.status               = status
        self.updated_at           = updated_at
    }
    
}
