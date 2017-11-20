//
//  GroupEventEditViewController.swift
//  App411
//
//  Created by osvinuser on 8/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import AVKit
import ObjectMapper
import Cloudinary

class GroupEventEditViewController: UIViewController, ShowAlert {
    
    @IBOutlet fileprivate var tableView_Main: UITableView!
    @IBOutlet fileprivate var editButton: UIButton!
    fileprivate var createEventInfoParams: [String: AnyObject] = ["groupTitle" : "" as AnyObject, "groupDescription": "" as AnyObject]
    
    var groupEventData : AGroupEventInfoModel!
    var imageFullSize = UIImage()
    var imageThumbnailSize = UIImage()
    var videoURL : URL!
    fileprivate var isMediaSelected = Bool()
    fileprivate var isImagePick = false
    var isImageChange : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackground()
        
        self.registerTableViewNibs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        createEventInfoParams["groupTitle"] = groupEventData.groupName as AnyObject
        createEventInfoParams["groupDescription"] = groupEventData.groupDescription as AnyObject
        
    }
    
    // MARK: Keyboard Notifications
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView_Main.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView_Main.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    internal func registerTableViewNibs() {
        
        tableView_Main.estimatedRowHeight = 50
        
        tableView_Main.register(UINib(nibName: "TableViewCellSignUpProfilePic", bundle: nil), forCellReuseIdentifier: "TableViewCellSignUpProfilePic")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextField", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextField")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextView", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextView")
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")
        
    }
    
    @IBAction func showEditProfile(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            self.tableView_Main.reloadData()
            
        } else {
            
            if validation() {
                
                if Reachability.isConnectedToNetwork() == true {
                    //self.createEventAPI()
                    self.uploadImageToServer()
                } else {
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                }
                
            }
        }
        
    }
    
    //MARK:- Validation
    internal func validation() -> Bool {
        
        if (createEventInfoParams["groupTitle"] as! String).characters.count == 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.titleEmpty)
            
        } else if (createEventInfoParams["groupDescription"] as! String).characters.count == 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.SubtitleEmpty)
            
        }  else if !isMediaSelected {
            
            self.EditGroupAPI(authToken: "", imageName: groupEventData.groupImageName ?? "", imageURL: groupEventData.groupImageUrl ?? "")
            return true
        } else {
            
            return true
        }
        
        return false
        
    }
    
    //MARK: - Webservice Method
    internal func uploadImageToServer() {
        
        if isImageChange == true {
            
            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
            
            var profileName = String()
            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                
                profileName = "profile_user_id_" + String(userInfoObj.id!)
            }
            
            Methods.sharedInstance.showLoader()
            
            let config = CLDConfiguration(cloudinaryUrl: CLOUDINARY_URL)
            let cloudinary = CLDCloudinary(configuration: config!)
            
            let params = CLDUploadRequestParams()
            params.setTransformation(CLDTransformation().setGravity(.northWest))
            params.setPublicId(profileName)
            
            if videoURL == nil {
                
                cloudinary.createUploader().signedUpload(data: UIImageJPEGRepresentation(imageThumbnailSize, 1.0)!, params: params, progress: { (progress) in
                    
                    print(progress)
                    
                }, completionHandler: { (respone, error) in
                    
                    if error != nil {
                        
                        Methods.sharedInstance.hideLoader()
                        
                        self.showAlert(error?.localizedDescription ?? "No Error Found")
                        
                    } else {
                        
                        print(respone ?? "Not Found")
                        
                        if let cldUploadResult: CLDUploadResult = respone {
                            
                            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                                
                                self.EditGroupAPI(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
                                
                            }
                            
                        }
                        
                    }
                })
                
            } else {
                
                let params = CLDUploadRequestParams()
                params.setResourceType(.video)
                params.setTransformation(CLDTransformation().setGravity(.northWest))
                
                //Video Upload Code
                cloudinary.createUploader().signedUpload(url: videoURL, params: params , progress: { (progress) in
                    print(progress)
                    
                }, completionHandler: { (respone, error) in
                    
                    if error != nil {
                        
                        Methods.sharedInstance.hideLoader()
                        
                        self.showAlert(error?.localizedDescription ?? "No Error Found")
                        
                    } else {
                        
                        print(respone ?? "Not Found")
                        
                        if let cldUploadResult: CLDUploadResult = respone {
                            
                            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                                
                                self.EditGroupAPI(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
                                
                            }
                            
                        }
                        
                    }
                })
                
            }
        } else {
            
            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
            
            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                
                self.EditGroupAPI(authToken: userInfoObj.authentication_token!, imageName: self.groupEventData.groupImageName ?? "", imageURL: self.groupEventData.groupImageUrl ?? "")
            }
        }
    }
    
    //MARK:- Create Event API.
    internal func EditGroupAPI(authToken: String, imageName: String, imageURL: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,group_id,description,name,image_link,image_name,video_flag
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&video_flag=\(videoURL == nil ? 0 : 1)&image_link=\(imageURL)&image_name=\(imageName)&name=\(createEventInfoParams["groupTitle"] as AnyObject)&description=\(createEventInfoParams["groupDescription"] as AnyObject)&group_id=\(groupEventData.id ?? 0)"
        
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.editGroup, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode == true  {
                        
                        self.moveTobackTwo()
                        
                        self.showAlert("Your group has been updated.")
                        
                    } else {
                        
                        print("Worng data found.")
                        self.showAlert(jsonResult["message"] as? String ?? "")
                        
                    }
                }
            }
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueOptionFlyer" {
            
            let destinationView: ChooseFlyerViewController = segue.destination as! ChooseFlyerViewController
            destinationView.delegate = self
            
        }
        
    }
    
    
}

