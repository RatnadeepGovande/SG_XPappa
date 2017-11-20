//
//  MyChannelDetail.swift
//  App411
//
//  Created by osvinuser on 8/24/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class MyChannelDetailInfoModel: Mappable {
    
    var id: Int?
    var profileImageName: String?
    var profileImageUrl: String?
    var channelBackgroundImageName: String?
    var channelBackgroundImageUrl: String?
    var channelName: String?
    var channelUserDict: AUserInfoModel?
    var channelDescription: String?

    var publicFlag: Bool?
    var subscriptionCount: Int?
    var subscribedChannel: Int?
    var SubscribeFlag: Bool?

    var myPostInfoArray = [AEventPostInfoModel]()
    var subscribedChannelArray = [ChannelListMoadelInfo]()
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                                    <- map["id"]
        profileImageName                      <- map["image"]
        profileImageUrl                       <- map["image_link"]
        channelBackgroundImageName            <- map["cover_image_name"]
        channelBackgroundImageUrl             <- map["cover_image_link"]
        channelName                           <- map["channel_name"]
        channelUserDict                       <- map["user_detail"]
        channelDescription                    <- map["channel_description"]

        publicFlag                            <- map["public_flag"]
        SubscribeFlag                         <- map["subcribtion_status"]
        
        myPostInfoArray                       <- map["post_detail"]
        subscribedChannelArray                <- map["subcribed_channel"]

    }
    
    
}
