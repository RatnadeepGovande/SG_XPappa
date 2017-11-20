//
//  AFindFriendInfoModel.swift
//  App411
//
//  Created by osvinuser on 7/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class AFindFriendInfoModel: Mappable {
    
    var id: Int?
    var email: String?
    var fullname: String?
    var image: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        id                   <- map["id"]
        email                <- map["email"]
        fullname             <- map["fullname"]
        image                <- map["image"]
    }
    
}
