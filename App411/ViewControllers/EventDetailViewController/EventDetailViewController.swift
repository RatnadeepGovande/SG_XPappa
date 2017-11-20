//
//  EventDetailViewController.swift
//  App411
//
//  Created by osvinuser on 7/27/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import AVFoundation
import MediaPlayer
import AVKit
import Branch
import UberRides

class EventDetailViewController: UIViewController, ShowAlert {

    // Outlet
    @IBOutlet var tableView_Main: UITableView!

    @IBOutlet var backButton: UIButton!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    let blackRequestButton = RideRequestButton()
    
    var refreshControl: UIRefreshControl!
    
    // varibales
    var array_TableData = ["Location", "Start Date","End Date", "Description", "Things to bring"]
    
    var categoryName : String?
    
    var eventData : ACreateEventInfoModel!
    var eventModelData : ACreateEventInfoModel!

    var rowHeights:[Int:CGFloat] = [:] //declaration of Dictionary
    
    var avPlayer: AVPlayer!
    
    var visibleIP : IndexPath?
    
    var aboutToBecomeInvisibleCell = -1
    
    var avPlayerLayer: AVPlayerLayer!
    
    var paused: Bool = false
    
    var videoURLs = Array<URL>()
    
    var firstLoad = true
    
    var userEventAdmin: Bool = false

    
    //MARK: View Start
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // registers nib files
        self.registerNibForTableViews()
        
        // set backgrounds
        self.setViewBackground()
        
        // Get visible index.
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            userEventAdmin = userInfoModel.id ?? 0 == eventModelData.user_id ?? 0 ? true : false
            
