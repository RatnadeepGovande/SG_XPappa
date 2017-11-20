//
//  ChannelDetailsViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage
import MobileCoreServices
import MBProgressHUD

class ChannelDetailsViewController: UIViewController, ShowAlert {

    // Variables.
    @IBOutlet var tableView_Main: UITableView!
    
    
    var channelDetail : MyChannelDetailInfoModel!
    var flagValue: Int8 = 1
    
    var channelDetailDict: [String: AnyObject] = ["channelCoverImage" : "" as AnyObject, "channelBackgroundImage" : "" as AnyObject, "channelName" : "" as AnyObject, "channelDescription" : "" as AnyObject, "channelPrivacy" : "" as AnyObject]

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.registerTableViewNibs()
        self.setViewBackground()
        
        self.channelDetailDict["channelName"] = self.channelDetail.channelName as AnyObject
        self.channelDetailDict["channelDescription"] = self.channelDetail.channelDescription as AnyObject

        // Notification.
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelDetailsViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelDetailsViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Keyboard Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.tableView_Main.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
                
                // Get indexpath
                let indexpath = IndexPath(row: 2, section: 0)
                self.tableView_Main.scrollToRow(at: indexpath, at: UITableViewScrollPosition.top, animated: true)
                
            })
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.tableView_Main.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            
        })
        
    }
    
    
    // MARK: - Register Table View Cell.
    
    internal func registerTableViewNibs() {
        
        tableView_Main.register(UINib(nibName: "TableViewChannelDetailCoverCell", bundle: nil), forCellReuseIdentifier: "TableViewChannelDetailCoverCell")
        
        tableView_Main.register(UINib(nibName: "TableViewTextFieldWithEditButton", bundle: nil), forCellReuseIdentifier: "TableViewTextFieldWithEditButton")
        
       // tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextView", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextView")
        
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")

    }

    
    // MARK: - Did Receive Memory warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "imageCropped" {
            
            let destinationView: ImageCropperViewController = segue.destination as! ImageCropperViewController
            destinationView.delegate = self
            destinationView.selectedImage = sender as? UIImage
            
        }
        
    }

}

extension ChannelDetailsViewController : TableViewChannelDetailCoverCellDelegate, ImageCropperViewControllerDelegate {
    
    func imageCroppedDelegateMethod(cropImage: UIImage) {
        
        let cell: TableViewChannelDetailCoverCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewChannelDetailCoverCell
        
        cell.coverImage.image = cropImage
        self.channelDetailDict["channelBackgroundImage"] = cropImage as AnyObject
        
        //check net connection
        if Reachability.isConnectedToNetwork() == true {
            
            self.uploadAvatarImageToCloudinary(flagValue: self.flagValue, avatarImage: cropImage)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }

    }
    
    func imageButtonMethod(_ sender: UIButton) {
        
        self.flagValue = Int8(sender.tag)
        self.showActionSheetForImage()
    }
    
    //MARK:- Call ActionSheet For image
    func showActionSheetForImage() {
        
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Choose Photo", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        if self.flagValue == 1 {
            
            let cell: TableViewChannelDetailCoverCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewChannelDetailCoverCell
            
            cell.avatarImage.image = image
            self.channelDetailDict["channelProfileImage"] = image as AnyObject
            
            picker.dismiss(animated: true) {}

            //check net connection
            if Reachability.isConnectedToNetwork() == true {
                
                self.uploadAvatarImageToCloudinary(flagValue: self.flagValue, avatarImage: image)
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            

        } else {
            
            picker.dismiss(animated: true) {
                
                self.performSegue(withIdentifier: "imageCropped", sender: image)
            }
            
            //self.channelDetailDict["channelBackgroundImage"] = image as AnyObject

        }
    }
    
    
}

