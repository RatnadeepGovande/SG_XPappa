
import Foundation
import UIKit
import AVKit
import AVFoundation
import Photos



extension UIImage {
    
    func createImageThumbnailFromImage() -> UIImage {
        
        let src: CGImageSource = CGImageSourceCreateWithData(UIImageJPEGRepresentation(self, 1.0)! as CFData, nil)!
        
        let options : [NSObject:AnyObject] = [
            kCGImageSourceShouldAllowFloat : true as AnyObject,
            kCGImageSourceCreateThumbnailWithTransform : true as AnyObject,
            kCGImageSourceCreateThumbnailFromImageAlways : true as AnyObject,
            kCGImageSourceThumbnailMaxPixelSize : 640 as AnyObject
        ]
        
        let thumbnail: CGImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary)!
        let thumbanal = UIImage(cgImage: thumbnail)
        return thumbanal
        
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}



extension URL {
    
    func createThumbnailFromUrl() -> UIImage? {
        
        let filePath: URL = self
        
        do {
            let asset = AVURLAsset(url: filePath , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            // thumbnail here
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
    }
    
    func createImageThumbnailFrom(returnCompletion: @escaping (UIImage?) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                let asset = AVURLAsset(url: self , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                returnCompletion(thumbnail)
                // thumbnail here
                
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
                returnCompletion(UIImage())
                
            }
            
        }
        
    }
}
