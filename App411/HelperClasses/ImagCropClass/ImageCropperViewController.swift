//
//  ImageCropperViewController.swift
//  ImageCropper
//
//  Created by Aatish Rajkarnikar on 10/4/16.
//  Copyright © 2016 iOSHub. All rights reserved.
//

import UIKit

protocol ImageCropperViewControllerDelegate {
    
    func imageCroppedDelegateMethod(cropImage: UIImage)
}

class ImageCropperViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView! {
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
        }
    }
    
    var selectedImage : UIImage?
    var delegate :ImageCropperViewControllerDelegate?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cropButton: UIButton!

    @IBOutlet var cropAreaView: CropAreaView!
    
    var cropArea:CGRect {
        
        get {
            
            let factor = imageView.image!.size.width/view.frame.width
            let scale = 1/scrollView.zoomScale
            let imageFrame = imageView.imageFrame()
            let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale * factor
            let y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
            let width = cropAreaView.frame.size.width * scale * factor
            let height = cropAreaView.frame.size.height * scale * factor
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = selectedImage
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func crop(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
            
            let croppedImage = UIImage(cgImage: croppedCGImage!)
            
            imageView.image = croppedImage
            scrollView.zoomScale = 1
            
        } else {
            
            self.delegate?.imageCroppedDelegateMethod(cropImage: imageView.image!)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}

extension UIImageView {
    
    func imageFrame()->CGRect {
        
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        
        if imageRatio < imageViewRatio {
            
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
            
        } else {
            
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}

class CropAreaView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}
