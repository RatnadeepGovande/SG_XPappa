//
//  CreatePostController.swift
//  App411
//
//  Created by osvinuser on 7/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import MobileCoreServices
import Cloudinary
import ObjectMapper


enum PostUploadType : Int {
    case eventPost = 1
    case timelinePost = 2
    case ChannelPost = 3
}

@objc protocol CreatePostControllerDelegate {
    
    @objc optional func isCreatePost(isSuccess: Bool)
    
}


class CreatePostController: UIViewController, ShowAlert {

    
    // Outlet
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var postSelectedImage: UIImageView!
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var showVideoButton: UIButton!
    
    @IBOutlet var postTextView: DesignableTextView!
    
    @IBOutlet var avatarImage: DesignableImageView!
    
    @IBOutlet var postButton: UIButton!
    
    @IBOutlet var tvHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var crossImageButton: UIButton!

    @IBOutlet var bottomViewConstarint: NSLayoutConstraint!
    
    @IBOutlet var imageView_Constarint: NSLayoutConstraint!
    
    var delegate :CreatePostControllerDelegate?
    
    // varibale
    var eventId: Int?
    
    var imageFullSize : UIImage?
    
    var imageThumbnailSize : UIImage?
    
    var videoURL : URL?
    
    var videoData: Data?
    
    
    var postUploadAtType: PostUploadType!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.title = "Create Post"
        self.tabBarController?.tabBar.isHidden = true
        
