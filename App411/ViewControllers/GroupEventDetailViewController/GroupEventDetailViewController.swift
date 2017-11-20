//
//  GroupEventDetailViewController.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import AVKit
import ObjectMapper
import SDWebImage

class GroupEventDetailViewController: UIViewController, ShowAlert {
    
    @IBOutlet var tableView_Main: UITableView!
    @IBOutlet var playVideoButton: UIButton!
    var refreshControl: UIRefreshControl!
    
    
    @IBOutlet var createEvent: UIBarButtonItem!
    var createEventInfoParams: [String: AnyObject] = ["groupTitle" : "" as AnyObject, "groupDescription": "" as AnyObject, "groupMembers": "" as AnyObject]
    var groupEventData : AGroupEventInfoModel!
    var groupId : Int?
    
    var isaddMember : Bool = false
    var isUserAdmin : Bool = false
    var groupMembers : Int = 0
    var isGroupHost : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Group Detail"
        
        self.setViewBackground()
        
        self.registerTableViewNibs()
        
        groupId = groupEventData.id
        isGroupHost = groupEventData.isGroupHost ?? false
        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            isUserAdmin = userInfoModel.id ?? 0 == groupEventData.userId ?? 0 ? true : false
            
            createEvent.isEnabled = true
            
        }
        
        self.refreshControlAPI()
    }
    
    
    // MARK: - refresh control For API
    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        tableView_Main.addSubview(refreshControl) // not required when using UITableViewController
        
        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    

    // MARK: - Reload API
    func reloadAPI() {
        
        // Check network connection.
        if Reachability.isConnectedToNetwork() == true {
            
            self.showGroupEventDetailServiceFunction()
            
        } else {
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    internal func registerTableViewNibs() {
        
        tableView_Main.estimatedRowHeight = 50
        
        tableView_Main.register(UINib(nibName: "TableViewCellSignUpProfilePic", bundle: nil), forCellReuseIdentifier: "TableViewCellSignUpProfilePic")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextField", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextField")
        tableView_Main.register(UINib(nibName: "TableViewCellCreateEventTextView", bundle: nil), forCellReuseIdentifier: "TableViewCellCreateEventTextView")
        tableView_Main.register(UINib(nibName: "TableViewCellJoinCollection", bundle: nil), forCellReuseIdentifier: "TableViewCellJoinCollection")
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")
        tableView_Main.register(UINib(nibName: "TableViewCellSaveEvents", bundle: nil), forCellReuseIdentifier: "TableViewCellSaveEvents")
        tableView_Main.register(UINib(nibName: "TableViewButtonCell", bundle: nil), forCellReuseIdentifier: "TableViewButtonCell")
        
    }
    
    //MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBActions
    
    @IBAction func createEvent(_ sender: Any) {
        
        self.openActionSheet()
    }
    
    internal func openActionSheet() {
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
        if isUserAdmin {
            
            //Create Event Group
            let singleActionButton = UIAlertAction(title: "Create Event", style: .default) { action -> Void in
                print("Create Single Event")
                
//                let instanceObject = self.storyboard?.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
//
//                instanceObject.groupID = self.groupId ?? 0
//                self.navigationController?.pushViewController(instanceObject, animated: true)
                
                self.performSegue(withIdentifier: "chooseCategoryType", sender: self)

            }
            actionSheetController.addAction(singleActionButton)
            
            // Edit Group Action
            let editActionButton = UIAlertAction(title: "Edit Group", style: .default) { action -> Void in
                print("Create Group Event")
                self.performSegue(withIdentifier: "GroupEditSegue", sender: self)
            }
            actionSheetController.addAction(editActionButton)
            
            //Group Delete Action
            let exitActionButton = UIAlertAction(title: "Delete Group", style: .default) { action -> Void in
                print("Create Group Event")
                
                if Reachability.isConnectedToNetwork() == true {
                    //self.createEventAPI()
                    self.deleteGroupServiceFunction()
                } else {
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                }
                
            }
            actionSheetController.addAction(exitActionButton)
            
        } else {
            
            // If user is host of the Group only in that case user can create the event
            if isGroupHost {
                
                let singleActionButton = UIAlertAction(title: "Create Event", style: .default) { action -> Void in
                    print("Create Single Event")
                    
                    self.performSegue(withIdentifier: "chooseCategoryType", sender: self)

                }
                actionSheetController.addAction(singleActionButton)
                
            }
            
            //If group is private then only user can be able to exit this group
            /* self.groupEventData.publicFlag == true, this means group is private or vice - versa */
            if self.groupEventData.publicFlag == true && self.groupEventData.isGroupJoin == true {
                
                let exitActionButton = UIAlertAction(title: "Exit Group", style: .default) { action -> Void in
                    print("Create Group Event")
                    
                    if Reachability.isConnectedToNetwork() == true {
                        //self.createEventAPI()
                        self.joinOrUnjoinGroupServiceFunction()
                    } else {
                        self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    }
                    
                }
                actionSheetController.addAction(exitActionButton)
            }
            
            let groupSpamButton = UIAlertAction(title: "Report/Spam this group", style: .default) { action -> Void in
                print("Create Group Event")
                
                if Reachability.isConnectedToNetwork() == true {
                    //self.createEventAPI()
                    self.reportOrSpamGroupServiceFunction()
                } else {
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                }
                
            }
            actionSheetController.addAction(groupSpamButton)
            
        }
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addgroupMember" {
            
            let destinationView: AddGroupMemberViewController = segue.destination as! AddGroupMemberViewController
            destinationView.groupID = groupId
            destinationView.addMembers = groupMembers
            
        } else if segue.identifier == "GroupEditSegue" {
            //GroupEditSegue
            
            let destinationView: GroupEventEditViewController = segue.destination as! GroupEventEditViewController
            destinationView.groupEventData = self.groupEventData
            
        } else if segue.identifier == "chooseCategoryType" {
            
            let destination = segue.destination as! FilterViewController
            destination.filterType = false
            destination.groupEventID = self.groupId ?? 0
        }
    }
    
}

