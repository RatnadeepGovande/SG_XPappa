//
//  ExploreEventModel.swift
//  App411
//
//  Created by osvinuser on 9/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import MapKit

class ExploreEventModel: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var id: Int?
    var user_id: Int?
    var title: String?
    var eventSubtitle: String?
    var start_event_date: String?
    var end_event_date: String?
    var eventDescription: String?
    var things_people_get: String?
    var things_to_bring: String?
    var event_category_id: Int?
    var event_image: String?
    var group_event_flag: Bool?
    var group_event_id: String?
    var host_name: String?
    var availability: String?
    var event_place_address: String?
    var event_place_name: String?
    var event_video_flag: String?
    var event_views: Int?
    var event_favorite: Bool?
    var event_join: Bool?
    
    var causeDonationType: Int?
    var causelatitute: String?
    var causelongitude: String?
    var causeAddress: String?
    
    init(coordinate: CLLocationCoordinate2D, eventDict: Dictionary<String, AnyObject>) {
        
        self.coordinate         = coordinate
        
        id                      = eventDict["id"] as? Int ?? 0
        user_id                 = eventDict["user_id"] as? Int ?? 0
        title                   = eventDict["title"] as? String ?? ""
        eventSubtitle           = eventDict["sub_title"] as? String ?? ""
        start_event_date        = eventDict["start_event_date"] as? String ?? ""
        end_event_date          = eventDict["end_event_date"] as? String ?? ""
        eventDescription        = eventDict["description"] as? String ?? ""
        things_people_get       = eventDict["things_people_get"] as? String ?? ""
        things_to_bring         = eventDict["things_to_bring"] as? String ?? ""
        event_category_id       = eventDict["event_category_id"] as? Int ?? 0
        event_image             = eventDict["event_image"] as? String ?? ""
        group_event_flag        = eventDict["group_event_flag"] as? Bool ?? false
        group_event_id          = eventDict["group_event_id"] as? String ?? ""
        host_name               = eventDict["host_name"] as? String ?? ""
        availability            = eventDict["availability"] as? String ?? ""
        event_place_address     = eventDict["event_place_address"] as? String ?? ""
        event_place_name        = eventDict["event_place_name"] as? String ?? ""
        event_video_flag        = eventDict["video_flag"] as? String ?? ""
        event_views             = eventDict["views"] as? Int ?? 0
        event_favorite          = eventDict["favourite_status"] as? Bool ?? false
        event_join              = eventDict["join_flag"] as? Bool ?? false
        causeDonationType       = eventDict["cause_donationType"] as? Int ?? 0
        causeAddress            = eventDict["cause_address"] as? String ?? ""
        causelatitute           = eventDict["causeLat"] as? String ?? ""
        causelongitude          = eventDict["causeLong"] as? String ?? ""
        
    }
    
    
    
}

class AnnotationView: MKAnnotationView
{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}
