//
//  GroupDetailsViewController.swift
//  App411
//
//  Created by osvinuser on 7/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import LayerKit
import Atlas
import ObjectMapper
import MobileCoreServices


protocol GroupDetailsViewControllerDelegate {
    func createGroupWithSelectedParticipants(participants: [AnyHashable], groupTitle: String, groupImage: UIImage)
}


class GroupDetailsViewController: UIViewController, ATLParticipantTableViewControllerDelegate, ShowAlert {

    @IBOutlet var tableView_Main: UITableView!
    
    @IBOutlet var createGroupButton: UIBarButtonItem!
    
    var imageFullSize = UIImage()
    var imageThumbnailSize = UIImage()

    var array_SelectedParticipants = Set<AnyHashable>()
    
    var delegate: GroupDetailsViewControllerDelegate?
    
    fileprivate var chatCount: Int = 25
    fileprivate var groupName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewGroupTitleCell", bundle: nil), forCellReuseIdentifier: "TableViewGroupTitleCell")
        tableView_Main.register(UINib(nibName: "TableViewCollectionCell", bundle: nil), forCellReuseIdentifier: "TableViewCollectionCell")
        
        createGroupButton.isEnabled = false
        
    }

    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - IBActions
    
    @IBAction func createGroupButtonAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: false)
        
        delegate?.createGroupWithSelectedParticipants(participants: Array(self.array_SelectedParticipants), groupTitle: groupName, groupImage: imageThumbnailSize)
        
    }

    
    // MARK: - Present Participant Table View Controller.
    func presentParticipantTableViewController(participants: Set<AnyHashable>) {
        
        self.array_SelectedParticipants.removeAll()
        
        let participantTableViewController: ATLParticipantTableViewController = ATLParticipantTableViewController(participants: participants, sortType: .firstName)
        participantTableViewController.delegate = self
        participantTableViewController.presenceStatusEnabled = false
        participantTableViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissparticipantTableViewControllerLocal))
        
        participantTableViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonViewController))

        
        let navigationLocal: UINavigationController = UINavigationController(rootViewController: participantTableViewController)
        
        self.navigationController?.present(navigationLocal, animated: true, completion: nil)
        
    }
    
    func dismissparticipantTableViewControllerLocal() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonViewController() {
        
        self.navigationController?.dismiss(animated: false, completion: {
            
            // User Click on done button of ATLParticipantTableViewController
            self.createGroupButton.isEnabled = self.array_SelectedParticipants.count > 0 && self.groupName.characters.count > 0 ? true : false
            self.tableView_Main.reloadSections(IndexSet(integer: 1), with: .automatic)
            
        })
        
    }
    
    
    // MARK: - Participant Delegate
    func participantTableViewController(_ participantTableViewController: ATLParticipantTableViewController, didSelect participant: ATLParticipant) {
        
        /*
        print(participant.userID)
        print(participant.displayName)
        print(participant.firstName)
        print(participant.lastName)
        print(participant.avatarImageURL ?? "")
        */
        
        self.array_SelectedParticipants.insert(participant as! AnyHashable)
        // print(self.array_SelectedParticipants)

    }
    
    
    func participantTableViewController(_ participantTableViewController: ATLParticipantTableViewController, didDeselect participant: ATLParticipant) {
        
        self.array_SelectedParticipants.remove(participant as! AnyHashable)
        // print(self.array_SelectedParticipants)

    }
    
    
    
    /**
     @abstract Informs the delegate that a search has been made with the following search string.
     @param participantTableViewController The participant table view controller in which the search was made.
     @param searchString The search string that was just used for search.
     @param completion The completion block that should be called when the results are fetched from the search.
     */
    func participantTableViewController(_ participantTableViewController: ATLParticipantTableViewController, didSearchWith searchText: String, completion: @escaping (Set<AnyHashable>) -> Void) {
        
    }
    
    
    // Get Friend Request List.
    func getFriendRequestList() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.friendList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            var participants = Set<AnyHashable>()
                            
                            if let friendList = jsonResult["user"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                        
                                        print(friendInfoMapperObj.fullname!)
                                        
                                        let user = ConversationParticipantProtocol(firstName: friendInfoMapperObj.fullname!, lastName: friendInfoMapperObj.fullname!, displayName: friendInfoMapperObj.fullname!, userID: String(friendInfoMapperObj.id ?? 0), avatarImageURL: URL(string: friendInfoMapperObj.image ?? "http://xyphr.herokuapp.com/chat.png")!, presenceStatus: .away, presenceStatusEnabled: true)
                                        
                                        // print(user.userID)
                                        // print(user.displayName)
                                        
                                        participants.insert(user)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            print(participants)
                            
                            self.presentParticipantTableViewController(participants: participants)
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        
    }
    */


}