extension GroupEventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isGroupHost || isUserAdmin {
            
            // if user is owner of group or user is host of group
            return self.groupEventData.eventArray.count > 0 ? 7 : 6
            
        } else {
            
            // if user is only member of group
            
            if self.groupEventData.event_HostsArray.count > 0 {
                
                return self.groupEventData.eventArray.count > 0 ? 7 : 6
                
            } else {
                
                return self.groupEventData.eventArray.count > 0 ? 6 : 5
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isGroupHost || isUserAdmin {
            
            return section == 6 ? self.groupEventData.eventArray.count : 1
            
        } else {
            
            // if user is member of group
            if section == 5 {
                
                return self.groupEventData.event_HostsArray.count == 0 ? 1 : self.groupEventData.eventArray.count
                
            } else if section == 6 {
                
                return self.groupEventData.eventArray.count
                
            } else {
                
                return 1
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:TableViewCellSignUpProfilePic = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSignUpProfilePic") as! TableViewCellSignUpProfilePic
            
            cell.selectionStyle = .none
            
            cell.imageView_Images.layer.cornerRadius = (cell.imageView_Images.frame.size.width)/2
            
            cell.imageView_Images.clipsToBounds = true
            
            //If event_image contains video then below condition will execute or vice - versa.
            if self.groupEventData.videoFlag == 1 {

                var videoImage: UIImage = UIImage(named: "ic_no_image")!
                
                if let videoString = self.groupEventData.groupImageUrl {
                    
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
            
            return cell
            
        } else if indexPath.section == 1 {
            
            return self.getTableViewCellCreateEventTextField(tableView: tableView, indexPath: indexPath)
            
        } else if indexPath.section == 2 {
            
            let cell:TableViewCellCreateEventTextView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextView") as! TableViewCellCreateEventTextView
            
            self.addToolBar(textView: cell.textView_EnterText)
            cell.textView_EnterText.isUserInteractionEnabled = false
            
            cell.textView_EnterText.text = self.groupEventData.groupDescription
            
            cell.selectionStyle = .none
            
            return cell
            
        } else if indexPath.section == 3 || indexPath.section == 4 {
            
            if isGroupHost || isUserAdmin {
                
                let cell:TableViewCellJoinCollection = tableView.dequeueReusableCell(withIdentifier: "TableViewCellJoinCollection") as! TableViewCellJoinCollection
                
                cell.delegate = self
                
                cell.goingButton.setTitle("View All", for: .normal)
                
                cell.eventUserJoinArray = indexPath.section == 3 ? self.groupEventData.event_JoinArray : self.groupEventData.event_HostsArray
                
                if indexPath.section == 3 {
                    
                    cell.updateJoinCollection(istrue:true)
                    cell.goingButton.isHidden = self.groupEventData.event_JoinArray.count > 4 ? false : true
                    
                } else {
                    
                    cell.updateJoinCollection(istrue: true)
                    cell.goingButton.isHidden = self.groupEventData.event_HostsArray.count > 4 ? false : true
                    
                }
                
                cell.selectionStyle = .none
                
                tableView.separatorStyle = .none
                
                return cell
                
            } else {
                
                if indexPath.section == 3 || (indexPath.section == 4 && self.groupEventData.event_HostsArray.count > 0) {
                    
                    let cell:TableViewCellJoinCollection = tableView.dequeueReusableCell(withIdentifier: "TableViewCellJoinCollection") as! TableViewCellJoinCollection
                    
                    cell.delegate = self
                    
                    cell.goingButton.setTitle("View All", for: .normal)
                    
                    cell.eventUserJoinArray = indexPath.section == 3 ? self.groupEventData.event_JoinArray : self.groupEventData.event_HostsArray
                    
                    if indexPath.section == 3 {
                        
                        cell.updateJoinCollection(istrue: true)
                        cell.goingButton.isHidden = self.groupEventData.event_JoinArray.count > 4 ? false : true
                        
                    } else {
                        
                        cell.updateJoinCollection(istrue: true)
                        cell.goingButton.isHidden = self.groupEventData.event_HostsArray.count > 4 ? false : true
                        
                    }
                    
                    cell.selectionStyle = .none
                    
                    tableView.separatorStyle = .none
                    
                    return cell
                    
                } else {
                    
                    return self.availabilitySwitchCell(tableView:tableView, indexPath:indexPath)
                    
                }
            }
            
        } else {
            
            if isGroupHost || isUserAdmin {
                
                return indexPath.section == 5 ? self.availabilitySwitchCell(tableView:tableView, indexPath:indexPath) : self.savedEventCell(tableView: tableView, indexPath: indexPath)
                
            } else {
                
                if (indexPath.section == 5 && self.groupEventData.event_HostsArray.count > 0) {
                    
                    return self.availabilitySwitchCell(tableView:tableView, indexPath:indexPath)
                    
                } else {
                    
                    return self.savedEventCell(tableView: tableView, indexPath: indexPath)
                    
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 10.0
            
        } else {
            
            return 40.0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if isGroupHost || isUserAdmin {
            
            if section == 3 || section == 4 {
                return 35.0
            } else {
                return  0.1
            }
            
        } else {
            
            return  0.1
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return self.createHeaderView()
            
        } else if section == 1 {
            
            return self.setHeaderView(title: "Group Name")
            
        }else if section == 2 {
            
            return self.setHeaderView(title: "Group Description")
            
        } else if section == 3 {
            
            return self.setHeaderView(title: "Members of Group")
            
        } else if section == 4 {
            
            if isGroupHost || isUserAdmin {
                
                return self.setHeaderView(title: "Hosts of Group")
                
            } else {
                
                return (section == 4 && self.groupEventData.event_HostsArray.count > 0) ? self.setHeaderView(title: "Hosts of Group") : self.setHeaderView(title: "Availability")
            }
            
        } else if section == 5 {
            
            if isGroupHost || isUserAdmin {
                
                return self.setHeaderView(title: "Availability")
                
            } else {
                
                return (section == 5 && (self.groupEventData.eventArray.count > 0 && self.groupEventData.event_HostsArray.count == 0)) ? self.setHeaderView(title: "Event List") : self.setHeaderView(title: "Availability")
            }
            
        } else {
            
            return self.setHeaderView(title: "Event List")
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 3 {
            
            if isGroupHost || isUserAdmin {
                
                return self.createHeaderViewWithTitle(titleStr: "+ Add Members", indexpath: section)
            } else {
                
                return self.createHeaderView()
            }
        } else if section == 4 {
            
            if isGroupHost || isUserAdmin {
                
                return self.createHeaderViewWithTitle(titleStr: "Create Hosts", indexpath: section)
                
            } else {
                
                return self.createHeaderView()
            }
            
        } else {
            
            return self.createHeaderView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isGroupHost || isUserAdmin {
            
            if indexPath.section == 6 {
                
                self.moveToDetailEvent(row: indexPath.row, arrayObject: self.groupEventData.eventArray)
            }
            
        } else {
            
            if indexPath.section == 5 && (self.groupEventData.eventArray.count > 0 && self.groupEventData.event_HostsArray.count == 0) {
                
                self.moveToDetailEvent(row: indexPath.row, arrayObject: self.groupEventData.eventArray)
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 180.0
            
        } else if indexPath.section == 1 {
            
            return 50
            
        } else if indexPath.section == 2 {
            
            return 150
        } else if indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 {
            
            if isGroupHost || isUserAdmin {
                
                return (indexPath.section == 4 || indexPath.section == 5) ? 50 : 100
                
            } else {
                
                if indexPath.section == 4 || indexPath.section == 6 {
                    
                    return indexPath.section == 4 ? 50 : 100
                } else {
                    
                    return self.groupEventData.event_HostsArray.count > 0 ? 50 : 100
                }
            }
            
        } else {
            
            return 50
        }
    }
    
    
    internal func availabilitySwitchCell(tableView: UITableView, indexPath: IndexPath) -> TableViewCellSwitch {
        
        let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
        
        cell.label_Text.text = "Make the group public"
        cell.switch_ButtonOutlet.isUserInteractionEnabled = false
        
        cell.switch_ButtonOutlet.setOn(true, animated:true)
        //cell.switch_ButtonOutlet.setOn(createEventInfoParams["EventAvailability"] as? Bool ?? true, animated:true)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    internal func savedEventCell(tableView: UITableView, indexPath: IndexPath) -> TableViewCellSaveEvents {
        
        let cell:TableViewCellSaveEvents = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSaveEvents") as! TableViewCellSaveEvents
        
        cell.avatarImage.layer.cornerRadius = (cell.avatarImage.frame.size.width)/2
        cell.avatarImage.clipsToBounds = true
        
        let aEventInfoModel: ACreateEventInfoModel = self.groupEventData.eventArray[indexPath.row]
        
        //If event_image contains video then below condition will execute or vice - versa.
        if aEventInfoModel.event_video_flag == "1" {
            
            var videoImage: UIImage = UIImage(named: "ic_no_image")!
            
            if let videoString = aEventInfoModel.event_image {
                
                URL(fileURLWithPath: videoString).createImageThumbnailFrom(returnCompletion: { (imageFromVideo) in
                    
                    DispatchQueue.main.async {
                        
                        if let imageThum =  imageFromVideo {
                            videoImage = imageThum
                        }
                    }
                    
                })
            }
            
            cell.avatarImage.image = videoImage
            
        } else {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
        }
        
        cell.eventTitleLabel.text = aEventInfoModel.title
        
        cell.descriptionLabel.text = aEventInfoModel.start_event_date! + "\n" + aEventInfoModel.event_place_name!
        
        return cell
        
    }
    
    internal func getTableViewCellCreateEventTextField(tableView: UITableView, indexPath: IndexPath) -> TableViewCellCreateEventTextField {
        
        let cell:TableViewCellCreateEventTextField = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCreateEventTextField") as! TableViewCellCreateEventTextField
        
        //cell.textField_EnterText.delegate = self
        cell.textField_EnterText.isUserInteractionEnabled = false
        
        cell.textField_EnterText.placeholder = "Group Name"
        
        cell.textField_EnterText.text = self.groupEventData.groupName
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func createHeaderView() -> UIView {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
    }
    
    func createHeaderViewWithTitle(titleStr: String, indexpath: Int) -> UIView {
        
        let hearderView: UIView = UIView()
        hearderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40)
        hearderView.backgroundColor = UIColor.clear
        
        let btn = UIButton(type: .custom) as UIButton
        btn.setTitle(titleStr, for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: hearderView.frame.size.width/1.2, height: 35)
        btn.center = hearderView.center
        btn.tag = indexpath
        btn.addTarget(self, action: #selector(addMemberAction), for: .touchUpInside)
        hearderView.addSubview(btn)
        
        return hearderView
    }
    
    func addMemberAction(sender:UIButton!) {
        print("Button Clicked")
        
        if sender.tag == 3 {
            groupMembers = 0
            self.performSegue(withIdentifier: "addgroupMember", sender: self)
        } else {
            groupMembers = 2
            self.performSegue(withIdentifier: "addgroupMember", sender: self)
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
    
    
}

extension GroupEventDetailViewController : TableViewCellJoinCollectionDelegate, TableViewButtonCellDelegate {
    
    //MARK: - TableViewButtonCellDelegate Method
    func clickOnAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            groupMembers = 0
            self.performSegue(withIdentifier: "addgroupMember", sender: self)
        default:
            groupMembers = 2
            self.performSegue(withIdentifier: "addgroupMember", sender: self)
        }
        
    }
    
    func isClickOnUser(_ userData: AUserInfoModel) {
        
        let instanceObject = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
        instanceObject.selectedUserProfile = userData
        self.navigationController?.pushViewController(instanceObject, animated: true)
    }
    
    //MARK: TableViewCellJoinCollectionDelegate Method
    func isGoingAction(_ sender: UIButton) {
        
        groupMembers = 1
        
        self.performSegue(withIdentifier: "addgroupMember", sender: self)
        
    }
}
