//
//  File.swift
//  ConstruPlaza
//
//  Created by osvinuser on 10/20/16.
//  Copyright © 2016 osvinuser. All rights reserved.
//

import Foundation
import UIKit


extension String {
    
    /* Email validation */
    func isValidEmail() -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    /* Password validation */
    func isPasswordValid() -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$").evaluate(with: self)
    }
    
    /* String Length */
    var length: Int {
        return (self as NSString).length
    }
    
    /* String Width */
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size.width
    }
    
    /* String Height */
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size.height
    }
    
    /* Random String */
    func randomString(length: Int) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        var _: String = formatter.string(from: Date())
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = self
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        randomString += randomString
        
        return randomString
    }
    
    
    /* Event Data Format  */
    func eventDataFormat() -> Date {
    
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM d, yyyy h:mm a"
        let dateInString: Date = dateFormatterGet.date(from: self)!
        
        return dateInString
        
    }
    
    /* String Height */
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics], attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    /* String Width */
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
        
    }
    
}

extension NSMutableAttributedString {
    
    @discardableResult func bold(_ text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: FontNameConstants.SourceSansProBold, size: CGFloat(fontSize))!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func mid(_ text: String, fontSize: Int) -> NSMutableAttributedString {
        
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: FontNameConstants.SourceSansProRegular, size: CGFloat(fontSize))!]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func attributedValue(_ text:String, fontName: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: fontName, size: fontSize)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String, fontSize: Int) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: FontNameConstants.SourceSansProRegular, size: CGFloat(fontSize))!]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
}