            if !userEventAdmin {
                cameraButton.isHidden = true
            }
        }

    }
    
    internal func registerNibForTableViews() {
    
        // tablle view cells.
        tableView_Main.register(UINib(nibName: "EventDetailProfileCell", bundle: nil), forCellReuseIdentifier: "EventDetailProfileCell")
        
        tableView_Main.register(UINib(nibName: "TableViewEventDescriptionCell", bundle: nil), forCellReuseIdentifier: "TableViewEventDescriptionCell")
        
        tableView_Main.register(UINib(nibName: "EventDetailPostCell", bundle: nil), forCellReuseIdentifier: "EventDetailPostCell")
        
        tableView_Main.register(UINib(nibName: "EventPostVideoCell", bundle: nil), forCellReuseIdentifier: "EventPostVideoCell")
        
        // table view cell.
        tableView_Main.register(UINib(nibName: "TableViewCellJoinCollection", bundle: nil), forCellReuseIdentifier: "TableViewCellJoinCollection")
        
        tableView_Main.register(UINib(nibName: "TableViewCellLabel", bundle: nil), forCellReuseIdentifier: "TableViewCellLabel")
        
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")

        // Set estimation height.
        tableView_Main.estimatedRowHeight = 80
        
        self.refreshControlAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    
    
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.showEventDetail(eventId: eventModelData.id ?? 0)
            
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
    
     func initialSetupForUberRides() {
        
        let deeplinkBehavior = DeeplinkRequestingBehavior()
        blackRequestButton.requestBehavior = deeplinkBehavior
        //Double(self.eventData.latitute)!
        
        let dropOffLat: CLLocationDegrees =  Double(self.eventData.latitute ?? "") ?? 0.0
        let dropOffLongitude: CLLocationDegrees = Double(self.eventData.longitude ?? "") ?? 0.0
        blackRequestButton.colorStyle = .black
        
        let pickupLocation = CLLocation(latitude: appDelegateShared.userCurrentLocation.latitude, longitude: appDelegateShared.userCurrentLocation.longitude)
        
        let dropoffLocation = CLLocation(latitude: dropOffLat, longitude: dropOffLongitude)
        
        let builder = RideParametersBuilder()
        builder.pickupLocation = pickupLocation
        builder.pickupNickname = ""
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = self.eventData.event_place_address ?? ""
        builder.productID = "a1111c8c-c720-46c3-8534-2fcdd730040d"
        
        blackRequestButton.rideParameters = builder.build()
    }
    
    
    internal func openActionSheet() {
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
        if userEventAdmin {
            
            let deleteActionButton = UIAlertAction(title: "Delete Event", style: .default) { action -> Void in
                print("Delete Event")
                //Are you sure you want to delete this event?
                self.alertFunctionsWithCallBack(title: "Are you sure you want to delete this event?") { (isSuccess) in
                    
                    if isSuccess.boolValue == true {
                        
                        if Reachability.isConnectedToNetwork() == true {
                            
                            self.deleteEvent(eventId: self.eventData.id ?? 0)
                            
                        } else {
                            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                            
                        }
                    }
                }
            }
            
            actionSheetController.addAction(deleteActionButton)
            
        } else {
            
            let reportActionButton = UIAlertAction(title: "Report/Spam Event", style: .default) { action -> Void in
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
        }
        actionSheetController.addAction(shareActionButton)

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
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
                    
                    print(textValue ?? "")
                    
                })
            }
        }
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

    
    
    @IBAction func cameraAction(_ sender: Any) {
    
        self.performSegue(withIdentifier: "createPost", sender: self)
        
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
        self.openActionSheet()
        
    }
    
    
   // MARK: - When user click on save event below method will work
   fileprivate func saveEventClick() {
    
        if Reachability.isConnectedToNetwork() == true {
            
            let savedEvent = self.eventData.event_favorite!
            self.saveEventForUser(eventId: eventData.id ?? 0, isSavedEvent: !savedEvent)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
    
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createPost" {
            let destinationView = segue.destination as! CreatePostController
            destinationView.eventId = eventData.id
            destinationView.delegate = self
            destinationView.postUploadAtType = PostUploadType.eventPost
        }
    }
    
    // 7
    internal func playVideoByUrl(videoUrl:String) {
        
        let player = AVPlayer(url: URL(string: videoUrl)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension EventDetailViewController : CreatePostControllerDelegate {
    
    func isCreatePost(isSuccess: Bool) {
        
        if isSuccess {
            
            self.refreshControlAPI()
        }
        
    }
    
}

extension EventDetailViewController : EventDetailProfileCellDelegate, TableViewCellJoinCollectionDelegate, EventDetailPostCellDelegate, EventPostVideoCellDelegate {
    
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
            self.saveEventClick()

        case 3:
            // click on event Image
        print("click on event Image")
            
        // Check Video.
        if self.eventData.event_video_flag == "1" {
            
            self.playVideoByUrl(videoUrl: self.eventData.event_image ?? "")

        }

        default:
            //back action
           self.navigationController?.popViewController(animated: true)

        }
        
    }
    
    //MARK: TableViewCellJoinCollectionDelegate Method
    func isGoingAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if Reachability.isConnectedToNetwork() == true {
        
            sender.isUserInteractionEnabled = false
            
            self.joinEventForUser(eventId: eventData.id ?? 0, isEventJoin: eventData.event_join ?? false, completionHandler: { ( isSuccess) in
                
                sender.isUserInteractionEnabled = true

            })
            
        } else {
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
    //MARK: EventDetailPostCellDelegate Method
    func isLikedAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        let isLiked: Int = sender.isSelected ? 1 : 0
        
        if sender.isSelected {
            
            sender.backgroundColor = UIColor.red
            sender.setTitleColor(UIColor.white, for: UIControlState.normal)
            
        } else {
            
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(UIColor.red, for: UIControlState.normal)
            
        }
        
        let dict = self.eventData.event_postArray[sender.tag]
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.postLikeAndDisLike(event_ID: eventData.id ?? 0, post_ID: dict.id ?? 0, status_isLiked: isLiked, postObj: dict, selectedTag: sender.tag)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    func isLikedVideoAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        let isLiked: Int = sender.isSelected ? 1 : 0
        
        if sender.isSelected {
            
            sender.backgroundColor = UIColor.red
            sender.setTitleColor(UIColor.white, for: UIControlState.normal)
            
        } else {
            
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(UIColor.red, for: UIControlState.normal)
            
        }
        
        
        
        let dict = self.eventData.event_postArray[sender.tag]
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.postLikeAndDisLike(event_ID: eventData.id ?? 0, post_ID: dict.id ?? 0, status_isLiked: isLiked, postObj: dict, selectedTag: sender.tag)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
}


extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 1
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count > 0 {
        
            return 7
            
        } else if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count <= 0 || self.eventData.event_HostArray.count <= 0 && self.eventData.event_postArray.count > 0 {
            
            if userEventAdmin {
                
                if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count <= 0 {
                    
                    return 6
                    
                } else {
                    
                    return 7
                }
            } else {
                
                return 6
            }
            
        } else {
            
            return !userEventAdmin ? 5 : 6
        }
    }
    // 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section <= 4  {
        
            return section == 1 ?  array_TableData.count : 1
        
        } else {
            
            if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count > 0 {
                
                return section == 5 ? 1 : self.eventData.event_postArray.count
                
            } else {

                return (section == 5 && self.eventData.event_postArray.count > 0 && self.eventData.event_HostArray.count <= 0) ? self.eventData.event_postArray.count : 1

            }
        }
    }
    
    
    fileprivate func addBlackRequestButtonConstraints() {
        
    }
    
    // 3
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:EventDetailProfileCell = tableView.dequeueReusableCell(withIdentifier: "EventDetailProfileCell") as! EventDetailProfileCell
            
            cell.delegate = self
            
            cell.eventImage.layer.cornerRadius = (cell.eventImage.frame.size.width)/2
            
            cell.eventImage.clipsToBounds = true
            
            // Check Video.
            if self.eventData.event_video_flag == "1" {
                
                cell.eventImageButton.isHidden = false
                cell.eventImageButton.setImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
                
                cell.eventImage.sd_setImage(with: URL(string: self.eventData.event_Thumbnail ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
                
            } else {
                
                cell.eventImageButton.isHidden = true

                cell.eventImage.sd_setImage(with: URL(string: self.eventData.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
                
            }
            
            cell.eventViewLbl.text = "\(self.eventData.event_views ?? 0)" + " " + "views"
            
            cell.eventSaveButton.isSelected = self.eventData.event_favorite!
            
            // show the event title in bold color and date in simple text
            let formattedString = NSMutableAttributedString()
            
            formattedString.bold(self.eventData.title ?? "", fontSize: 17).normal("\n" + (self.eventData.sub_title ?? ""), fontSize: 15)
            
            cell.eventTitle.attributedText = formattedString
            
            cell.selectionStyle = .none
            
            cell.addSubview(blackRequestButton)
            
            blackRequestButton.translatesAutoresizingMaskIntoConstraints = false
            
            let saveButtonConstraints : [NSLayoutConstraint] = [
                
                blackRequestButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0),
                blackRequestButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
            ]
            
            NSLayoutConstraint.activate(saveButtonConstraints)
            
            cell.separatorInset = UIEdgeInsetsMake(0.0, Constants.ScreenSize.SCREEN_WIDTH, 0.0, -Constants.ScreenSize.SCREEN_WIDTH)

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
                case 3:
                    cell.descLabel.text = self.eventData.description
                default:
                    cell.descLabel.text = self.eventData.things_to_bring
                
            }
            
            cell.selectionStyle = .none
            
            cell.separatorInset = UIEdgeInsetsMake(0.0, Constants.ScreenSize.SCREEN_WIDTH, 0.0, -Constants.ScreenSize.SCREEN_WIDTH)

            return cell

            
        } else if indexPath.section == 2 {
            //Category Cell
            let cell:TableViewCellLabel = tableView.dequeueReusableCell(withIdentifier: "TableViewCellLabel") as! TableViewCellLabel
            
            cell.selectionStyle = .none
            
            cell.label_Text.text = self.categoryName ?? ""
            
            return cell
            
        } else if indexPath.section == 3 {
            //Availablilty Cell
            let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
            
            cell.label_Text.text = "Make the event public"
            
            cell.switch_ButtonOutlet.isUserInteractionEnabled = false
            
            cell.switch_ButtonOutlet.setOn(self.eventData.availability == "0" ? false : true , animated:true)
            
            cell.selectionStyle = .none
            
            return cell

            
        } else if indexPath.section == 4 {
            
            return self.cellJoinEventTableView(tableView, cellForRowAt: indexPath)

        } else {
        
            if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count > 0 {
                
                if indexPath.section == 5 {
                    
                    return self.cellJoinEventTableView(tableView, cellForRowAt: indexPath)
                    
                } else {
                    
                    return self.cellImageAndVideoPostTableView(tableView, cellForRowAt: indexPath)
                    
                }
                
            } else {
            
                if indexPath.section == 5 && userEventAdmin || indexPath.section == 5 && self.eventData.event_HostArray.count > 0 {
                    
                    return self.cellJoinEventTableView(tableView, cellForRowAt: indexPath)

                } else {
                    
                    return self.cellImageAndVideoPostTableView(tableView, cellForRowAt: indexPath)

                }
                
            }
            
        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        } else if section == 1 {
            
            return self.setHeaderView(title: "Event Details")
            
        } else if section == 2 {
            
            return self.setHeaderView(title: "Category")

        } else if section == 3 {
            
            return self.setHeaderView(title: "Availability")
            
        } else if section == 4 {
            
            return self.setHeaderView(title: "Who Joined")
           
        } else {
        
            if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count > 0 {
                
                return section == 5 ? self.setHeaderView(title: "Host Details") : self.setHeaderView(title: "Feeds")
                
            } else {
                
                if section == 5 && userEventAdmin || section == 5 && self.eventData.event_HostArray.count > 0 {
                    
                    return self.setHeaderView(title: "Host Details")
                    
                } else {
                
                    return self.setHeaderView(title: "Feeds")
                
            }
            
          }
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10.0 : 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 5 && userEventAdmin {
            
             return 40.0
        } else {
            
            return 0.1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.section == 0 || indexPath.section == 1 {
            
            return indexPath.section == 0 ? 270 : UITableViewAutomaticDimension
            
        } else if indexPath.section <= 4 {
            
            return 60
            
        } else {
        
            if self.eventData.event_HostArray.count > 0 && self.eventData.event_postArray.count > 0 {
                
                if indexPath.section == 5 {
                    
                    return 60
                    
                } else {
                    
                    let dict = self.eventData.event_postArray[indexPath.row]
                    
                    if dict.postVideoFlag == 2 || dict.postVideoFlag == 1 {
                        
                        return UITableViewAutomaticDimension
                        
                    } else {
                        
                        guard let height = self.rowHeights[indexPath.row] else {
                            
                            return UITableViewAutomaticDimension
                        }
                        
                        return height
                    }
                    
                }
                
            } else {
                
                if indexPath.section == 5 && userEventAdmin || indexPath.section == 5 && self.eventData.event_HostArray.count > 0  {
                    
                    return 60
                    
                } else {
                    
                    let dict = self.eventData.event_postArray[indexPath.row]
                    
                    if dict.postVideoFlag == 2 || dict.postVideoFlag == 1 {
                        
                        return UITableViewAutomaticDimension
                        
                    } else {
                        
                        guard let height = self.rowHeights[indexPath.row] else {
                            
                            return UITableViewAutomaticDimension
                        }
                        
                        return height
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 5 && userEventAdmin {
            
            let hearderView: UIView = UIView()
            hearderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70)
            hearderView.backgroundColor = UIColor.clear
            
            let btn = UIButton(type: .custom) as UIButton
            btn.setTitle("+ Add more hosts", for: .normal)
            btn.setTitleColor(UIColor.red, for: .normal)
            btn.titleLabel?.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
            btn.frame = CGRect(x: 0, y: 0, width: hearderView.frame.size.width/1.2, height: 40)
            btn.center = hearderView.center
            //btn.backgroundColor = UIColor.gray
            btn.addTarget(self, action: #selector(createHostsEvent), for: .touchUpInside)
            hearderView.addSubview(btn)
            
            return hearderView
            
        } else {
            
           return self.clearBackgroundColor()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.eventData.event_postArray.count > 0 && indexPath.section == 6 || indexPath.section == 5 && self.eventData.event_HostArray.count == 0 {
            
            let dict = self.eventData.event_postArray[indexPath.row]
            
            if dict.postVideoFlag == 1 {
                
                self.playVideoByUrl(videoUrl: self.eventData.event_postArray[indexPath.row].postImageURL!)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? EventPostVideoCell{
            videoCell.stopPlayback()
        }
        
        paused = true
    }
    
    // Cell Functions
    // 1
    internal func cellJoinEventTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        let cell:TableViewCellJoinCollection = tableView.dequeueReusableCell(withIdentifier: "TableViewCellJoinCollection") as! TableViewCellJoinCollection
        
        cell.delegate = self
        
        if indexPath.section == 4 {
        
            if userEventAdmin {
                
                cell.goingButton.isHidden = true
                
            } else {
                
                cell.goingButton.isEnabled = true
                cell.goingButton.isHidden = false
                cell.goingButton.setTitle(self.eventData.event_join ?? false == true ? "Going" : "I'm Going", for: .normal)
                
                cell.goingButton.isSelected = self.eventData.event_join!
            }
        } else {
            
            cell.goingButton.isHidden = true
        }
        
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
        
        cell.separatorInset = UIEdgeInsetsMake(0.0, Constants.ScreenSize.SCREEN_WIDTH, 0.0, -Constants.ScreenSize.SCREEN_WIDTH)
        
        return cell
        
    }
    
    // 2
    internal func cellImageAndVideoPostTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        let dict = self.eventData.event_postArray[indexPath.row]
        
        if dict.postVideoFlag == 1 {
            
            return self.videoEventPostCell(tableView: tableView, indexpath: indexPath.row)
            
        } else {
            
            return self.imageAndTextTableViewCell(tableView: tableView, indexpath: indexPath.row)
        }
        
    }
    
    // 3
    internal func videoEventPostCell(tableView:UITableView, indexpath:Int) -> UITableViewCell {
        
        let cell:EventPostVideoCell = tableView.dequeueReusableCell(withIdentifier: "EventPostVideoCell") as! EventPostVideoCell
        
        tableView.separatorStyle = .singleLine
        
        cell.delegate = self
        
        cell.selectionStyle = .none

        
        let dict = self.eventData.event_postArray[indexpath]
        
        let userImageOfPost = dict.postUserDict
        
        cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: dict.postImageThumbnail ?? "")!)

        cell.ProfileImage.layer.cornerRadius = (cell.ProfileImage.frame.size.width)/2
        
        cell.ProfileImage.clipsToBounds = true
        
        cell.ProfileImage.sd_setImage(with: URL(string: userImageOfPost?.image ?? ""), placeholderImage: nil)
        
        cell.likeButton.tag = indexpath
        //show the event title in bold color and date in simple text
        let formattedString = NSMutableAttributedString()
        
        formattedString.attributedValue(userImageOfPost?.fullname ?? "", fontName: FontNameConstants.SourceSansProSemiBold, fontSize: 16).normal("\n" + self.getEventDate(eventDate: dict.postCreatedDate!), fontSize: 14)
        
        cell.nameLabel.attributedText = formattedString
        
        cell.contentLabel.text = dict.postContent
        
        if dict.like_status == 1 {
            
            cell.likeButton.backgroundColor = UIColor.red
            cell.likeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            cell.likeButton.isSelected = true
            
        } else {
            
            cell.likeButton.backgroundColor = UIColor.white
            cell.likeButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            cell.likeButton.isSelected = false
            
        }
        
        
        return cell
        
    }
    
    // 4
    internal func imageAndTextTableViewCell(tableView:UITableView, indexpath:Int) -> UITableViewCell {
        
        let cell:EventDetailPostCell = tableView.dequeueReusableCell(withIdentifier: "EventDetailPostCell") as! EventDetailPostCell
        
        tableView.separatorStyle = .singleLine
        
        cell.delegate = self
        
        cell.selectionStyle = .none
        
        let dict = self.eventData.event_postArray[indexpath]
        
        let userImageOfPost = dict.postUserDict
        
        cell.imageView_Image.layer.cornerRadius = (cell.imageView_Image.frame.size.width)/2
        
        cell.imageView_Image.clipsToBounds = true
        
        cell.imageView_Image.sd_setImage(with: URL(string: userImageOfPost?.image ?? ""), placeholderImage: nil)
        
        //show the event title in bold color and date in simple text
        let formattedString = NSMutableAttributedString()
        
        formattedString.attributedValue(userImageOfPost?.fullname ?? "", fontName: FontNameConstants.SourceSansProSemiBold, fontSize: 17).normal("\n" + self.getEventDate(eventDate: dict.postCreatedDate!), fontSize: 15)
        
        cell.label_name.attributedText = formattedString
        
        if dict.postVideoFlag == 0 {
            
            let heightOfPost = self.calculateImageHeight(Object: dict)
            
            self.rowHeights[indexpath] = heightOfPost.imageHeight + heightOfPost.postText + 10.0
            
            cell.postImageConstraint.constant = heightOfPost.imageHeight
            
            cell.layoutIfNeeded()
            
            cell.postImage.sd_setImage(with: URL(string: dict.postImageURL ?? ""), placeholderImage: nil)
            
            cell.postImage.layer.cornerRadius = 5
            
            cell.postImage.clipsToBounds = true
            
        } else {
            
            cell.postImageConstraint.constant = 0.0
            
        }
        
        cell.likeButton.tag = indexpath

        if dict.like_status == 1 {
            
            cell.likeButton.backgroundColor = UIColor.red
            cell.likeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            cell.likeButton.isSelected = true
            
        } else {
            
            cell.likeButton.backgroundColor = UIColor.white
            cell.likeButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            cell.likeButton.isSelected = false
            
        }
        
        cell.label_Text.text = dict.postContent
        
        
        return cell
            
    }
    
    // 5
    internal func getEventDate(eventDate:String) -> String {
    
        let date = self.getDateFormatterFromServer(stringDate: eventDate)
        
        return date!.timeAgo
    }
    
    // 6
    internal func calculateImageHeight(Object:AEventPostInfoModel) -> (imageHeight: CGFloat, postText:CGFloat) {
        
        guard let imageNewWidth = NumberFormatter().number(from: Object.postImageWidth!) else {
            print("width not found")
            return (0.0,0.0)
        }
        
        guard let imageNewHeight = NumberFormatter().number(from: Object.postImageHeight!) else {
            print("width not found")
            return (0.0,0.0)
        }
        
        let aspectRatio = CGFloat(imageNewHeight)/CGFloat(imageNewWidth)
        
        let actualHeight = (self.view.frame.width/aspectRatio)*aspectRatio
        
        let labelFrame: CGRect = self.heightForLabel(text:  Object.postContent!, font: UIFont(name: FontNameConstants.SourceSansProRegular, size: 16)!, width: Constants.ScreenSize.SCREEN_WIDTH - 133)
        
        return (actualHeight, labelFrame.size.height + 100)

    }
    
    func createHostsEvent(sender:UIButton!) {
        print("Button Clicked")
        
        let object = self.storyboard?.instantiateViewController(withIdentifier: "HostNameFriendListViewController") as! HostNameFriendListViewController
        object.eventInfoMapperObj = eventData
        object.isEventHost = 1
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(object, animated: true)

        //eventInfoMapperObj
    }

    
    func playerItemDidReachEnd(notification: Notification) {
        
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        
        p.seek(to: kCMTimeZero)
        
    }
    
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
        
        
        
        let indexPaths = self.tableView_Main.indexPathsForVisibleRows
        
        var cells = [Any]()
        
        if let indexpathArray = indexPaths {
            
            for ip in indexpathArray {
                
                if let videoCell = self.tableView_Main.cellForRow(at: ip) as? EventPostVideoCell {
                    
                    cells.append(videoCell)
                    
                } else {
                    
                    if let imageCell = self.tableView_Main.cellForRow(at: ip) as? EventDetailPostCell {
                        
                        cells.append(imageCell)
                        
                    }
                    
                }
                
            }
            
            let cellCount = cells.count
            
            if cellCount == 0 { return }
            
            if cellCount == 1 {
                
                if visibleIP != indexPaths?[0] {
                    
                    visibleIP = indexPaths?[0]
                    
                }
                
                if let videoCell = cells.last! as? EventPostVideoCell {
                    
                    self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
                    
                }
                
            }
            
            if cellCount >= 2 {
                
                for i in 0..<cellCount {
                    
                    let cellRect = self.tableView_Main.rectForRow(at: (indexPaths?[i])!)
                    
                    let intersect = cellRect.intersection(self.tableView_Main.bounds)
                    
                    let currentHeight = intersect.height
                    
                    let cellHeight = (cells[i] as AnyObject).frame.size.height
                    
                    if currentHeight > (cellHeight * 0.95) {
                        
                        if visibleIP != indexPaths?[i] {
                            
                            visibleIP = indexPaths?[i]
                            
                            if let videoCell = cells[i] as? EventPostVideoCell {
                                
                                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                                
                            }
                            
                        }
                        
                    } else {
                        
                        if aboutToBecomeInvisibleCell != indexPaths?[i].row {
                            
                            aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                            
                            if let videoCell = cells[i] as? EventPostVideoCell {
                                
                                self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
    func changeUIButtonValues(alphaValue: CGFloat, interactionOfButton : Bool) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backButton.alpha = alphaValue
            self.moreButton.alpha = alphaValue

//            self.cameraButton.alpha = alphaValue
        }, completion: { (finished) in
            self.moreButton.isUserInteractionEnabled = interactionOfButton
            self.backButton.isUserInteractionEnabled = interactionOfButton
//            self.cameraButton.isUserInteractionEnabled = interactionOfButton
        })
        
    }
    func checkVisibilityOfCell(cell : EventPostVideoCell, indexPath : IndexPath) {
        
        let cellRect = self.tableView_Main.rectForRow(at: indexPath)
        
        let completelyVisible = self.tableView_Main.bounds.contains(cellRect)
        
        if completelyVisible {
            
            self.playVideoOnTheCell(cell: cell, indexPath: indexPath)
            
        } else {
            
            if aboutToBecomeInvisibleCell != indexPath.row {
                
                aboutToBecomeInvisibleCell = indexPath.row
                
                self.stopPlayBack(cell: cell, indexPath: indexPath)
                
            }
            
        }
        
    }
    
    func playVideoOnTheCell(cell : EventPostVideoCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : EventPostVideoCell, indexPath : IndexPath) {
        cell.stopPlayback()
    }
    
   

}
