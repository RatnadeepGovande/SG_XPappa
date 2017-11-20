//
//  Constants.swift
//  ConstruPlaza
//
//  Created by osvinuser on 10/28/16.
//  Copyright © 2016 osvinuser. All rights reserved.
//

import Foundation
import UIKit


struct SharedInstance {
    
    static let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    //    static func defaultRegularFontWithSize(size: CGFloat) -> UIFont {
    //        return UIFont(name: "ABeeZee-Regular", size: size)!
    //    }
    
    typealias myDict = Dictionary<String, Any>
    
    typealias callBack = () -> ()
    
    typealias SourceCompletionHandler = (_ success:AnyObject) -> () // for success case
    
    static let googlePicKey = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=60&key=AIzaSyCaSjiwkdmPQrKdhRCSWWJXFAq9gbFPuik&photoreference="
    
}


struct BranchConstants {
    
    static let branchKey = "key_live_acFPoxaLCw9h5AtQnS0TTpbpFwgZAZyk"
    static let branchSecret = "secret_live_C8XA6VzLmVtHZZGh3ToYDrGnT6Vk5Vfh"
    static let branchAppId = "437514188781278068"

}

struct NewsApiConstant {
    
    static let newsApiKey = "bdd8a8a2aa7049988a3cd27441db0e87"
    
    static let getSources = "https://newsapi.org/v1/sources?language=en"
    
    static let getNewsFromChannel = "https://newsapi.org/v1/articles?"

}

struct Constants {
    
    struct APIs {
        //http://xyphr.herokuapp.com/api/v1/profile_view
        // Base URL
        static let baseURL                      = "http://xyphr.herokuapp.com/api/v1/"
        
        // Email Valid (Check e-mail exists or not).
        static let emailValidation              = "validate_email"
        
        // SignUp API (create user at server or send verification code on email OTP)
        static let signUpFunction               = "users/"
        
        // Reset OTP (resend OTP to user).
        static let resentOTP                    = "resend_access_token"
        
        // Verfiy E-mail.
        static let verifyEmail                 = "verify_email"

        // Forgot password.
        static let forgotPassword               = "forgot_password"
        
        // Reset Password
        static let resetPassword                = "reset_password"
        
        // upload profile pic
        static let imageUpload                 = "image_upload"
        
        // Signin API
        static let signIn                       =  signUpFunction + "sign_in"
        
        // facebook login
        static let facebookLogin                =  "fb_login"
        
        // Filter Category list
        static let filter_category_list         = "category_list"
        
        // Flyers
        static let flyer_list                   = "flyer_list"
        
        // Create Event
        static let createEvent                  = "event_create"
        
        // Event Invite
        static let event_invite                 = "event_invite"
        
        // Apply Fliter 
        static let applyFliter                  = "apply_filter"
        
        // Event List
        static let eventList                    = "event_list"
        
        //Save Event List
        static let saveEventList                = "favourite_list"
        
        //Delete Event
        static let deleteEvent                  = "delete_event"
        
        //Event Spam
        static let spamEvent                    = "event_spam"
        
        //hosts List
        static let hostsList                    = "host_list"
        
        //Add Hosts List
        static let addHostsToEvent              = "add_event_host"
        
        //Save Event
        static let saveEvent                    = "add_to_favourite"
        
        static let event_post_like              = "event_post_like"

        
        //Notification list
        static let notificationList             = "notification_list"
        
        //Update Profile
        static let updateUserProfile            = "profile_update"
        
        // Search Friend API
        static let searchFriend                 = "search_friend"
        
        // Send Friend Request
        static let friendRequest                = "friend_request"
        
        // Get Friends list.
        static let friendList                   = "friend_list"
        
        //Unfriend User
        static let unfriendUser                 = "unfriend"
        
        // Accept Request
        static let accept_request               = "accept_request"
        
        // Delete Friend
        static let delete_friend                = "delete_request"

        static let updateProfile                = "profile_update"
        
        //Block User
        static let blockUserRequest             = "block_user"
        
        //UnBlock User
        static let unblockUserRequest           = "unblock_user"
        
        //Block List
        static let blockListRequest             = "block_list"
        
        

        //calendar Listing of Events Dates
        static let calendarListRequest          = "date_list"
        
        //calendar Listing of particular Event At Dates
        static let calendarListDetailRequest    = "date_detail"
        
        
        // Push Notification Status.
        static let pushNotificationStatus       = "notification_status"
        
        //Event Detail
        
        static let eventDetail                  = "single_event"
        
        //event Join
        static let eventJoin                    = "event_join"
        
