//
//  ErrorHandler.swift
//  App411
//
//  Created by osvinuser on 6/29/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation

struct AKErrorHandler {

    struct CommonErrorMessages {
        
        static let Empty_Email_Password = "Email or Password does not exist."
        static let Empty_Email = "Please enter email."
        static let Empty_Password = "Please enter password."
        static let Valid_Email = "Please enter valid email. e.g example@xyz.com."
        static let Password_Valid = "Make sure it's 8 characters or more with atleast 1 Uppercase Alphabet, 1 Number & 1 Special Character."
        static let AllFields_Message = "Please enter all Fields."
        static let Blank_Fields = "should not be blank"
        static let Fields_Same = "New Password and Re-enter Password should be same."
        static let Enter_OTP = "Please enter OTP code."
        
        static let NO_INTERNET_AVAILABLE = "No internet, please check your internet connection and try again later."
        static let INTERNAL_SERVER_ERROR = "Unable to connect to server, please try again later."
        static let UNKNOWN_ERROR_FROM_SERVER = "Something went wrong. Please try again."
         static let enterText = "Please enter text."
    }
    
    struct CreateEvent {
        
        static let titleEmpty = "Please enter title."
        static let SubtitleEmpty = "Please enter subtitle."
        static let addLocation = "Please choose location."
        static let startTime = "Please select start time"
        static let endTime = "Please select end time"
        static let descriptionEmpty = "Please enter description"
        static let thingsTobring = "Please enter things to bring"
        static let thingsToPeople = "Please enter things that people will get"
        static let categoryEmpty = "Please select category"
        static let hostEmpty = "Please enter host name"
        static let selectMedia = "Please select media for event."
        static let donatethings = "Please choose which type of donation you want in your cause."

    }
}
