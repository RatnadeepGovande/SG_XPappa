//
//  ACreateEventInfoModel.swift
//  App411
//
//  Created by osvinuser on 7/17/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper

class ACreateEventInfoModel: Mappable {
    
    var id: Int?
    var user_id: Int?
    var title: String?
    var sub_title: String?
    var start_event_date: String?
    var end_event_date: String?
    var description: String?
    var things_people_get: String?
    var things_to_bring: String?
    var event_category_id: Int?
    var event_image: String?
    var event_Thumbnail: String?

    var group_event_flag: Bool?
    var group_event_id: String?
    var latitute: String?
    var longitude: String?
    var host_name: String?
    var availability: String?
    var event_place_address: String?
    var event_place_name: String?
    var event_video_flag: String?
    var event_views: Int?
    var event_favorite: Bool?
    var event_join: Bool?
    var host_flag: Bool?
    var causeDonationType: Int?
    var causelatitute: String?
    
    
    var causelongitude: String?
    var causeAddress: String?

    
    var event_postArray = [AEventPostInfoModel]()
    var event_JoinArray = [AUserInfoModel]()
    var event_HostArray = [AUserInfoModel]()
    var donationArray   = [DonationMoneyModel]()

    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        id                      <- map["id"]
        user_id                 <- map["user_id"]
        title                   <- map["title"]
        sub_title               <- map["sub_title"]
        start_event_date        <- map["start_event_date"]
        end_event_date          <- map["end_event_date"]
        description             <- map["description"]
        things_people_get       <- map["things_people_get"]
        things_to_bring         <- map["things_to_bring"]
        things_to_bring         <- map["things_to_bring"]
        event_category_id       <- map["event_category_id"]
        event_image             <- map["event_image"]
        event_Thumbnail         <- map["thumbnail_image"]

        group_event_flag        <- map["group_event_flag"]
        group_event_id          <- map["group_event_id"]
        latitute                <- map["latitute"]
        longitude               <- map["longitude"]
        host_name               <- map["host_name"]
        availability            <- map["availability"]
        event_place_address     <- map["event_place_address"]
        event_place_name        <- map["event_place_name"]
        event_video_flag        <- map["video_flag"]
        event_views             <- map["views"]
        event_favorite          <- map["favourite_status"]
        event_join              <- map["join_flag"]
        event_postArray         <- map["post"]
        event_JoinArray         <- map["join.user"]
        event_HostArray         <- map["host"]
        host_flag               <- map["host_flag"]
        donationArray           <- map["donation"]
        causeDonationType       <- map["cause_donationType"]
        causeAddress            <- map["cause_address"]
        causelatitute           <- map["causeLat"]
        causelongitude          <- map["causeLong"]
    }
    
    
    init(id: Int, user_id:Int) {
        self.id = id
        self.user_id = user_id

    }
    
}



class DonationMoneyModel: Mappable {
    
    var userId: Int?
    var email: String?
    var fullname: String?
    var image: String?
    var imageName: String?
    var dob: String?
    var city: String?
    var gender: String?
    var country: String?
    var state: String?
    var eventID: Int?
    var donationID: Int?
    var donationType: String?
    var amountDonate: String?
    var showUser: Bool?

    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {

        userId               <- map["id"]
        email                <- map["email"]
        fullname             <- map["fullname"]
        image                <- map["image"]
        
        imageName            <- map["image_name"]
        dob                  <- map["dob"]
        city                 <- map["city"]
        gender               <- map["gender"]
        country              <- map["country"]
        state                <- map["state"]
        
        eventID              <- map["event_id"]
        donationType         <- map["donation_type"]
        donationID           <- map["donation_id"]
        amountDonate         <- map["amount"]
        showUser             <- map["show_user"]
        
    }
    
}
