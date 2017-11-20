//
//  CloudinarySingletonClass.swift
//  App411
//
//  Created by osvinuser on 8/8/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation
import Cloudinary


// Cloudonary URL
let CLOUDINARY_URL = "cloudinary://653422148562277:BTDeVD3eJaIjrUQU8KK-C-mLpkY@dj7w3dx3o"


// MARK: - Singleton
final class CloudinarySingletonClass {
    
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let sharedInstance = CloudinarySingletonClass()

    
    // MARK: - configuration of cloudinary
    func configurationOfCloudinary(publicID: String, resourceType: CLDUrlResourceType) -> (cloudinary: CLDCloudinary, params: CLDUploadRequestParams) {

        let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
        let cloudinary = CLDCloudinary(configuration: config!)
        
        let params = CLDUploadRequestParams()
        params.setTransformation(CLDTransformation().setGravity(.northWest))
        params.setPublicId(publicID)
        params.setResourceType(resourceType)
        
        return (cloudinary, params)
        
    }
    
    
}