        //create event post
        static let createEventPost              = "event_post_upload"
        
        
        
        
        // Timeline
        // Post on Timeline
        static let postOnTimeline               = "timeline_post_create"
        // Post List on Timeline
        static let postListOnTimeline           = "timeline_post_list"
        // Post Detail on Timeline
        static let timeline_post_detail         = "timeline_post_detail"
        
        //Group of event lists
        static let groupOfEventList             = "group_list"
        
        //Group of Detail event
        static let groupDetailEvent             = "group_show"
        
        //Admin Can Delete his group
        static let groupDelete                  = "group_delete"
        
        //Group of Create Event
        static let createGroupEvent             = "group_event_create"
        
        //exist Group
        static let existGroup                   = "group_exit"
        
        //group friend list
        static let groupFriendList              = "group_friend_list"
        
        //add member to group
        static let addMemberToGroup             = "add_member"
        
        //view all group members
        static let viewAllGroupMembers          = "group_members"
        
        //other user profile view
        static let otherUserProfile             = "profile_view"
        
        //other user profile view
        static let addGroupHost                 = "group_host"
        
        
        //create Group
        static let createGroup                  = "group_create"
        
        //edit Group
        static let editGroup                    = "group_edit"
        
        //user Spam
        static let userSpam                     = "user_spam"
        
        //event Spam
        static let eventSpam                    = "event_spam"
        
        //post Spam
        static let postSpam                     = "post_spam"
        
        //group Report Spam
        static let groupReportSpam              = "group_report_span"
        
        
        
        
        
        // Explore 
        // Store list 
        static let explore_story_list           = "explore_story_list"
        
        // Create Store.
        static let explore_story_create         = "explore_story_create"
        
        
        
        
        // Channel Module
        static let myChannelRequest             = "channel_detail"
        
        // Channel list
        static let channel_list                 = "channel_list"
        
        // Channel cover image or profile image
        static let channelImageUpdate           = "channel_image_update"
        
        // Channel Content Update
        static let channelContentUpdate         = "channel_content_update"
        
        // Channel post upload
        static let channelPostUpload            = "channel_post_upload"
        
        // Subscribe and unsubscribe
        static let subscribe_unsubscribe_channel = "subscribe_unsubscribe_channel"
        
        
        
        // signout user
        static let signoutUser                  = signUpFunction + "sign_out"
        
        //Donation Module
        
        static let getTokenPayment              = "get_token"
        
        static let sendPaymentTo411Server       = "payment_checkout"
        
        static let makeDonation                 = "make_donation"
        
        // identify_token 
        // This is using for layer chat.
        static let identify_token               = "identify_token"
        
    }
    
    struct googleConstants {
        
        static let placesUrl    = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        
        static let nearbysearch = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        
        static let placesKey    = "AIzaSyDUuwEiAxFjmCcFkCm-DVIaKhSJRba_mtI" // "AIzaSyBTpJNIFfwli5EqnrbvDmHCWJUwuGbI8uA"
        
    }
    
    struct ScreenSize {
        
        static let SCREEN_BOUNDS        = UIScreen.main.bounds
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        
    }
    
    struct DeviceType {
        
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad   && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
        static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad   && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    }
    
    

    
    
    struct appTitle {
        
        static let alertTitle        = "App411"
        
    }
    
//    struct appMessages {
//        
//        static let appMessage_logout     = "Do you want to logout?"
//        
//        static let blockUserMessage      = "Would you like to report this indiviual?"
//        
//        static let businessNameMessage   = "Please enter business name."
//        
//        static let businessSelectedMessage = "Please select business name."
//        
//        static let businessPositionSelectedMessage = "Please select position name."
//
//        static let deleteJobMessage = "Would you like to delete this job permanently?"
//        
//        static let PleaseAddJobMessage = "Active Job list is empty!"
//        
//        static let createGroupMessage = "Please add at least 2 user."
//        
//        static let locationValidation = "Location is not available of waiter."
//    }
//    
//    struct errorMessage {
//        
//        static let error_InternetConnectMessage     = "Please check your internet connect then try again."
//        
//        static let error_TextFieldIsEmpty           = "is empty."
//        
//        static let error_EmailValidationMessage     = "Please enter valid email."
//        
//        static let error_PasswordValidationMessage  = "should be atleast of 6 characters."
//
//        static let error_AllFieldsMessage           = "Please enter all Fields."
//        
//        static let error_WaitrRaterSelectionMessage = "Please select your Type."
//
//        static let error_SamePasswordMessage        = "New Password and Re-enter Password should be same."
//        
//        static let error_EnterMessage               = "Please enter message."
//        
//        static let error_SelectJobMessage           = "Please select a job."
//        
//        //API's Error Messages.
//        static let error_WaitrRater500 = "Internal Server Error. Please try again."
//
//    }
    
}