extension GroupDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        
            let cell:TableViewGroupTitleCell = tableView.dequeueReusableCell(withIdentifier: "TableViewGroupTitleCell") as! TableViewGroupTitleCell
            
            cell.selectionStyle = .none
            
            cell.textField_GroupText.delegate = self
            
            cell.delegate = self
            
            cell.label_CharCount.text = String(chatCount)
            
            cell.textField_GroupText.text = groupName

            
            if cell.textField_GroupText.text?.isEmpty ?? true {
            
                cell.textField_GroupText.becomeFirstResponder()
                
            } else {
            
                cell.textField_GroupText.resignFirstResponder()
                
            }
            
            return cell
            
        } else {
            
            let cell:TableViewCollectionCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCollectionCell") as! TableViewCollectionCell
            
            cell.selectionStyle = .none
            
            cell.array_SelectedParticipants = Array(self.array_SelectedParticipants)
            
            cell.createGroupButton = createGroupButton
            
            cell.reloadCollectionView()
            
            return cell
        
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
        
            return 120
            
        } else {
        
            let width = Constants.ScreenSize.SCREEN_WIDTH / 4
            return ((width+(width*0.20))*(20/4))

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.1 : 30.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
        
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        } else {
        
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
            
            let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 30.0))
            
            label_Title.text = "PARTICIPANTS: "
            
            label_Title.textColor = UIColor.darkGray
            
            label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
            
            hearderView.addSubview(label_Title)

            
            let button_AddParticipants = UIButton(type: .custom)
            
            button_AddParticipants.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH - 35, y: 0, width: 30, height: 30)
            
            button_AddParticipants.setImage(#imageLiteral(resourceName: "addParticipant"), for: .normal)
            
            button_AddParticipants.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            
            button_AddParticipants.titleLabel?.textColor = UIColor.darkGray
            
            button_AddParticipants.addTarget(self, action:#selector(self.addParticipantsForGroupChat), for: .touchUpInside)
            
            hearderView.addSubview(button_AddParticipants)
            
            
            return hearderView
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    
    // MARK: - Add Participants For Group Chat.
    
    func addParticipantsForGroupChat() {
    
        if Reachability.isConnectedToNetwork() == true {
            
            self.getFriendRequestList()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
}

extension GroupDetailsViewController: TableViewGroupTitleCellDelegate {

    func clickGropImage() {
    
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            print("Take Photo")
            self.view.endEditing(true)
            self.openImagePickerViewController(sourceType: .camera, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Choose Photo", style: .default)
        { _ in
            print("Choose Photo")
            self.view.endEditing(true)
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        DispatchQueue.main.async {
            self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        imageFullSize = image as! UIImage
        
        let imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
        imageThumbnailSize = imageThumbnail
        
        let cell: TableViewGroupTitleCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewGroupTitleCell
        cell.imageView_GroupIcon.image = imageThumbnail
        
        picker.dismiss(animated: true) { 
            //self.tableView_Main.reloadData()
            if cell.textField_GroupText.text?.isEmpty ?? true {
                cell.textField_GroupText.becomeFirstResponder()
            } else {
                cell.textField_GroupText.resignFirstResponder()
            }
            
        }
        
    }
    
}


extension GroupDetailsViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        groupName = newString
        
        if newString.characters.count > 0 && newString.characters.count <= 25 {
        
            chatCount = 25
            chatCount -= newString.characters.count
            
            let cell:TableViewGroupTitleCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewGroupTitleCell
            cell.label_CharCount.text = String(chatCount)
            
            self.createGroupButton.isEnabled = self.array_SelectedParticipants.count > 0 && self.groupName.characters.count > 0 ? true : false

        } else {
            
            chatCount = 25
            
            let cell:TableViewGroupTitleCell = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewGroupTitleCell
            cell.label_CharCount.text = String(chatCount)
            
            self.createGroupButton.isEnabled = self.array_SelectedParticipants.count > 0 && self.groupName.characters.count > 0 ? true : false
            
            return string == "" ? true : false
            
        } // end else.
        
        return true
        
    }
    
}
