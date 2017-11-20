//
//  MyProfileViewController.swift
//  App411
//
//  Created by osvinuser on 7/18/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import Cloudinary
import ObjectMapper
import MobileCoreServices

class MyProfileViewController: UIViewController, ShowAlert {
    
    @IBOutlet var tableView_Main: UITableView!
    @IBOutlet var editButton: UIButton!
    
    
    var array_TableData = ["Profile", "About Me", "Email", "Date Of Birth"]
    var createEventInfoParams: [String: AnyObject] = ["Name" : "" as AnyObject, "DateOfBirth" : "" as AnyObject, "AboutMe": "" as AnyObject, "userImage" : "" as AnyObject]
    var params = [String: String]()

    
    fileprivate var startEventBool = false
    fileprivate var isImagePick = false
    fileprivate var isUserChangeAnything = false
    
    
    var imageFullSize = UIImage()
    var imageThumbnailSize = UIImage()
    
    var selectedUserProfile: AUserInfoModel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView_Main.register(UINib(nibName: "TableViewProfileCell", bundle: nil), forCellReuseIdentifier: "TableViewProfileCell")
        tableView_Main.register(UINib(nibName: "TableViewProfileAboutMe", bundle: nil), forCellReuseIdentifier: "TableViewProfileAboutMe")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextField", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextField")
        tableView_Main.register(UINib(nibName: "TableViewCellDatePicker", bundle: nil), forCellReuseIdentifier: "TableViewCellDatePicker")
        
        self.setViewBackground()
        tableView_Main.estimatedRowHeight = 80
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.showDataOnStaticView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Keyboard Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView_Main.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView_Main.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
    }
    
    
    // MARK: - Show Data On Server.
    
    func showDataOnStaticView() {
    
        if selectedUserProfile != nil {
            
            if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
                if userInfoModel.id == selectedUserProfile?.id {
                
                    // Current Login User Data.
                    editButton.setTitle("Edit", for: .normal)
                    editButton.tag = 1
                    
                    createEventInfoParams["AboutMe"] = userInfoModel.description_bio as AnyObject
                    createEventInfoParams["Name"] = userInfoModel.fullname as AnyObject
                    createEventInfoParams["DateOfBirth"] = userInfoModel.dob as AnyObject
                    createEventInfoParams["userImage"] = userInfoModel.image as AnyObject
                    
                    if let email = userInfoModel.email {
                        createEventInfoParams["Email"] = email as AnyObject
                    } else {
                        createEventInfoParams["Email"] = "Facebook User" as AnyObject
                    }
                    
                    self.title = "My Profile"
                    
                } else {
                
                    // Show Another User Data.
                    self.title = selectedUserProfile?.fullname ?? ""
                    
                    if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
                        editButton.isHidden =  userInfoModel.id ?? 0 == selectedUserProfile?.id ?? 0 ? true : false
                    }
                    
                    editButton.tag = 2
                    editButton.setTitle("More", for: .normal)
                    self.someOtherUserServiceFunction()
                    
                }
                
            } else {
            
                print("Current Login User Data Not Found - My Profile View Controller")
                
            }
            
        } else {
        
            print("User Profile Not Found - My Profile View Controller")
            
        }
        
    }

    
    @IBAction func showEditProfile(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            sender.isSelected = !sender.isSelected
            
            if sender.isSelected {
                
                self.tableView_Main.reloadData()
                
            } else {
                
                self.saveUserInfoToServer()
            }
            
        } else {
            
            self.openActionSheet()
            
        }
    }
    
    
    internal func openActionSheet() {
        
            //1. Create the AlertController
            let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
            
            var friendStatus = String()
        
            print(selectedUserProfile.userFriendStatus ?? 0)
            
            switch selectedUserProfile.userFriendStatus ?? 0 {
            case 0:
                friendStatus = "Add as Friend"
            case 1:
                friendStatus = "Unfriend this user"
            case 2:
                friendStatus = "Accept Request"
            case 3:
                friendStatus = "Already sent friend request"
            default:
                friendStatus = "Add as Friend"
            }
            
            //2. add as friend Action button
            let addfriendActionButton = UIAlertAction(title: friendStatus, style: .default) { action -> Void in
                print("Create Single Event")
                
                if self.selectedUserProfile.userFriendStatus ?? 0 == 0 {
                    if Reachability.isConnectedToNetwork() == true {
                        
                        self.sendFriendRequestAPI(friendId: "\(self.selectedUserProfile?.id ?? 0)")
                        
                    } else {
                        
                        self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    }
                } else if self.selectedUserProfile.userFriendStatus ?? 0 == 1 {
                    
                    if Reachability.isConnectedToNetwork() == true {
                        
                        self.unFriendUserRequestAPI(friendId: self.selectedUserProfile.id ?? 0)
                        
                    } else {
                        
                        self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    }
                    
                }
                
            }
            actionSheetController.addAction(addfriendActionButton)
            
            
            //3. Block User Action Button
            let blockUserActionButton = UIAlertAction(title: "Block User", style: .default) { action -> Void in
                print("Create Group Event")
                
                self.alertFunctionsWithCallBack(title: "Are you sure you want to block \(self.createEventInfoParams["Name"] ?? "" as AnyObject)?", completionHandler: { (isTrue) in
                    
                    if isTrue.boolValue {
                        
                        if Reachability.isConnectedToNetwork() == true {
                            
                            self.blockUserRequestApi(friendId: "\(self.selectedUserProfile?.id ?? 0)")
                            
                        } else {
                            
                            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                            
                        }
                    }
                    
                })
                
            }
            actionSheetController.addAction(blockUserActionButton)
            
            
            //4. report User Action Button
            let reportActionButton = UIAlertAction(title: "Report User", style: .default) { action -> Void in
                print("Create Group Event")
                
                self.alertFunctionsWithCallBack(title: "Are you sure you want to report \(self.createEventInfoParams["Name"] ?? "" as AnyObject)?", completionHandler: { (isTrue) in
                    
                    if isTrue.boolValue {
                        
                        if Reachability.isConnectedToNetwork() == true {
                            
                            self.reportSpamUserRequestApi(friendId: "\(self.selectedUserProfile.id ?? 0)")
                            
                        } else {
                            
                            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                            
                        }
                    }
                    
                })
                
            }
            
            actionSheetController.addAction(reportActionButton)
            
            
            // 5. cancel Action Sheet button
            let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                print("Cancel")
            }
            actionSheetController.addAction(cancelActionButton)
            
            // 6. Present Action Sheet
            self.present(actionSheetController, animated: true, completion: nil)
            

    }
    
    fileprivate func saveUserInfoToServer() {
        
        let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
        let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
        
        if isUserChangeAnything {
            
            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
            
                if Reachability.isConnectedToNetwork() == true {
                
                    let profileName: String = "profile_user_id_" + String(userInfoObj.id!)
                    self.uploadProfilePicName(imageName: profileName)
                
                } else {
                
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
                }
            }
            
        } else {
            
            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                
                if Reachability.isConnectedToNetwork() == true {
                    
                    self.sendProfileDetailsOnServer(authToken: userInfoObj.authentication_token!, imageName: "", imageURL: userInfoObj.image ?? "", description: self.createEventInfoParams["AboutMe"] as? String ?? "", dob:self.createEventInfoParams["DateOfBirth"] as? String ?? "",full_name:self.createEventInfoParams["Name"] as? String ?? "")
                    
                } else {
                    
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    
                }
                
            }
            
        }
        
    }
    
    //MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension MyProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        createEventInfoParams["AboutMe"] = textView.text as AnyObject
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
        
        if textField.tag == 103 {
            
            createEventInfoParams["Name"] = textField.text as AnyObject
            
        }
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
        } // end else
        
        return true
        
    }
    
}