extension ChannelDetailsViewController : TableViewTextFieldWithEditButtonDelegate, TableViewCellSwitchDelegates, UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        channelDetailDict["channelDescription"] = textView.text as AnyObject
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        channelDetailDict["channelName"] = textField.text as AnyObject
        
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func changeSwitchButtonStatus(sender: UISwitch) {
        
        channelDetailDict["channelPrivacy"] = (sender.isOn ? false : true) as AnyObject
        
        //check net connection
        if Reachability.isConnectedToNetwork() == true {
            
            self.updateContentOfChannelServiceFunction()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
    }
    
    
    func saveDelegateMethod() {
        
        self.view.endEditing(true)
        let cell: TableViewTextFieldWithEditButton = tableView_Main.cellForRow(at: IndexPath(row: 1, section: 0)) as! TableViewTextFieldWithEditButton
        
        print(cell.textFieldEnterText.text as AnyObject)
        
        self.channelDetailDict["channelName"] = cell.textFieldEnterText.text as AnyObject
        
        //check net connection
        if Reachability.isConnectedToNetwork() == true {
            
            self.updateContentOfChannelServiceFunction()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
        self.view.endEditing(true)
        
    }
    
    func editDelegateMethod(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        let cell: TableViewTextFieldWithEditButton = tableView_Main.cellForRow(at: IndexPath(row: 1, section: 0)) as! TableViewTextFieldWithEditButton
        
        
       if sender.isSelected {
           
            cell.textFieldEnterText.isUserInteractionEnabled = true

            cell.allocSaveButton()
            
        } else {
            
            cell.textFieldEnterText.isUserInteractionEnabled = false

            cell.saveButton.removeFromSuperview()
            
        }
        
    }
    
    func addToolBarTo(textView: UITextView) {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = appColor.appTabbarSelectedColor
        
        let doneButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.donePressed))
        doneButton.tintColor = UIColor.darkGray
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChannelDetailsViewController.saveDescriptionTextForChannel))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([saveButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.inputAccessoryView = toolBar
        
    }
    
    func saveDescriptionTextForChannel() {
        
        //check net connection
        self.view.endEditing(true)
        let cell: TableViewTextFieldWithEditButton = tableView_Main.cellForRow(at: IndexPath(row: 1, section: 0)) as! TableViewTextFieldWithEditButton
        
        print(cell.textFieldEnterText.text as AnyObject)

        self.channelDetailDict["channelName"] = cell.textFieldEnterText.text as AnyObject

        if Reachability.isConnectedToNetwork() == true {
            
            self.updateContentOfChannelServiceFunction()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
}


//

extension ChannelDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
        
            let cell: TableViewChannelDetailCoverCell = tableView.dequeueReusableCell(withIdentifier: "TableViewChannelDetailCoverCell") as! TableViewChannelDetailCoverCell
            
            cell.avatarImage.sd_setImage(with: URL(string: self.channelDetail.profileImageUrl ?? ""), placeholderImage: UIImage(named: "avatarSingleIcon"))
            
            cell.coverImage.sd_setImage(with: URL(string: self.channelDetail.channelBackgroundImageUrl ?? ""), placeholderImage: nil)
            
            cell.delegate = self
            
           
            
            cell.selectionStyle = .none
            
            return cell
            
        } else if indexPath.row == 1 {
        
            let cell:TableViewTextFieldWithEditButton = tableView.dequeueReusableCell(withIdentifier: "TableViewTextFieldWithEditButton") as! TableViewTextFieldWithEditButton
            
            cell.textFieldEnterText.placeholder = "Please enter Name"
            
            cell.textFieldEnterText.text = ""
            
            cell.delegate = self
            
            cell.textFieldEnterText.delegate = self

            cell.textFieldEnterText.isUserInteractionEnabled = false

            cell.textFieldEnterText.text = channelDetailDict["channelName"] as? String ?? ""
            
            cell.selectionStyle = .none

            return cell
            
        } /*else if indexPath.row == 2 {
            
            let cell:TableViewCellCreateEventTextView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextView") as! TableViewCellCreateEventTextView
            
            self.addToolBarTo(textView: cell.textView_EnterText)

            cell.textView_EnterText.text = channelDetailDict["channelDescription"] as? String ?? ""
            cell.selectionStyle = .none

            return cell
            
        } */ else {
            
            let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
            
            cell.delegate = self
            
            cell.label_Text.text = "Make the channel public"
            
            cell.switch_ButtonOutlet.setOn(channelDetailDict["channelPrivacy"] as? Bool ?? true, animated:true)
            
            cell.selectionStyle = .none

            return cell
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
           return 180
            
        }/* else if indexPath.row == 2 {
            
             return 100
            
        } */else {
            
            return 60
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 40.0 : 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
}