        showVideoButton.isHidden = true
        postTextView.delegate = self
        

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton"), style: .plain, target: self, action:  #selector(self.popFromViewCpntroller))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            avatarImage.sd_setImage(with: URL(string: userInfoModel.image ?? ""), placeholderImage: nil)
        }
        
        imageView_Constarint.constant = 0.0
        
        
        // Add Tap Gesture.
        self.addTapGesture()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: - Add tap gesture (for hidden view)
    
    internal func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        scrollView.addGestureRecognizer(tapGesture)
    }

    internal func hideKeyboard() {
        self.view.endEditing(true)
    }

    
    
    // MARK: - Keyboard Notification.
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomViewConstarint?.constant = 0.0
            } else {
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.bottomViewConstarint?.constant = endFrame?.size.height ?? 0.0
                })
            }
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    
    // MARK: - Pop view controller.
    
    internal func popFromViewCpntroller() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - IBAction

    @IBAction func crossImageAction(_ sender: Any) {
        self.resetAllValues()
    }


    @IBAction func postAction(_ sender: Any) {
        
        let trimmedStringPostString = ((postTextView.text ?? "") as NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        postTextView.text = trimmedStringPostString
        
        if postTextView.text.characters.count > 0 {
        
            if Reachability.isConnectedToNetwork() == true {
                
                // Post upload via Timeline and Event.
                self.postViewController(postUploadAtType: postUploadAtType)
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.enterText)

        }
        
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        
        self.uploadProfilePicClick()
        
    }
    
    @IBAction func playVideo(_ sender: Any) {
        
        let player = AVPlayer(url: videoURL!)
        
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            
            playerViewController.player!.play()
            
        }
        
    }
    
    internal func resetAllValues() {
        
        imageView_Constarint.constant = 0.0
        
        postSelectedImage.image = nil
        
        imageThumbnailSize = nil
        
        imageFullSize = nil
        
        videoURL = nil
        
        self.crossImageButton.isHidden = true
        
        if self.showVideoButton.isHidden {
            self.showVideoButton.isHidden = false
        }
        
        if postTextView.text.characters.count == 0 {
            postButton.isEnabled = false
        }
        
    }
    
    
    
    // MARK: - Post View Controller.
    // Using For Timeline Post.
    // Using For Event Post.
    internal func postViewController(postUploadAtType: PostUploadType) {
    
        // Data.
        var post_URL = ""
        
        let postText = postTextView.text ?? ""
        
        var randomIDTimelinePost = ""
        
        if postUploadAtType.rawValue == 1 {
            
            // Using for event post.
            randomIDTimelinePost = "EventPostPublicID_".randomString(length: 60)
            post_URL = Constants.APIs.baseURL + Constants.APIs.createEventPost
            
        } else if postUploadAtType.rawValue == 2 {
            
            // Useing For Timeline post.
            randomIDTimelinePost = "TimelinePostPublicID_".randomString(length: 60)
            post_URL = Constants.APIs.baseURL + Constants.APIs.postOnTimeline
            
        } else if postUploadAtType.rawValue == 3 {
            
            // Using for Channel post.
            randomIDTimelinePost = "ChannelPostPublicID_".randomString(length: 60)
            post_URL = Constants.APIs.baseURL + Constants.APIs.channelPostUpload
        }
        

        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            if let authToken = userInfoModel.authentication_token {
                
                if postSelectedImage.image == nil {
                    
                    // Show Loaders.
                    Methods.sharedInstance.showLoader()
                    
                    randomIDTimelinePost = ""
                    
                    
                    if postUploadAtType.rawValue == 1 {
                    
                        // Using for event post.
                        self.postUploadOnEventByUserToken(APIUrl: post_URL, authToken: authToken, postDataText: postText, videoThumbnailURL: "", postDataPublicID: randomIDTimelinePost, postDataURL: "", isVideo: "2", eventID: String(eventId ?? 0), imageWidth: "0", imageHeight: "0")
                        
                    } else if postUploadAtType.rawValue == 2 {
                    
                        // Useing For Timeline post.
                        self.postUploadOnTimeLineByUserToken(APIUrl: post_URL, authToken: authToken, postDataText: postText, videoThumbnailURL: "", postDataPublicID: randomIDTimelinePost, postDataURL: "", isVideo: "2", imageWidth: "0", imageHeight: "0")
                        
                    } else if postUploadAtType.rawValue == 3 {
                    
                        // Using for Channel post.
                        self.postUploadOnChannelByUserToken(APIUrl: post_URL, authToken: authToken, postDataText: postText, videoThumbnailURL: "", postDataPublicID: randomIDTimelinePost, postDataURL: "", isVideo: "2", imageWidth: "0", imageHeight: "0")
                    }
                    
                    
                } else {
                    
                    if videoURL == nil {
                        
                        if let image = imageThumbnailSize {
                        
                            if let imageData = UIImageJPEGRepresentation(image, 0.6) {
                            
                                let imageWidth = "\(image.size.width)"
                                let imageHeight = "\(image.size.height)"
                                
                                // Show Loaders.
                                Methods.sharedInstance.showLoader()
                                
                                // post text and image
                                self.uploadImageOnCloudinaryByData(APIUrl: post_URL, authToken: authToken, postDataText: postText, publicID: randomIDTimelinePost, imageData: imageData, imageWidth: imageWidth, imageHeight: imageHeight, isVideo: "0", postUploadAtType: postUploadAtType)
                            
                            }
                            
                        }
                        
                    } else {
                        
                        
                        if let fileURL = videoURL {
                        
                            // Show Loaders.
                            Methods.sharedInstance.showLoader()
                            
                            let videoThumbnailID = "TimelinePostVideoThumnailPublicID_".randomString(length: 60)
                            
                            self.uploadVideoOnCloudinaryByURL(APIUrl: post_URL, authToken: authToken, postDataText: postText, videoThumbnailPublicID: videoThumbnailID, publicID: randomIDTimelinePost, fileURL: fileURL, isVideo: "1", postUploadAtType: postUploadAtType)
                            
                        }
                        
                    }
                    
                }
                
                
            } else {
                
                print("user auth token not found")
                
            }
            
        } else {
            
            print("user data not found")
        }
        
        
    }
    
    
    
    // MARK: - Alert Methods
    
     internal func uploadProfilePicClick() {
        
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            print("Take Photo")
            let customCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraCustomController") as! CameraCustomController
            customCamera.delegate = self
            
            self.navigationController?.present(customCamera, animated: true, completion: nil)
            
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Photos Library", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String, kUTTypeMovie as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.resetAllValues()
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                print("Image Selected")
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage , type: 0)

            }
            
            if mediaType == "public.movie" {
                print("Video Selected")
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerMediaURL] as! URL , type: 1)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}


