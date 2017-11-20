//
//  CauseDetailViewController.swift
//  App411
//
//  Created by osvinuser on 9/15/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import Branch

class CauseDetailViewController: UIViewController, ShowAlert {

    // Outlet
    @IBOutlet var tableView_Main: UITableView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var moreButton: UIButton!

    var refreshControl: UIRefreshControl!

    // variables
    var array_TableData = ["Location", "Start Date","End Date", "Description"]
    var categoryName : String?
    let donationArray = ["Money", "Food", "Clothes", "Others"]

    var eventData : ACreateEventInfoModel!
    var eventModelData : ACreateEventInfoModel!
    var userEventAdmin: Bool = false

    
    //MARK:- View Start
    override func viewDidLoad() {
        super.viewDidLoad()

        // registers nib files
        self.registerNibForTableViews()
        
        // set backgrounds
        self.setViewBackground()

        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            userEventAdmin = userInfoModel.id ?? 0 == eventModelData.user_id ?? 0 ? true : false
        }
    }
    
    internal func registerNibForTableViews() {
        
        // tablle view cells.
        tableView_Main.register(UINib(nibName: "EventDetailProfileCell", bundle: nil), forCellReuseIdentifier: "EventDetailProfileCell")
        
        tableView_Main.register(UINib(nibName: "TableViewEventDescriptionCell", bundle: nil), forCellReuseIdentifier: "TableViewEventDescriptionCell")
        
        // table view cell.
        tableView_Main.register(UINib(nibName: "TableViewCellJoinCollection", bundle: nil), forCellReuseIdentifier: "TableViewCellJoinCollection")
        
        tableView_Main.register(UINib(nibName: "TableViewCellDetailLabel", bundle: nil), forCellReuseIdentifier: "TableViewCellDetailLabel")
        
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")
        
        tableView_Main.register(UINib(nibName: "TableViewCellJoinCollection", bundle: nil), forCellReuseIdentifier: "TableViewCellJoinCollection")
        
        tableView_Main.register(UINib(nibName: "TabelViewCellNotifications", bundle: nil), forCellReuseIdentifier: "TabelViewCellNotifications")

        //TableViewCellJoinCollection
        
        // Set estimation height.
        tableView_Main.estimatedRowHeight = 70
        
        self.refreshControlAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.showCauseDetailFor(causeID: eventModelData.id ?? 0)
            
        } else {
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
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
    
    
    // MARK:- TableView Footer Actions
    func mobiliseButton(sender:UIButton!) {
        print("mobiliseButton Clicked")
        
    }
    
    func donateButton(sender:UIButton!) {
        print("donateButton Clicked")
        
        self.performSegue(withIdentifier: "causeDonate", sender: self.eventData)

    }
    
    
    // MARK:- More Actions

    @IBAction func moreAction(_ sender: Any) {
        
        self.openActionSheet()
    }
    
    internal func openActionSheet() {
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
        if userEventAdmin {
            
            let deleteActionButton = UIAlertAction(title: "Delete Cause", style: .default) { action -> Void in
                print("Delete Event")
                //Are you sure you want to delete this event?
                self.alertFunctionsWithCallBack(title: "Are you sure you want to delete this cause?") { (isSuccess) in
                    
                    if isSuccess.boolValue == true {
                        
                        if Reachability.isConnectedToNetwork() == true {
                            
                            self.deleteCauseByUser(eventId: self.eventData.id ?? 0)
                            
                        } else {
                            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                            
                        }
                    }
                }
            }
            
            actionSheetController.addAction(deleteActionButton)
            
        } else {
            
            let reportActionButton = UIAlertAction(title: "Report/Spam Cause", style: .default) { action -> Void in
                print("Report/Spam Event")
                
                if Reachability.isConnectedToNetwork() == true {
                    
                    self.spamOrReportEvent(eventId: self.eventData.id ?? 0)
                    
                } else {
                    
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    
                }
                
            }
            actionSheetController.addAction(reportActionButton)
            
        }
        
        let shareActionButton = UIAlertAction(title: "Share this Event", style: .default) { action -> Void in
            print("Report/Spam Event")
            self.generateDeepLickForSharing()
            //self.shareImageButton()
        }
        actionSheetController.addAction(shareActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // share image
     func shareImageButton() {
        
        // image to share
        let image = UIImage(named: "Image")
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func changeUIButtonValues(alphaValue: CGFloat, interactionOfButton : Bool) {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.backButton.alpha = alphaValue
            self.moreButton.alpha = alphaValue
            
        }, completion: { (finished) in
            
            self.moreButton.isUserInteractionEnabled = interactionOfButton
            self.backButton.isUserInteractionEnabled = interactionOfButton
        })
        
    }
    
    
    internal func generateDeepLickForSharing() {
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        linkProperties.channel = "facebook"
        linkProperties.addControlParam("$desktop_url", withValue: "custom/path")
        linkProperties.addControlParam("$ios_url", withValue: "http://www.google.com")
        
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "item/12345")
        branchUniversalObject.title = self.eventData.title ?? ""
        branchUniversalObject.contentDescription = self.eventData.description ?? ""
        branchUniversalObject.imageUrl = self.eventData.event_image ?? ""
        branchUniversalObject.addMetadataKey("Metadata_Key1", value: "\(self.eventData.event_category_id ?? 0)")
        branchUniversalObject.addMetadataKey("Metadata_Key2", value: "\(self.eventData.id ?? 0)")
        branchUniversalObject.addMetadataKey("Metadata_Key3", value: "\(self.eventData.user_id ?? 0)")
        
        branchUniversalObject.getShortUrl(with: linkProperties) { (url, error) in
            if error == nil {
                print("got my Branch link to share: %@", url ?? "not found")
                
                branchUniversalObject.showShareSheet(with: nil, andShareText: url, from: self, completion: { (textValue, isTrue) in
                    //https://app411.app.link/p2A4bZyRIG
                    print(textValue ?? "")
                    
                })
            }
        }
        
    }
   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "causeDonate" {
            let destinationVC = segue.destination as! DonateViewController
            destinationVC.eventModelData = sender as! ACreateEventInfoModel
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CauseDetailViewController : EventDetailProfileCellDelegate, TableViewCellJoinCollectionDelegate {
    
    func isGoingAction(_ sender: UIButton) {
        
        print("is going selected")
    }
    
    
    //MARK:- TableViewCellJoinCollectionDelegate Method
    func isClickOnUser(_ userData: AUserInfoModel) {
        
        let instanceObject = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
        instanceObject.selectedUserProfile = userData
        self.navigationController?.pushViewController(instanceObject, animated: true)
        
    }
    
    //MARK: EventDetailProfileCellDelegate Method
    func clickOnActions(buttonTag: Int) {
        
        switch buttonTag {
            
        case 1:
            //click on view events
            print("click on view events")
            
        case 2:
            //click on saved events
            print("click on saved events")
            self.saveEventForUser(eventId: self.eventData.id ?? 0, isSavedEvent: !self.eventData.event_favorite!)
            
        case 3:
            // click on event Image
            print("click on event Image")
            
        default:
            //back action
            print("click on default")

        }
        
    }
}

extension CauseDetailViewController : UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 0 {
            
            if scrollView.contentOffset.y > 100 {
                self.changeUIButtonValues(alphaValue: 0, interactionOfButton: false)
            } else {
                self.changeUIButtonValues(alphaValue: 1, interactionOfButton: true)
            }
        } else {
            self.changeUIButtonValues(alphaValue: 1, interactionOfButton: true)
        }
        
    }
    
    // Cell Functions
    // 1
    internal func cellJoinEventTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        let cell:TableViewCellJoinCollection = tableView.dequeueReusableCell(withIdentifier: "TableViewCellJoinCollection") as! TableViewCellJoinCollection
        
        cell.delegate = self
        
        if userEventAdmin {
            
            cell.goingButton.isHidden = true
            
        } else {
            
            cell.goingButton.isEnabled = true
            cell.goingButton.isHidden = false
            cell.goingButton.setTitle(self.eventData.event_join ?? false == true ? "Going" : "I'm Going", for: .normal)
            
            cell.goingButton.isSelected = self.eventData.event_join!
        }
        
        cell.goingButton.isHidden = true
        
        cell.eventUserJoinArray = indexPath.section == 4 ? self.eventData.event_JoinArray : self.eventData.event_HostArray
        
        cell.updateJoinCollection(istrue:true)
        
        if cell.goingButton.isSelected {
            
            cell.goingButton.backgroundColor = UIColor.red
            cell.goingButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            
        } else {
            
            cell.goingButton.backgroundColor = UIColor.white
            cell.goingButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            
        }
        
        cell.selectionStyle = .none
        
        //cell.separatorInset = UIEdgeInsetsMake(0.0, Constants.ScreenSize.SCREEN_WIDTH, 0.0, -Constants.ScreenSize.SCREEN_WIDTH)
        
        return cell
        
    }
    
    
    // Cell Functions
    // 1
    internal func cellTableViewCellLabel(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellDetailLabel  {
        
        //Category Cell
        let cell:TableViewCellDetailLabel = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDetailLabel") as! TableViewCellDetailLabel
        
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 2:
            cell.label_Text.text = self.donationArray[self.eventData.causeDonationType ?? 0]
        case 3:
            cell.label_Text.text = self.eventData.causeAddress ?? ""
        case 4:
            cell.label_Text.text = self.categoryName ?? ""
        default:
            //5
            cell.label_Text.text = self.categoryName ?? ""
        }
        
        return cell
        
    }
    
    internal func donationTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TabelViewCellNotifications {
        
        let cell:TabelViewCellNotifications = tableView.dequeueReusableCell(withIdentifier: "TabelViewCellNotifications") as! TabelViewCellNotifications
        
        cell.selectionStyle = .none
        
        let donationModel: DonationMoneyModel = self.eventData.donationArray[indexPath.row]
        
        cell.label_Text.enabledTypes = [.mention, .hashtag, .url]
        cell.label_Text.textColor = .black
        
        cell.label_Text.tag = indexPath.row
        
        var notification = ""
        var nameString = ""
        
        if donationModel.showUser == true {
            
            cell.imageView_Image.sd_setImage(with: URL(string: donationModel.image ?? ""), placeholderImage: nil)
            nameString = "@" + "\(donationModel.fullname ?? "")"

        } else {
            
            cell.imageView_Image.image = #imageLiteral(resourceName: "avatarSingleIcon")
            nameString = "Someone"

        }
        
        let donationType = donationModel.donationType ?? "0"

        if donationType == "0" {
            
            notification = nameString + " " + "made a donation of" + " $" + "\(donationModel.amountDonate ?? "")"
            
        } else if donationType == "1" {
            
            notification = nameString + " " + "donated" + " " + "food"
            
        } else if donationType == "2" {
            
            notification = nameString + " " + "donated" + " " + "clothes"

        } else {
            
            notification = nameString + " " + "donated" + " " + "some other things"

        }
        
        cell.label_Text.customize { label in
            
            label.text = notification
            label.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
            
            label.hashtagColor = .red
            label.mentionColor = .red
            label.URLColor     = appColor.URLColorNotification
            
            label.highlightFontName = FontNameConstants.SourceSansProSemiBold
            label.highlightFontSize = 17
            
            label.handleMentionTap { mention in
                print("You just tapped the \(mention) Mention")
                
                let selectedNotificationObj: DonationMoneyModel = self.eventData.donationArray[label.tag]
                let userid = selectedNotificationObj.userId ?? 0
                
                let userObj = AUserInfoModel(id: userid)
                self.showUserProfile(userObj)
                
            }
            
        }
        
        return cell
        
    }
    
    // 1
    func numberOfSections(in tableView: UITableView) -> Int {

        return self.eventData.donationArray.count > 0 ? 8 : 7
    }
    // 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1  {
            
            return 4
            
        } else if section == 7 {
            
            return self.eventData.donationArray.count
            
        } else {
        
            return 1
        
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:EventDetailProfileCell = tableView.dequeueReusableCell(withIdentifier: "EventDetailProfileCell") as! EventDetailProfileCell
            
            cell.delegate = self
            
            cell.eventImage.layer.cornerRadius = (cell.eventImage.frame.size.width)/2
            
            cell.eventImage.clipsToBounds = true
            
            cell.eventImage.sd_setImage(with: URL(string: self.eventData.event_image ?? ""), placeholderImage: nil)
            
            cell.eventViewLbl.text = "\(self.eventData.event_views ?? 0)" + " " + "views"
            
            cell.eventSaveButton.isSelected = self.eventData.event_favorite!
            
            // show the event title in bold color and date in simple text
            let formattedString = NSMutableAttributedString()
            
            formattedString.bold(self.eventData.title ?? "", fontSize: 17).normal("\n" + (self.eventData.sub_title ?? ""), fontSize: 15)
            
            cell.eventTitle.attributedText = formattedString
            
            cell.selectionStyle = .none
            
           // cell.separatorInset = UIEdgeInsetsMake(0.0, Constants.ScreenSize.SCREEN_WIDTH, 0.0, -Constants.ScreenSize.SCREEN_WIDTH)
            
            return cell
            
            
        } else if indexPath.section == 1 {
            
            let cell:TableViewEventDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "TableViewEventDescriptionCell") as! TableViewEventDescriptionCell
            
            cell.headerLabel.text = array_TableData[indexPath.row]
            
            switch indexPath.row {
                
            case 0:
                cell.descLabel.text = self.eventData.event_place_name
            case 1:
                cell.descLabel.text = self.eventData.start_event_date
            case 2:
                cell.descLabel.text = self.eventData.end_event_date

            default:
                cell.descLabel.text = self.eventData.description

            }
            
            cell.selectionStyle = .none
            
            //cell.separatorInset = UIEdgeInsetsMake(0.0, Constants.ScreenSize.SCREEN_WIDTH, 0.0, -Constants.ScreenSize.SCREEN_WIDTH)
            
            return cell
            
            
        } else if indexPath.section <= 4 {
            
           return self.cellTableViewCellLabel(tableView, cellForRowAt: indexPath)
            
        } else if indexPath.section == 5 {
            
            return self.cellJoinEventTableView(tableView, cellForRowAt: indexPath)

        } else if indexPath.section == 6 {
            
            //Availablilty Cell
            let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
            
            cell.label_Text.text = "Make the event public"
            
            cell.switch_ButtonOutlet.isUserInteractionEnabled = false
            
            cell.switch_ButtonOutlet.setOn(self.eventData.availability == "0" ? false : true , animated:true)
            
            cell.selectionStyle = .none
            
            return cell

        } else {
            
            return self.donationTableView(tableView, cellForRowAt: indexPath)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 5 {
            
            return 60.0
        } else {
            
            return 0.1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.section == 0 {
            
            return 220
            
        } else if indexPath.section == 7 {
            
            return 70.0

        } else if indexPath.section == 5 || indexPath.section == 1 || indexPath.section == 6 {
            
            return 60.0
            
        } else {
            
             return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return self.clearBackgroundColor()
            
        } else if section == 1 {
            
            return self.setHeaderView(title: "Cause Details")
            
        } else if section == 2 {
            
            return self.setHeaderView(title: "Things to Donate")
            
        } else if section == 3 {
            
            return self.setHeaderView(title: "Make donations at this location")
            
        } else if section == 4 {
            
            return self.setHeaderView(title: "Category")
            
        } else if section == 5 {
            
            return self.setHeaderView(title: "Host Name")
            
        } else if section == 6 {
            
            return self.setHeaderView(title: "Availability")
            
        } else {
            
            return self.setHeaderView(title: "Who Donated")

        }
    }
    
    // MARK:- Header View.
    internal func setHeaderView(title: String) -> UIView {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_Title.text = title
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 5 {
            
            let hearderView: UIView = UIView()
            hearderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70)
            hearderView.backgroundColor = UIColor.clear
            
            let btn = UIButton(type: .custom) as UIButton
            btn.setTitle("Mobilise", for: .normal)
            btn.setTitleColor(UIColor.red, for: .normal)
            btn.titleLabel?.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 17)
            btn.frame = CGRect(x: 20, y: 10, width: hearderView.frame.size.width/2.4, height: 45)
            btn.layer.borderColor = UIColor.red.cgColor
            btn.layer.borderWidth = 1.0
            btn.layer.cornerRadius = 5
            btn.clipsToBounds = true
            btn.addTarget(self, action: #selector(mobiliseButton), for: .touchUpInside)
            hearderView.addSubview(btn)
            
            let Donate = UIButton(type: .custom) as UIButton
            Donate.setTitle("Donate", for: .normal)
            Donate.setTitleColor(UIColor.red, for: .normal)
            Donate.titleLabel?.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 17)
            Donate.layer.borderColor = UIColor.red.cgColor
            Donate.layer.borderWidth = 1.0
            Donate.layer.cornerRadius = 5
            Donate.clipsToBounds = true
            Donate.frame = CGRect(x: btn.frame.size.width + 30, y: 10, width: btn.frame.size.width, height: 45)
            Donate.addTarget(self, action: #selector(donateButton), for: .touchUpInside)
            hearderView.addSubview(Donate)
            
            return hearderView
            
        } else {
            
            return self.clearBackgroundColor()
        }
        
    }

    
}
