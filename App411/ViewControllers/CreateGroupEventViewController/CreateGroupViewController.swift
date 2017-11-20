//
//  CreateGroupViewController.swift
//  App411
//
//  Created by osvinuser on 8/8/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import AVKit
import ObjectMapper
import Cloudinary

class CreateGroupViewController: UIViewController, ShowAlert {
    
    @IBOutlet fileprivate var tableView_Main: UITableView!
    @IBOutlet var playVideoButton: UIButton!
    fileprivate var createEventInfoParams: [String: AnyObject] = ["groupTitle" : "" as AnyObject, "groupDescription": "" as AnyObject, "groupMembers": "" as AnyObject, "EventAvailability": "1" as AnyObject]
    
    var imageFullSize = UIImage()
    var imageThumbnailSize = UIImage()
    var videoURL : URL!
    fileprivate var isMediaSelected = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackground()

        tableView_Main.estimatedRowHeight = 50
        
        tableView_Main.register(UINib(nibName: "TableViewCellSignUpProfilePic", bundle: nil), forCellReuseIdentifier: "TableViewCellSignUpProfilePic")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextField", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextField")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextView", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextView")
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")

        
        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    //Remove Observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.25, animations: {
                
                let edgeInsets = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
                self.tableView_Main.contentInset = edgeInsets
                self.tableView_Main.scrollIndicatorInsets = edgeInsets
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25, animations: {
            
            let edgeInsets = UIEdgeInsets.zero
            self.tableView_Main.contentInset = edgeInsets
            self.tableView_Main.scrollIndicatorInsets = edgeInsets
        })
    }

    @IBAction func showVideo(_ sender: Any) {
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
    }
    
    //MARK:- Validation
    internal func validation() -> Bool {
        
        if (createEventInfoParams["groupTitle"] as! String).characters.count == 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.titleEmpty)
            
        } else if (createEventInfoParams["groupDescription"] as! String).characters.count == 0 {
            
            self.showAlert(AKErrorHandler.CreateEvent.SubtitleEmpty)
            
        }  else if !isMediaSelected {
            
            self.showAlert(AKErrorHandler.CreateEvent.selectMedia)
        } else {
            
            return true
        }
        
        return false
        
    }
    
    func createGroupEvent(sender:UIButton!) {
        print("Button Clicked")
        
        if validation() {
          
            if Reachability.isConnectedToNetwork() == true {
                //self.createEventAPI()
                self.uploadImageToServer()
            } else {
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }

        }
    }
    
    //MARK: - Webservice Method
    internal func uploadImageToServer() {
        
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
                            
                            self.createGroupAPI(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
                            
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
                            
                            self.createGroupAPI(authToken: userInfoObj.authentication_token!, imageName: cldUploadResult.publicId!, imageURL: cldUploadResult.url!)
                            
                        }
                        
                    }
                    
                }
            })
            
        }
        
    }
    
    //MARK:- Create Event API.
    internal func createGroupAPI(authToken: String, imageName: String, imageURL: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        var hostIdsString : String?
        if let selectedFriendList: [AFriendInfoModel] = createEventInfoParams["EventHostIds"] as? [AFriendInfoModel] {
            let ids = selectedFriendList.flatMap { String($0.id ?? 0) }
            hostIdsString = ids.joined(separator: ", ")
        }
        
        //auth_token,name,image_name,image_link,description,video_flag,user_ids,public_flag
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&video_flag=\(videoURL == nil ? 0 : 1)&image_link=\(imageURL)&image_name=\(imageName)&name=\(createEventInfoParams["groupTitle"] as AnyObject)&description=\(createEventInfoParams["groupDescription"] as AnyObject)&user_ids=\(hostIdsString ?? "")&public_flag=\(createEventInfoParams["EventAvailability"] as AnyObject)"
        
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.createGroup, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode == true  {
                        
                        self.showAlert(jsonResult["message"] as? String ?? "")
                        self.moveToGroupListViewController()
                    } else {
                        
                        print("Worng data found.")
                        self.showAlert(jsonResult["message"] as? String ?? "")
 
                    }
                }
            }
        }
        
    }
    
    internal func moveToGroupListViewController() {
        
        let tabBarControl: MainTabbarViewController = self.storyboard!.instantiateViewController(withIdentifier: "MainTabbarViewController") as! MainTabbarViewController
        SharedInstance.appDelegate?.window!.rootViewController = tabBarControl
        tabBarControl.selectedIndex = 4
        
        if let nc = tabBarControl.viewControllers![4] as? UINavigationController {
            
            let messageViewController = storyboard?.instantiateViewController(withIdentifier: "EventGroupListViewController") as! EventGroupListViewController
            
            nc.pushViewController(messageViewController, animated: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueOptionFlyer" {
            
            let destinationView: ChooseFlyerViewController = segue.destination as! ChooseFlyerViewController
            destinationView.delegate = self
            
        } else if segue.identifier == "seguehostname" {
            
            let destinationView = segue.destination as? HostNameFriendListViewController
            destinationView?.isPresentHost = false
            destinationView?.isAddMembers = true
            destinationView?.eventInfoMapperObj = sender as? ACreateEventInfoModel
            destinationView?.delegate = self
            
        }
        
    }

}

extension CreateGroupViewController : CameraCustomControllerDelegate {
    
    //MARK: Camera Delegate Method
    func fetchImageAndVideoURL(url: Any?, type: Int, error: Error!) {
        
        if (error != nil) {
            print(error.localizedDescription)
            return
        }
        
        self.getImageAndThumbnailOfImage(image: url , type: type)
    }
    
