//
//  SingletonClass.swift
//  App411
//
//  Created by osvinuser on 7/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation


// MARK: - Singleton
final class Singleton {
    
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let sharedInstance = Singleton()
    
    
    // MARK: Local Variable
    var categoryListInfo : [AFilterCategoriesInfoModel] = []
    
    var filterSelectedListInfo : [ASelectedFiltersInfoModel] = []
    
    var filterDistance : String!
    
    
    // MARK: Event List Array
    var array_eventList = [ACreateEventInfoModel]()
    
    // MARK:- Places List Array.
    var array_PlacesList: [Dictionary<String, AnyObject>] = []
    
    
    // MARK: UserCurrent Location
    var userCurrentLocation: CLLocationCoordinate2D!
    
    
    
    func getImageNameByCategoryId(Id: Int) -> UIImage {
        
        let image_Marker: UIImage!
        
        switch Id {
            
        case 1:
            image_Marker = #imageLiteral(resourceName: "BussinessMarker")
            
        case 2:
            image_Marker = #imageLiteral(resourceName: "RomanceMarker")
            
        case 3:
            image_Marker = #imageLiteral(resourceName: "SocialMarker")
            
        case 4:
            image_Marker = #imageLiteral(resourceName: "EducationMarker")
            
        case 5:
            image_Marker = #imageLiteral(resourceName: "EntertainmentMarker")
            
        case 6:
            image_Marker = #imageLiteral(resourceName: "ShoppingMarker")
            
        case 7:
            image_Marker = #imageLiteral(resourceName: "SportsMarker")
            
        case 8:
            image_Marker = #imageLiteral(resourceName: "FeaturedMarker")
            
        case 9:
            image_Marker = #imageLiteral(resourceName: "HotEventMarker")
            
            
        default:
            image_Marker = #imageLiteral(resourceName: "BussinessMarker")
        }
        
        return image_Marker
        
    }
    
    
    func getDateFormatterFromServer(stringDate: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let date = dateFormatter.date(from: stringDate)
        return date
        
    }
    
    
    func calculateImageViewSize(imageW: CGFloat, imageH: CGFloat, cellW: CGFloat) -> CGFloat {
        
        print("image width \(imageW) image height \(imageH) cell Width \(cellW)")
        
        if imageW > imageH {
            
            let ratio = imageW / cellW
            
            if imageW > cellW {
                
                let newHeight = imageW / ratio
                return newHeight
                
            } else {
                
                let newHeight = imageW * ratio
                return newHeight
                
            }
            
        } else {
            
            let ratio = imageW / imageH
            let newHeight = cellW / ratio
            return newHeight
            
        }
        
    }
    
    func calculateCellHeightByPostModelInfo(postModelInfo: ATimeLinePostInfoModel, frame: CGRect, indexPath: IndexPath) -> CGSize {
        
        let staticHeight: CGFloat =  8 + 44 + 4 + 4 + 24 + 8 + 0.5 + 8 + 40 + 16
        
        var cellSize: CGSize = CGSize(width: frame.size.width, height: staticHeight)
        
        if let statusText = postModelInfo.content {
            
            let textheight = statusText.height(withConstrainedWidth: frame.size.width-16, font: UIFont.systemFont(ofSize: 14))
            
            cellSize.height += textheight
            cellSize.height += 10
            
        }
        
        
        if let videoFlag = postModelInfo.video_flag {
            
            if videoFlag == 0 {
                
                print(postModelInfo)
                
                let imageWidth = NumberFormatter().number(from: postModelInfo.image_width ?? "320")
                let imageHeight = NumberFormatter().number(from: postModelInfo.image_height ?? "480")
                
                cellSize.height += self.calculateImageViewSize(imageW: imageWidth as! CGFloat, imageH: imageHeight as! CGFloat, cellW: frame.size.width)
                
                cellSize.height -= 15
                
            } else if videoFlag == 1 {
                cellSize.height += 300
            }
            
        }
        
        return cellSize
        
    }
    
    
    func clearTmpDirectory() {
        
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
    }
}
