//
//  WebServiceClass.swift
//  ConstruPlaza
//
//  Created by osvinuser on 10/28/16.
//  Copyright © 2016 osvinuser. All rights reserved.
//

import Foundation
import UIKit

class WebServiceClass {
    
    static let sharedInstance = WebServiceClass()
    
    //MARK:- Data task
    open func dataTask(urlName: String, method: String, params: String, completion: @escaping (_ success: Bool, _ object: Any, _ errorMsg: String) -> ()) {
        
        let urlString: URL = URL(string: urlName)!
        
        //let body = self.createMultiPartBody(parameters: params as [[String : AnyObject]])
        print("API Name:- \(urlString) Get body Data: \(params)")
        
        let request = NSMutableURLRequest(url: urlString,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 60.0)
        request.httpMethod = method
        
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //request.allHTTPHeaderFields = self.requestHeaders()
        
        request.httpBody = params.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                // print(data ?? "No Data found")
                // print(response ?? "No Data found")
                // print(error?.localizedDescription ?? "No Data found")

                if (error != nil) {
            
                    //print(error?.localizedDescription ?? "error details not found")
                    //print(error ?? "error not found")
                    
                    completion(false, "", AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                    
                } else {
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode  {
                        
                        if response.statusCode == 201 || response.statusCode == 200 {
                            
                            // Check Data
                            if let data = data {
                                
                                // Json Response
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                                    
                                    completion(true, jsonResponse, "")
                                    
                                } else {
                                    
                                    completion(false, "", AKErrorHandler.CommonErrorMessages.INTERNAL_SERVER_ERROR)
                                    
                                }
                                
                            } else {
                     
                                completion(false, "", AKErrorHandler.CommonErrorMessages.INTERNAL_SERVER_ERROR)
                            
                            }
                            
                        } else {
                            
                            completion(false, "", AKErrorHandler.CommonErrorMessages.INTERNAL_SERVER_ERROR)
                        
                        }
                        
                    } else {
                        
                        completion(false, "", AKErrorHandler.CommonErrorMessages.UNKNOWN_ERROR_FROM_SERVER)
                    
                    }
                    
                }
                
            })

        })
        
        dataTask.resume()
                    
    }
    
    
    /// Create body of the multipart/form-data request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The multipart/form-data boundary
    ///
    private func createMultiPartBody(parameters: [[String: AnyObject]]) -> String {
       
        let boundary = generateBoundaryString()
        
        var body = ""
        let error: Error? = nil
        
        for param in parameters {
            let paramName = param["name"]!
            body += "\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
                let fileContent = try! String(contentsOfFile: filename as! String, encoding: String.Encoding.utf8)
                if (error != nil) {
                    print(error?.localizedDescription ?? "error not found")
                }
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                body += fileContent
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        
        return body
    }
    
    /// Set request Headers
    ///
    /// - returns:            headers list form of array.
    private func requestHeaders() -> [String: String] {
    
        let boundary = generateBoundaryString()
        
        let headers = [
            "content-type": "multupart/form-data; boundary=" + boundary,
            "cache-control": "no-cache"
        ]
        
        print(headers)
        
        return headers
        
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    private func generateBoundaryString() -> String {
        return "----\(NSUUID().uuidString)"
    }
    
    
}