extension GroupEventEditViewController : CameraCustomControllerDelegate {
    
    //MARK: Camera Delegate Method
    func fetchImageAndVideoURL(url: Any?, type: Int, error: Error!) {
        
        if (error != nil) {
            print(error.localizedDescription)
            return
        }
        
        isImageChange = true
        
        self.getImageAndThumbnailOfImage(image: url , type: type)
    }
    
    //MARK: convert local URL and Image into Thumbnail
    fileprivate func getImageAndThumbnailOfImage(image: Any?, type: Int) {
        
        let cell: TableViewCellSignUpProfilePic = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellSignUpProfilePic
        
        var imageThumbnail : UIImage?
        isMediaSelected = true
        
        if type == 0 {
            
            // playVideoButton.isHidden = true
            
            imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = image as! UIImage
            
        } else {
            
            // playVideoButton.isHidden = false
            
            imageThumbnail = (image as! URL).createThumbnailFromUrl()
            imageThumbnailSize = imageThumbnail!
            
            
            videoURL = image as! URL
        }
        
        cell.imageView_Images.image = imageThumbnail
        
    }
    
}


extension GroupEventEditViewController: UITableViewDelegate, UITableViewDataSource, TableViewCellSignUpProfilePicDelegate, ChooseFlyerViewControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:TableViewCellSignUpProfilePic = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSignUpProfilePic") as! TableViewCellSignUpProfilePic
            
            cell.selectionStyle = .none
            
            cell.imageView_Images.layer.cornerRadius = (cell.imageView_Images.frame.size.width)/2
            
            cell.imageView_Images.clipsToBounds = true
            
            if !isImagePick {
                //If event_image contains video then below condition will execute or vice - versa.
                if self.groupEventData.videoFlag == 1 {

                    var videoImage: UIImage = UIImage(named: "ic_no_image")!
                    
                    if let videoString = self.groupEventData.groupImageUrl{
                        
                        URL(fileURLWithPath: videoString).createImageThumbnailFrom(returnCompletion: { (imageFromVideo) in
                            
                            DispatchQueue.main.async {
                                
                                if let imageThum =  imageFromVideo {
                                    videoImage = imageThum
                                }
                            }
                            
                        })
                    }
                    
                    cell.imageView_Images.image = videoImage
                    
                } else {
                    
                    cell.imageView_Images.sd_setImage(with: URL(string: self.groupEventData.groupImageUrl ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
                }
            }
            
            if editButton.isSelected {
                cell.delegate = self
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            
            
            return self.getTableViewCellCreateEventTextField(tableView: tableView, indexPath: indexPath)
            
            
        } else if indexPath.section == 2 {
            
            let cell:TableViewCellCreateEventTextView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextView") as! TableViewCellCreateEventTextView
            
            if editButton.isSelected {
                cell.textView_EnterText.delegate = self
            }
            
            
            self.addToolBar(textView: cell.textView_EnterText)
            
            cell.textView_EnterText.isUserInteractionEnabled = editButton.isSelected
            
            cell.textView_EnterText.text = self.groupEventData.groupDescription
            
            cell.selectionStyle = .none
            
            return cell
            
        }  else  {
            
            let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
            
            if editButton.isSelected {
                //cell.delegate = self
            }
            
            cell.label_Text.text = "Make the group public"
            
            cell.switch_ButtonOutlet.isUserInteractionEnabled = false
            
            cell.switch_ButtonOutlet.setOn(self.groupEventData.publicFlag ?? false, animated:true)
            
            cell.selectionStyle = .none
            
            return cell
            
        }
    }
    
    internal func getTableViewCellCreateEventTextField(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        if editButton.isSelected {
            cell.textField_EnterText.delegate = self
        }
        
        cell.textField_EnterText.isUserInteractionEnabled = editButton.isSelected
        
        cell.textField_EnterText.placeholder = "Group Name"
        
        cell.textField_EnterText.text = self.groupEventData.groupName
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 10.0
            
        } else {
            
            return 40.0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return section == 3  ? 10.0 : 0.1
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        } else if section == 1 {
            
            return self.setHeaderView(title: "Group Name")
            
        }else if section == 2 {
            
            return self.setHeaderView(title: "Group Description")
            
        } else {
            
            return self.setHeaderView(title: "Availability")
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
    }
    
    
    // MARK:- Header View.
    internal func setHeaderView(title: String) -> UIView {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_Title.text = title
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 16)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            self.performSegue(withIdentifier: "segueUploadEventProfile", sender: self)
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 180.0
            
        } else if indexPath.section == 1 {
            
            return 50
            
        } else if indexPath.section == 2 {
            
            return 150
        } else {
            
            return 50
        }
    }
    
    //MARK:- Cell Delegates
    func uploadProfilePicClick(sender: UIButton) {
        
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            print("Take Photo")
            
            let customCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraCustomController") as! CameraCustomController
            customCamera.delegate = self
            
            self.navigationController?.present(customCamera, animated: true, completion: nil)
            
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Choose Photo", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        let choosFlyerAction = UIAlertAction(title: "Choose Flyer", style: .default)
        { _ in
            print("Choose Flyer")
            self.performSegue(withIdentifier: "segueOptionFlyer", sender: self)
        }
        actionSheetControllerIOS8.addAction(choosFlyerAction)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            isImageChange = true
            if mediaType  == "public.image" {
                print("Image Selected")
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage , type: 0)
                
            } else if mediaType == "public.movie" {
                print("Video Selected")
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerMediaURL] as! URL , type: 1)
                
            }
        }
        
        isImagePick = true
        
        isMediaSelected = true
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func selectedImageFromList(image: UIImage) {
        
        print(image)
        self.getImageAndThumbnailOfImage(image: image, type: 0)
        
    }
    
    
}


extension GroupEventEditViewController : UITextFieldDelegate, UITextViewDelegate, TableViewCellSwitchDelegates {
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        createEventInfoParams["groupDescription"] = textView.text as AnyObject
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            let pointInTable:CGPoint = textView.superview!.convert(textView.frame.origin, to: self.tableView_Main)
            var contentOffset:CGPoint = self.tableView_Main.contentOffset
            contentOffset.y  = pointInTable.y
            if let accessoryView = textView.inputAccessoryView {
                contentOffset.y -= accessoryView.frame.size.height
            }
            self.tableView_Main.contentOffset = contentOffset
        })
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        createEventInfoParams["groupTitle"] = textField.text as AnyObject
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            
            // Do something of string
            createEventInfoParams["groupTitle"] = textField.text as AnyObject
            
        } else {
            
            return string == "" ? true : false
        } // end el
        
        return true
        
    }
    
    func changeSwitchButtonStatus(sender: UISwitch) {
        
        createEventInfoParams["EventAvailability"] =  (sender.isOn ? false : true) as AnyObject
        
    }
    
}
