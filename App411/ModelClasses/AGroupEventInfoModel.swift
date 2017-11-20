//
//  AGroupEventInfoModel.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class AGroupEventInfoModel: Mappable {
    
    var id: Int?
    var userId: Int?
    var groupDescription: String?
    var groupImageName: String?
    var groupImageUrl: String?
    var groupName: String?
    var publicFlag: Bool?
    var videoFlag: Int?
    var isGroupHost: Bool?
    var isGroupJoin: Bool?
    
    var eventArray = [ACreateEventInfoModel]()
    var event_JoinArray = [AUserInfoModel]()
    var event_HostsArray = [AUserInfoModel]()
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                    <- map["id"]
        userId                <- map["user_id"]
        groupDescription      <- map["description"]
        groupImageName        <- map["image_name"]
        groupImageUrl         <- map["image_link"]
        groupName             <- map["name"]
        publicFlag            <- map["public_flag"]
        videoFlag             <- map["video_flag"]
        eventArray            <- map["group_event"]
        event_JoinArray       <- map["group_members"]
        event_HostsArray      <- map["group_hosts"]
        isGroupHost           <- map["host_flag"]
        isGroupJoin           <- map["join_status"]
        
    }
    
    
}