extension MyProfileViewController: UITableViewDelegate, UITableViewDataSource, TableViewUpdateProfilePicDelegate, TableViewCellDatePickerDelegate {
    
    internal func getTableViewCellDatePicker(tableView: UITableView, indexPath: IndexPath) -> TableViewCellDatePicker {
        
        let cell:TableViewCellDatePicker = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDatePicker") as! TableViewCellDatePicker
        
        cell.delegate = self
        
        cell.selectionStyle = .none
        
        cell.datePicker_Outlet.datePickerMode = .date
        
        cell.datePicker_Outlet.tag = 100+indexPath.row
        
        return cell
        
    }
    
    internal func getTableViewCellCreateEventTextField(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        cell.textField_EnterText.delegate = self
        cell.textField_EnterText.isUserInteractionEnabled = true
        cell.textField_EnterText.text = ""
        
        // description Date block
        if startEventBool == false {
            cell.textField_EnterText.text = createEventInfoParams["DateOfBirth"] as? String ?? ""
            cell.textField_EnterText.isUserInteractionEnabled = false
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:TableViewProfileCell = tableView.dequeueReusableCell(withIdentifier: "TableViewProfileCell") as! TableViewProfileCell
            
            if !isImagePick {
                //userImage
                  cell.imageView_Image.sd_setImage(with: URL(string: createEventInfoParams["userImage"] as? String ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
                //imageThumbnailSize = cell.imageView_Image.image!
            }
            
            if editButton.isSelected {
                cell.delegate = self
            }
            
            cell.selectionStyle = .none
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell:TableViewProfileAboutMe = tableView.dequeueReusableCell(withIdentifier: "TableViewProfileAboutMe") as! TableViewProfileAboutMe
            
            self.addToolBar(textView: cell.aboutMeTextView)
            
            cell.aboutMeTextView.delegate = self
            
            cell.aboutMeTextView.text = createEventInfoParams["AboutMe"] as? String ?? ""
            
            cell.aboutMeTextView.isUserInteractionEnabled = editButton.isSelected
            
            cell.selectionStyle = .none
            
            return cell
            
        } else if indexPath.section == 2 || indexPath.section == 3 {
            
            let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
            
            
            switch indexPath.section {
                
                case 2:
                    cell.textField_EnterText.placeholder = "Email"
                    
                    var email: String = String()
                    if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
                        email =  userInfoModel.id ?? 0 == selectedUserProfile?.id ?? 0 ? createEventInfoParams["Email"] as? String ?? "" : "Facebook User"
                    }
                    
                    cell.textField_EnterText.text = email
                    
                case 3:
                    cell.textField_EnterText.placeholder = "Name"
                    cell.textField_EnterText.text = createEventInfoParams["Name"] as? String ?? ""
                    
                default: break
                
            }
            
            cell.textField_EnterText.tag = 100 + indexPath.section
            
            cell.textField_EnterText.delegate = self
            
            cell.selectionStyle = .none
            
            //If edit Button is selected then only textfield will be enable
            if editButton.isSelected {
                cell.textField_EnterText.isUserInteractionEnabled = indexPath.section == 2 ? false: true
            } else {
                cell.textField_EnterText.isUserInteractionEnabled = false
            }
            
            return cell
            
        } else {
            
            if startEventBool == true {
                
                return self.getTableViewCellDatePicker(tableView: tableView, indexPath: indexPath)
                
            } else {
                
                return self.getTableViewCellCreateEventTextField(tableView:tableView, indexPath:indexPath)
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if editButton.isSelected {
            
            if indexPath.section == 4 {
                
                startEventBool = !startEventBool
                
                tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
                
            } else if indexPath.section == 3 {
                
                tableView.setContentOffset(CGPoint(x: 0,y :100), animated: false)
                
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 160
            
        } else if indexPath.section == 1 {
            
            return 160
            
        } else if indexPath.section == 2 || indexPath.section == 3{
            
            return 50
            
        } else {
            
            if startEventBool == true  {
                
                return 250
                
            } else {
                
                return 50
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.1 : 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        } else if section == 1 {
            
            return self.setHeaderView(title: "About Me")
            
        } else if section == 2 {
            
            return self.setHeaderView(title: "Email")
            
        } else if section == 3 {
            
            return self.setHeaderView(title: "Name")
            
        } else {
            
            return self.setHeaderView(title: "Date Of Birth")
            
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    // MARK: - Cell Delegates
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
            self.openImagePickerViewController(sourceType: .camera, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Choose Photo", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        isUserChangeAnything = true
        
        imageFullSize = image as! UIImage
        
        let imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
        imageThumbnailSize = imageThumbnail
        
        let cell: TableViewProfileCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewProfileCell
        isImagePick = true
        cell.imageView_Image.image = imageThumbnail
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func selectedDateAndTime(datePicker: UIDatePicker) {
        
        let dateFormatterGet = DateFormatter()
        
        dateFormatterGet.dateFormat = "MMM d, yyyy"
        
        let dateInString: String = dateFormatterGet.string(from: datePicker.date)
        
        
        startEventBool = false
        
        createEventInfoParams["DateOfBirth"] = dateInString as AnyObject
        
        tableView_Main.reloadSections(IndexSet(integer: 4), with: .automatic)
        
    }
    
}
