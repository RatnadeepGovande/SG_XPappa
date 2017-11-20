//
//  ViewControllerExtensions.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Photos
import MobileCoreServices

struct CallBackMethods {
    
    typealias SourceCompletionHandler = (_ success:AnyObject) -> () // for success case
}


extension UIViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func alertFunctionsWithCallBack(title : String, isThirdButton: Bool = false, completionHandler:@escaping CallBackMethods.SourceCompletionHandler) {
        
        let alertController = UIAlertController(title: Constants.appTitle.alertTitle, message: title, preferredStyle:UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default)
        { action -> Void in
            // Put your code here
            completionHandler(true as AnyObject)
        })
        
        alertController.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default)
        { action -> Void in
            // Put your code here
            completionHandler(false as AnyObject)
        })
        
        if isThirdButton == true {
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            { action -> Void in
                // Put your code here
                completionHandler(2 as AnyObject)
            })
        }
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: { _ in }) // present the alert
        }
        
    }
    
    public func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGRect {
        
        // CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude)
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame
        
    }
    
    
    func setViewBackground() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ImageBackground")!)
    }
    
    
    func addToolBar(textView: UITextView) {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = appColor.appTabbarSelectedColor
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.donePressed))
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([/*cancelButton,*/ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.inputAccessoryView = toolBar
        
    }
    
    func donePressed(){
        view.endEditing(true)
    }
    
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    
    func addToolBarFor(textField: UITextField) {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = appColor.appTabbarSelectedColor
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.donePressed))
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([/*cancelButton,*/ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.inputAccessoryView = toolBar
        
    }
    
    
    
    func openImagePickerViewController(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        
        if sourceType == .camera {
            
            self.checkPermissionsCamera(sourceType: sourceType, mediaTypes: mediaTypes)
            
        } else {
            
            self.checkPhotoStatusPhotos(sourceType: sourceType, mediaTypes: mediaTypes)
        }
        
    }
    
    func checkPermissionsCamera(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch cameraAuthorizationStatus {
            
        case .denied:
            self.alertPromptToAllowCameraAccessViaSetting(accessType: "Camera")
        case .authorized:
            self.openImagePicker(sourceType: sourceType, mediaTypes: mediaTypes)
        case .restricted:
            self.alertPromptToAllowCameraAccessViaSetting(accessType: "Camera")
        case .notDetermined:
            self.openAccessCameraPop(mediaTypes: mediaTypes)
            
        }
        
    }
    
    func checkPhotoStatusPhotos(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        
        let photsAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photsAuthorizationStatus {
            
        case .denied:
            self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
        case .authorized:
            self.openImagePicker(sourceType: sourceType, mediaTypes: mediaTypes)
        case .restricted:
            self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
        case .notDetermined:
            self.openAccessPhotoLibraryPop(mediaTypes: mediaTypes)
            
        }
        
    }
    
    func openAccessCameraPop(mediaTypes: [String]) {
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted) in
            
            if(granted){
                self.openImagePicker(sourceType: .camera, mediaTypes: mediaTypes)
            } else {
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Camera")
            }
            
        }
    }
    
    func openAccessPhotoLibraryPop(mediaTypes: [String]) {
        
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
            
            switch status {
                
            case .denied:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                break
                
            case .authorized:
                self.openImagePicker(sourceType: .photoLibrary, mediaTypes: mediaTypes)
                break
                
            case .restricted:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                break
                
            case .notDetermined:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                break
                
            }
            
        })
        
    }
    
    
    func openImagePicker(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.mediaTypes = mediaTypes
        self.present(picker, animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func alertPromptToAllowCameraAccessViaSetting(accessType: String) {
        
        let alert = UIAlertController(title: "Access to \(accessType) is restricted", message: "You need to enable access to \(accessType). Apple Settings > Privacy > \(accessType).", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })
        
        present(alert, animated: true)
        
    }
    
    
    func showPopIfLocationServiceIsDisable() {
        
        let alert = UIAlertController(title: "Access to GPS is restricted", message: "GPS access is restricted. Show events by location, please enable GPS in the Settings > Privacy > Location Services.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            print("")
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true)
        
    }
    
    
    func getDateFormatterFromServer(stringDate: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //2017-10-09T16:50:51Z
        let date = dateFormatter.date(from: stringDate)
        return date
        
    }
    
    func getDateFormatterFromServer(stringDate: String, dateFormat forDate:String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.dateFormat = forDate
        
        //2017-10-09T16:50:51Z
        let date = dateFormatter.date(from: stringDate)
        return date
        
    }
    
    func generateThumnail(url : URL) -> UIImage? {
        
        let asset: AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time        : CMTime = CMTimeMake(1, 30)
        let img         : CGImage
        
        do {
            try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: UIImage = UIImage(cgImage: img)
            return frameImg
        } catch {
            
        }
        return nil
        
    }
    
    internal func setNavigationBar() {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 16)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    internal func moveToPrevious() {
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    internal func moveTobackTwo() {
        
        guard let navigationObject = self.navigationController else {
            
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        let viewControllers: [UIViewController] = navigationObject.viewControllers as [UIViewController]
        navigationObject.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    
    internal func moveToDetailEvent(row: Int, arrayObject : [ACreateEventInfoModel]) {
        
        let instanceObject = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        instanceObject.eventModelData = arrayObject[row]
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(instanceObject, animated: true)
        
    }
    
    internal func showUserProfile(_ userData: AUserInfoModel) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instanceObject = storyboard.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
        instanceObject.selectedUserProfile = userData
        self.navigationController?.pushViewController(instanceObject, animated: true)
        
    }
    
    internal func convertDictionaryIntoString(paramDict: Dictionary<String, AnyObject>) -> String {
        
        let cookieHeader = (paramDict.flatMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: "&")
        
        print(cookieHeader) // key2=value2;key1=value1
        return cookieHeader
    }
    
    internal func clearBackgroundColor() -> UIView {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
    }
    
}

extension UIRefreshControl {
    
    func beginRefreshingManually() {
        
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
    }
}


/* UIView Extension for add consgtraints */
extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary  = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
    
}

extension UITableView {
    
    internal func setBackGroundOfTableView(arrayBlockedList: [AnyObject]) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
            
            if arrayBlockedList.count <= 0 {
                
                let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                
                view_NoData.label_Text.text = "No Data Found"
                
                self.backgroundView = view_NoData
                
            } else {
                
                self.backgroundView = nil
                
            }
            
        })
        
    }
    
}