extension CreatePostController : UITextViewDelegate {
    
    //MARK: textview delegates
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let messagetext = ((textView.text ?? "") as NSString).replacingCharacters(in: range, with: text)
        let newString = messagetext.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            postButton.isEnabled = true
        } else {
            
            postButton.isEnabled = false
            return text == "" ? true : false
            
        } // end else.
        
        return true
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let maxValue: CGFloat = (Constants.ScreenSize.SCREEN_HEIGHT - 400)

        if size.height != tvHeightConstraint.constant && size.height > textView.frame.size.height {
            
            tvHeightConstraint.constant = size.height
            textView.setContentOffset(CGPoint.zero, animated: false)
            
            if size.height > maxValue {
                let bottomOffset = CGPoint(x: 0, y: size.height - maxValue)
                scrollView.setContentOffset(bottomOffset, animated: true)
            } else {
                scrollView.setContentOffset(CGPoint.zero, animated: false)
            }
            
        } else {
            
            tvHeightConstraint.constant = size.height
            textView.setContentOffset(CGPoint.zero, animated: false)
            
            if size.height > maxValue {
                let bottomOffset = CGPoint(x: 0, y: size.height - maxValue)
                scrollView.setContentOffset(bottomOffset, animated: false)
            } else {
                scrollView.setContentOffset(CGPoint.zero, animated: false)
            }
            
        }
        
    }
    
    
}

extension CreatePostController : CameraCustomControllerDelegate {
    
    //MARK: Camera Delegate Method
    func fetchImageAndVideoURL(url: Any?, type: Int, error: Error!) {
        
        if (error != nil) {
            print(error.localizedDescription)
            return
        }
        
        self.resetAllValues()
        
        self.getImageAndThumbnailOfImage(image: url , type: type)
        
    }
    
    //MARK: convert local URL and Image into Thumbnail
    fileprivate func getImageAndThumbnailOfImage(image: Any?, type: Int) {
        
        var imageThumbnail : UIImage?
        
        if type == 0 {
            
            showVideoButton.isHidden = true
            
            imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = image as? UIImage
            
        } else {
            
            showVideoButton.isHidden = false
            
            imageThumbnail = (image as! URL).createThumbnailFromUrl()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = imageThumbnail!
            videoURL = image as? URL
            
            if let videoUrl = videoURL {
                getDataFromUrl(url: videoUrl) { (data, response, error)  in
                    guard let data = data, error == nil else { return }
                    print("Download Finished")
                    DispatchQueue.main.async() { () -> Void in
                        self.videoData = data
                    }
                }
            }
        }
        
        self.postSelectedImage.image  = self.imageFullSize

        if self.imageFullSize != nil {
            imageView_Constarint.constant = self.getImageViewHeight(imageViewW: self.postSelectedImage.frame.width, imgView: self.imageFullSize!)
        }
        
        self.crossImageButton.isHidden = false
        
        postButton.isEnabled = true
        
    }
    
    func getImageViewHeight(imageViewW: CGFloat, imgView: UIImage) -> CGFloat {
    
        var newheight: CGFloat
        
        if imgView.size.height > imgView.size.width {
            newheight = imageViewW * (imgView.size.height/imgView.size.width)
        } else {
            newheight = imageViewW / (imgView.size.height/imgView.size.width)
        }
        
        return newheight
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }

}


//        guard let videoData = videoData else {
//            print("video url cannot be converted into data")
//
//            return
//        }


//        cloudinary.createUploader().signedUpload(data: videoData, params: params, progress: { (progress) in
//                        print(progress)
//
//        }) { (respone, error) in
//
//            if error != nil {
//
//                Methods.sharedInstance.hideLoader()
//
//                self.showAlert(error?.localizedDescription ?? "No Error Found")
//
//            } else {
//
//                print(respone ?? "Not Found")
//
//                if let cldUploadResult: CLDUploadResult = respone {
//
//                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
//                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
//
//                    if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
//
//                        self.sendPostDataToServer(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
//                    }
//                }
//
//               }
//        }
