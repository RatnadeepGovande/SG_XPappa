// The MIT License (MIT)
//
// Copyright (c) 2015 Meng To (meng@designcode.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@IBDesignable public class DesignableTextField: SpringTextField {
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    @IBInspectable var leftAddView: CGRect = CGRect.zero
    @IBInspectable var leftimageView: CGRect = CGRect.zero
    
    @IBInspectable public var placeholderColor: UIColor = UIColor.clear {
        didSet {
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName: placeholderColor])
            layoutSubviews()
            
        }
    }
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    
    
    @IBInspectable var SideImage:UIImage? {
        didSet {
            
            let leftAddView = UIView(frame: self.leftAddView)
            let leftimageView = UIImageView(frame: self.leftimageView)
            leftimageView.image = SideImage
            leftAddView.addSubview(leftimageView)
            
            self.leftView = leftAddView
            self.leftViewMode = UITextFieldViewMode.always
        }
        
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y, width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
   
    @IBInspectable public var lineHeight: CGFloat = 1.5 {
        didSet {
            let font = UIFont(name: self.font!.fontName, size: self.font!.pointSize)
            let text = self.text
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight
            
            let attributedString = NSMutableAttributedString(string: text!)
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: 0, length: attributedString.length))
            
            self.attributedText = attributedString
        }
    }
    
}