    //MARK: convert local URL and Image into Thumbnail
    fileprivate func getImageAndThumbnailOfImage(image: Any?, type: Int) {
        
        let cell: TableViewCellSignUpProfilePic = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellSignUpProfilePic
        
        var imageThumbnail : UIImage?
        isMediaSelected = true
        
        if type == 0 {
            
            playVideoButton.isHidden = true
            
            imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
            imageThumbnailSize = imageThumbnail!
            imageFullSize = image as! UIImage
            
        } else {
            
            playVideoButton.isHidden = false
            
            imageThumbnail = (image as! URL).createThumbnailFromUrl()
            imageThumbnailSize = imageThumbnail!
            
            videoURL = image as! URL
            
        }
        
        cell.imageView_Images.image = imageThumbnail
        
    }

}

extension CreateGroupViewController: UITableViewDelegate, UITableViewDataSource, TableViewCellSignUpProfilePicDelegate, ChooseFlyerViewControllerDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            
            return 2
        } else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:TableViewCellSignUpProfilePic = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSignUpProfilePic") as! TableViewCellSignUpProfilePic
            
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            return cell
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
              return self.getTableViewCellCreateEventTextField(tableView: tableView, indexPath: indexPath)
                
            } else {
                
                let cell:TableViewCellCreateEventTextView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextView") as! TableViewCellCreateEventTextView
                
                cell.textView_EnterText.delegate = self
                
                self.addToolBar(textView: cell.textView_EnterText)
                
                cell.textView_EnterText.text = createEventInfoParams["groupDescription"] as? String ?? ""
                                
                cell.selectionStyle = .none
                
                return cell
  
            }
            
        } else if indexPath.section == 2 {
            
            return self.getTableViewCellCreateEventTextField(tableView: tableView, indexPath: indexPath)
                
        } else {
            
                let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
                
                cell.delegate = self
                
                cell.label_Text.text = "Make the group public"
                
                cell.switch_ButtonOutlet.setOn(createEventInfoParams["EventAvailability"] as? Bool ?? true, animated:true)
            
                cell.selectionStyle = .none
                
                return cell
                
        }
        
    }
    
    internal func getTableViewCellCreateEventTextField(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        cell.textField_EnterText.delegate = self
        cell.textField_EnterText.isUserInteractionEnabled = indexPath.section == 1 ? true : false
        
        cell.textField_EnterText.placeholder = indexPath.section == 1 ? "Group Name" : "Add Members"

        if indexPath.section == 2 {
            if let selectedFriendList: [AFriendInfoModel] = createEventInfoParams["EventHostIds"] as? [AFriendInfoModel] {
                
                let ids = selectedFriendList.flatMap( { String($0.fullname ?? "") } )
                
                let joinIdsString = ids.joined(separator: ", ")
                cell.textField_EnterText.text = joinIdsString
                
            }
        } else {
            
            cell.textField_EnterText.text = createEventInfoParams["groupTitle"] as? String ?? ""
        }

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
        
        return section == 3 ? 70.0 : 0.1
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        } else if section == 1 {
            
            return self.setHeaderView(title: "Group Details")
            
        } else if section == 2 {
            
            return self.setHeaderView(title: "Add Members")

        } else {
            
            return self.setHeaderView(title: "Availability")

        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 3 {
            
            let hearderView: UIView = UIView()
            hearderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70)
            hearderView.backgroundColor = UIColor.clear
            
            let btn = UIButton(type: .custom) as UIButton
            btn.setTitle("Create Group", for: .normal)
            btn.setTitleColor(UIColor.red, for: .normal)
            btn.frame = CGRect(x: 0, y: 0, width: hearderView.frame.size.width/1.2, height: 40)
            btn.center = hearderView.center
            btn.addTarget(self, action: #selector(createGroupEvent), for: .touchUpInside)
            hearderView.addSubview(btn)
        
            return hearderView
            
        } else {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
        }
        
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
            
            self.performSegue(withIdentifier: "segueOptionFlyer", sender: self)
            
        } else if indexPath.section == 2 {
            
            self.performSegue(withIdentifier: "seguehostname",  sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 180.0
            
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                return 50
            } else {
                 return 150
            }
            
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
            
            if mediaType  == "public.image" {
                print("Image Selected")
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage , type: 0)
                
            } else if mediaType == "public.movie" {
                print("Video Selected")
                self.getImageAndThumbnailOfImage(image: info[UIImagePickerControllerMediaURL] as! URL , type: 1)
                
            }
        }
        
        isMediaSelected = true
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func selectedImageFromList(image: UIImage) {
        
        print(image)
        self.getImageAndThumbnailOfImage(image: image, type: 0)
        
    }
    
}

extension CreateGroupViewController: UITextFieldDelegate, UITextViewDelegate, TableViewCellSwitchDelegates, HostNameFriendListViewControllerDelegate {
    
    
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
            
        } else {
            
            return string == "" ? true : false
        } // end el
        
        return true
        
    }
    
    func changeSwitchButtonStatus(sender: UISwitch) {
        
        createEventInfoParams["EventAvailability"] =  (sender.isOn ? true : false) as AnyObject
        
    }
    
    func clickOnDoneButton(selectedFriendList: [AFriendInfoModel]) {
        
        createEventInfoParams["EventHostIds"] = selectedFriendList as AnyObject
        tableView_Main.reloadSections(IndexSet(integer: 2), with: .automatic)
    
    }
    
}

