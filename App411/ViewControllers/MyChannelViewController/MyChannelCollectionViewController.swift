//
//  MyChannelCollectionViewController.swift
//  App411
//
//  Created by osvinuser on 9/1/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage
import MediaPlayer
import AVFoundation
import AVKit

private let reuseIdentifier = "Cell"


class MyChannelCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ShowAlert {

    
    @IBOutlet var barButton_Search: UIBarButtonItem!
    @IBOutlet var barButton_Camera: UIBarButtonItem!
    
    
    var refreshControl: UIRefreshControl!
    var channelUserData: MyChannelDetailInfoModel?
    
    
    // MARK: - Black Background view
    
    var blackBackgroundView = UIView()
    var staticPostImageView = UIImageView()
    var zoomImageView = UIImageView()
    var navBarView = UIView()
    var tabBarView = UIView()
    
    
    var isUserChannelData: Bool = true
    var channelID: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(ChannelPostImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView!.register(UINib(nibName: "SubscribeChannelCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SubscribeChannelCollectionViewCell")


        self.collectionView!.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        self.collectionView!.register(UINib(nibName: "EmptyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCollectionViewCell")
        
        self.collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        
        // Do any additional setup after loading the view.
        navigationItem.title = "My Channel"
        
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView!.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        self.setViewBackground()
        self.refreshControlAPI()
    
        
        // Reload Event List Data.
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAPI), name: Notification.Name(rawValue: "ReloadChannelDataAPINotification"), object: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - refresh control For API
    
    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        self.collectionView?.addSubview(refreshControl) // not required when using UITableViewController
        
        // First time automatically refreshing.
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    // MARK: - Reload API
    func reloadAPI() {
        
        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        
        //check net connection
        if Reachability.isConnectedToNetwork() == true {

            // Current User
            guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                return
            }
            
            if isUserChannelData == true {
                self.myChannelDetail(authToken: userInfoModel.authentication_token ?? "", channelID: userInfoModel.channelId ?? 0)
            } else {
                self.myChannelDetail(authToken: userInfoModel.authentication_token ?? "", channelID: channelID)
            }
            
        } else {
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if let channelId = self.channelUserData?.id, channelId != 0 {
            return 3
        } else {
            return 0
        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        if section == 0 {
        
            return 0
            
        } else {
            
            if section == 1, let arrayCount = self.channelUserData?.myPostInfoArray.count, arrayCount > 0 {
                
                return arrayCount
                
            } else {
                
                if let subscriptionArrayCount = self.channelUserData?.subscribedChannelArray.count {
                    
                    return subscriptionArrayCount
                    
                }
            }
            
        }
        
        return 0
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCollectionViewCell", for: indexPath)
            
            // cell.myLabel.text = self.items[indexPath.item]
            
            return cell
            
        
        } else if indexPath.section == 1 {
            
            let channelPostImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChannelPostImageCell
            
            channelPostImageCell.delegate = self
            
            // Configure the cell
            if let postModelInfo = self.channelUserData?.myPostInfoArray[indexPath.item] {
            
                // Configure the cell
                channelPostImageCell.postModelInfo = postModelInfo
            
            }
            
            return channelPostImageCell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscribeChannelCollectionViewCell", for: indexPath) as! SubscribeChannelCollectionViewCell

            cell.button_subscribe.tag = indexPath.item
            cell.backgroundColor = UIColor.white
            cell.delegate = self
            
            let channelObj = self.channelUserData?.subscribedChannelArray[indexPath.item]

            objc_setAssociatedObject(cell.button_subscribe, &AssociatedObjectHandle, channelObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            
            if let channelName = channelObj?.channelName {
                cell.label_Title.text = channelName
            }
            
            cell.imageView_Channel.sd_setImage(with: URL(string: channelObj?.imageLink ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
            
            
            if let channelViewersCount = channelObj?.subcription_count {
                cell.label_ViewerCount.text = channelViewersCount > 0 ? "\(channelViewersCount) Subscribers" : "\(channelViewersCount) Subscriber"
            }
            
            cell.button_subscribe.setTitle("UnSubscribe",for: .normal)
            
            return cell
        }
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) ->
        CGSize {
        
        if indexPath.section == 0 {
        
            return CGSize(width: view.frame.width, height: 10)
            
        } else if indexPath.section == 1, let arrayCount = self.channelUserData?.myPostInfoArray.count, arrayCount > 0 {
        
            let staticHeight: CGFloat = 8 + 44 + 4 + 4 + 16
            var cellSize: CGSize = CGSize(width: collectionView.frame.size.width, height: staticHeight)
            
            // Configure the cell
            if let postModelInfo = self.channelUserData?.myPostInfoArray[indexPath.item] {
                
                //
                if let statusText = postModelInfo.postContent {
                    let textheight = statusText.height(withConstrainedWidth: view.frame.size.width-16, font: UIFont.systemFont(ofSize: 14))
                    cellSize.height += textheight
                    cellSize.height += 10
                }
                
                if let videoFlag = postModelInfo.postVideoFlag {
                    
                    if videoFlag == 0 {
                        
                        let imageWidth = NumberFormatter().number(from: postModelInfo.postImageWidth ?? "320")
                        let imageHeight = NumberFormatter().number(from: postModelInfo.postImageHeight ?? "480")
                        
                        cellSize.height += Singleton.sharedInstance.calculateImageViewSize(imageW: imageWidth as! CGFloat, imageH: imageHeight as! CGFloat, cellW: collectionView.frame.size.width)
                        
                        cellSize.height -= 15
                        
                    } else if videoFlag == 1 {
                        
                        cellSize.height += 300
                        
                    }
                    
                }
                
            }
            
            return cellSize
            
        } else {
            
            return CGSize(width: view.frame.width, height: 100)

        }
            
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
            case UICollectionElementKindSectionHeader:
                
                if indexPath.section == 0 {
                
                    let reusableview: HeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderCollectionReusableView
                    
                    reusableview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 200)
                    
                    reusableview.delegate = self
                    
                    print(self.channelUserData?.channelName ?? "Name Not found")
                    
                    if let profileURL = self.channelUserData?.profileImageUrl {
                        reusableview.imageView_ProfileImage.sd_setImage(with: URL(string: profileURL), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
                    } else {
                        reusableview.imageView_ProfileImage.image = #imageLiteral(resourceName: "avatarSmallImage")
                    }
                    
                    if let channelCoverImage = self.channelUserData?.channelBackgroundImageUrl {
                        reusableview.imageView_CoverImage.sd_setImage(with: URL(string: channelCoverImage), placeholderImage: nil)
                    } else {
                        reusableview.imageView_CoverImage.image = nil
                    }
                    
                    
                    if let channelName = self.channelUserData?.channelName {
                        reusableview.label_Name.text = channelName
                    }
                    
                    if let channelViewersCount = self.channelUserData?.subscriptionCount {
                        reusableview.label_Viewers.text = channelViewersCount > 0 ? "\(channelViewersCount) Views" : "\(channelViewersCount) View"
                    }
                    
                    
                    if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
                        
                        if let channelUserDict = self.channelUserData?.channelUserDict {
                        
                            reusableview.settingButton.isHidden = userInfoModel.id ?? 0 == channelUserDict.id ? false : true
                            reusableview.subcribeButton.isHidden = userInfoModel.id ?? 0 == channelUserDict.id ? true : false
                            
                        }

                    }

                    //do other header related calls or settups
                    return reusableview
                    
                } else {
                    
                    var reusableview: UICollectionReusableView? = nil
                    reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
                    let viewsToRemove = reusableview?.subviews
                    
                    if let removeViews = viewsToRemove {
                        for v: UIView in removeViews {
                            v.removeFromSuperview()
                        }
                    }
                    
                    if reusableview == nil {
                        reusableview = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
                    }
                
                    reusableview!.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                    
                    let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
                    
                    label_Title.text = indexPath.section == 1 ? "Posts" : "Subscribed Channels"
                    
                    label_Title.textColor = UIColor.black
                    
                    label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
                    
                    reusableview!.addSubview(label_Title)
                    
                    return reusableview!
                    
                }
            
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                footerView.backgroundColor = UIColor.clear
                return footerView
                
            
            default:  fatalError("Unexpected element kind")
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
        
            return CGSize(width: Int(self.view.frame.size.width), height: 200)
            
        } else {
            
            return CGSize(width: Int(self.view.frame.size.width), height: 40)

        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collcetionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    
        return CGSize(width: self.view.frame.size.width, height: 10)
        
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - IBAction.
    
    @IBAction func cameraButtonAction(_ sender: Any) {
    
        self.performSegue(withIdentifier: "seguePostChannel", sender: self)
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "seguePostChannel" {
            
            let destinationView: CreatePostController = segue.destination as! CreatePostController
            destinationView.postUploadAtType = PostUploadType.ChannelPost
            
        } else if segue.identifier == "channelEdit" {
            
            let destinationView: ChannelDetailsViewController = segue.destination as! ChannelDetailsViewController
            destinationView.channelDetail = self.channelUserData
            
        } else if segue.identifier == "segueChannelList" {
            
            let destinationView: MySubscriptionsListViewController = segue.destination as! MySubscriptionsListViewController
            destinationView.delegate = self
            
        }
        
    }
    

    
    // MARK: - My Channel Details.
    
    internal func myChannelDetail(authToken: String, channelID: Int) {
        
        /*
        // Current User
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        */
        // let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&channel_id=\(userInfoModel.channelId ?? 0)"

        
        // API's param.
        let paramsStr = "auth_token=\(authToken)&channel_id=\(channelID)"
        print(paramsStr)

        
        // Auth_token, Channel_id
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.myChannelRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        if let channelData = jsonResult["channel_detail"] as? Dictionary<String, AnyObject> {
                            
                            if let channelInfoMapperObj = Mapper<MyChannelDetailInfoModel>().map(JSONObject: channelData) {
                                self.channelUserData = channelInfoMapperObj
                            }
                            
                            DispatchQueue.main.async(execute: {
                                self.collectionView?.reloadData()
                            })
                        }
                        
                    } else {
                        
                        // self.tableView_Main.setBackGroundOfTableView(arrayBlockedList: [])
                        // When data Not found.
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
}


extension MyChannelCollectionViewController:  HeaderCollectionReusableViewDelegate, SubscribeChannelCollectionViewCellDelegate {
    
    func clickOnSettingButtAction() {
        if channelUserData != nil {
            
            self.performSegue(withIdentifier: "channelEdit", sender: self)
            
        }
    }
    
    func clickOnSubscribeButtonAction(_ sender: UIButton) {
        
    }
    
    
    func clickOnSubscribeOrUnSubscribeButton(_ sender: UIButton) {
        
        let getData = objc_getAssociatedObject(sender, &AssociatedObjectHandle)
        
        print(getData)
        
        if channelUserData != nil {
            
            //check net connection
            if Reachability.isConnectedToNetwork() == true {
                
                // Current User
                guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                    return
                }
                
                self.subscribeAndUnSubscribeAPI(authToken: userInfoModel.authentication_token ?? "", channelID: channelID, sender: sender)
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
         }
    }
    
    // MARK: - Subscribe and UnSubscribe API.
    
    internal func subscribeAndUnSubscribeAPI(authToken: String, channelID: Int, sender: Any) {
    
        // localhost:3000/api/v1/subscribe_unsubscribe_channel?auth_token=5vN9ESgjJ_Vvk5G6seNu&channel_id=1
        // API's param.
        let paramsStr = "auth_token=\(authToken)&channel_id=\(channelID)"
        print(paramsStr)
        
            
        // Auth_token, Channel_id
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.subscribe_unsubscribe_channel, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        if responeCode == true {
                            (sender as AnyObject).setTitle("Subscribed",for: .normal)
                        } else {
                            (sender as AnyObject).setTitle("Subscribe",for: .normal)
                        }
                        
                        
                    } else {
                        
                        // self.tableView_Main.setBackGroundOfTableView(arrayBlockedList: [])
                        // When data Not found.
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    
}


extension MyChannelCollectionViewController: ChannelPostImageCellDelegate {

    // MARK:- Play Video.
    func playPostVideoWithTapGesture(playerItem: AVPlayerItem) {
        
        let player = AVPlayer(playerItem: playerItem)
        player.volume = 1
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
    }
    
    
    // MARK: - Zoom image Animation
    func zoomImageAnimationWithTapGesture(postImageView: UIImageView) {
        
        staticPostImageView = postImageView
        
        if let startingFrame = postImageView.superview?.convert(postImageView.frame, to: nil) {
            
            // Hidden cell image view.
            postImageView.alpha = 0
            
            blackBackgroundView.frame = Constants.ScreenSize.SCREEN_BOUNDS
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            self.view.addSubview(blackBackgroundView)
            
            
            // add navigation bar
            navBarView.frame = CGRect(x: 0, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH, height: 20 + 44)
            navBarView.backgroundColor = UIColor.black
            navBarView.alpha = 0
            
            // add tab bar
            tabBarView.frame = CGRect(x: 0, y: Constants.ScreenSize.SCREEN_HEIGHT - 49, width: Constants.ScreenSize.SCREEN_WIDTH, height: 49)
            tabBarView.backgroundColor = UIColor.black
            tabBarView.alpha = 0
            
            appDelegateShared.window?.addSubview(navBarView)
            appDelegateShared.window?.addSubview(tabBarView)
            
            
            // Add background view.
            zoomImageView.backgroundColor = UIColor.red
            zoomImageView.frame = CGRect(x: startingFrame.origin.x, y: startingFrame.origin.y-64, width: startingFrame.width, height: startingFrame.height)
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.image = postImageView.image
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            self.view.addSubview(zoomImageView)
            
            
            // Add Gesture for zoom view.
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.zoomOutImageViewTapGesture(_:))))
            
            // ImageView animation.
            UIView.animate(withDuration: 0.75) {
                
                let height = (self.view.frame.size.width /  startingFrame.width) * startingFrame.height
                let y = self.view.frame.size.height / 2 - height / 2
                self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.size.width, height: height)
                self.blackBackgroundView.alpha = 1
                self.navBarView.alpha = 1
                self.tabBarView.alpha = 1
                
            }
            
        }
        
    }
    
    func zoomOutImageViewTapGesture(_ sender: UITapGestureRecognizer) {
        
        print("Remove Zoom Image View")
        
        if let startingFrame = staticPostImageView.superview?.convert(staticPostImageView.frame, to: nil) {
            
            UIView.animate(withDuration: 0.75, animations: {
                
                self.zoomImageView.frame = CGRect(x: startingFrame.origin.x, y: startingFrame.origin.y-64, width: startingFrame.width, height: startingFrame.height)
                self.blackBackgroundView.alpha = 0
                self.navBarView.alpha = 0
                self.tabBarView.alpha = 0
                
            }) { (finished) in
                
                self.staticPostImageView.alpha = 1
                self.zoomImageView.removeFromSuperview()
                self.blackBackgroundView.removeFromSuperview()
                self.navBarView.removeFromSuperview()
                self.tabBarView.removeFromSuperview()
                
            }
            
        }
        
    }
    
    
    func clickOnUserName(user: AUserInfoModel) {
        self.showUserProfile(user)
    }
    
}

extension MyChannelCollectionViewController:  MySubscriptionsListViewControllerDelegate {

    func selectedUserChannelID(channelID: Int, isUserChannel: Bool) {
    
        isUserChannelData = isUserChannel
        self.channelID = channelID
        
        if isUserChannel == false {
        
            self.navigationItem.rightBarButtonItems =  [barButton_Search]
            
        } else {
        
            self.navigationItem.rightBarButtonItems = [barButton_Camera, barButton_Search]
            
        }
        
        self.reloadAPI()
        
    }
    
}

