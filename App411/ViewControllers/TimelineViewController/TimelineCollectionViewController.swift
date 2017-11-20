//
//  TimelineCollectionViewController.swift
//  App411
//
//  Created by osvinuser on 8/8/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ActionCableClient
import ObjectMapper
import AVFoundation
import AVKit
import SDWebImage

private let reuseIdentifier = "CellIdentifier"

class TimelineCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ShowAlert, TimelineFeedCellDelegate {
    

    var arrayPostData = [ATimeLinePostInfoModel]()

    var refreshControlTop: UIRefreshControl!
    var refreshControlBottom: UIRefreshControl!
    
    
    // MARK: - Black Background view
    var blackBackgroundView = UIView()
    var staticPostImageView = UIImageView()
    var zoomImageView = UIImageView()
    var navBarView = UIView()
    var tabBarView = UIView()
    
    var post_Count: Int = 0
    var isAPILoaded: Bool = true
    var isFullDataFound: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView!.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // Register cell classes
        self.collectionView!.register(TimelineFeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // self.collectionView!.register(UINib(nibName: "FooterIndicatorView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "RefreshFooterIndicatorViewRefresh")
        
        // Add refresh controller
        self.refreshControlAPI()
        
        // Add Action Cable Subscribe Channels
        self.addActionCableSubscribeChannels()
        
    }
    
    
    // MARK: - refresh control For API
    internal func refreshControlAPI() {
        
        refreshControlTop = UIRefreshControl()
        refreshControlTop.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        self.collectionView?.addSubview(refreshControlTop) // not required when using UITableViewController
        
        refreshControlBottom = UIRefreshControl()
        refreshControlBottom.addTarget(self, action: #selector(self.reloadAPIByCount), for: .valueChanged)
        self.collectionView?.bottomRefreshControl = refreshControlBottom
        
        // First time automatically refreshing.
        refreshControlTop.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    func refreshManually() {
    
        // First time automatically refreshing.
        refreshControlTop.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    
    // MARK: - Reload API
    func reloadAPI() {
        
        // Check network connection.
        if Reachability.isConnectedToNetwork() == true {
            
            post_Count = 0
            
            // call Friend list API.
            self.getTimePostDataFromAPI(count: String(post_Count))
                        
        } else {
            
            // Refresh end.
            self.refreshControlTop.endRefreshing()
            self.refreshControlBottom.endRefreshing()
            
            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    func reloadAPIByCount() {
    
        if self.isAPILoaded == true && self.arrayPostData.count > 0 {
            
            self.post_Count = self.arrayPostData.count + 10
            
            // Check network connection.
            if Reachability.isConnectedToNetwork() == true {
                
                // call Friend list API.
                self.getTimePostDataFromAPI(count: String(post_Count))
                
            } else {
                
                // Refresh end.
                self.refreshControlTop.endRefreshing()
                self.refreshControlBottom.endRefreshing()
                
                // Show Internet Connection Error
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
        
        }
        
    }
    
    func clickOnUserName(user: AUserInfoModel) {
        self.showUserProfile(user)
    }
    
    // MARK: - Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayPostData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        let timelineFeedCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TimelineFeedCell
        timelineFeedCell.delegate = self
        
        let postModelInfo = arrayPostData[indexPath.item]
        timelineFeedCell.postModelInfo = postModelInfo
        
        
        timelineFeedCell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(sender:)), for: .touchUpInside) //add button action
        timelineFeedCell.likeButton.tag = indexPath.row
        
        // Change status.
        self.likeAndDislikeStatus(status: postModelInfo.like_flag == 1 ? true : false, sender: timelineFeedCell.likeButton)
        
        timelineFeedCell.commentButton.addTarget(self, action: #selector(self.commentButtonAction(sender:)), for: .touchUpInside) //add button action
        timelineFeedCell.commentButton.tag = indexPath.row
        
        return timelineFeedCell
        
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = Singleton.sharedInstance.calculateCellHeightByPostModelInfo(postModelInfo: arrayPostData[indexPath.item], frame: collectionView.frame, indexPath: indexPath)
        
        return cellSize // CGSize(width: view.frame.width, height: cellHeight)
        
    }
    

    // MARK: UICollectionViewDelegate
    
    // MARK: - Scroll View Delegate.
    //compute the scroll value and play witht the threshold to get desired effect
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let threshold = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        let triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold)
        
        if triggerThreshold < 3 {
            // self.reloadAPIByCount()
        }
        
    }

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
    
    
    

    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "seguePostTimeLine" {
            
            let destinationView: CreatePostController = segue.destination as! CreatePostController
            destinationView.postUploadAtType = PostUploadType.timelinePost
            
        } else if segue.identifier == "seguePostDetails" {
        
            let destinationView: TimelineDetailViewController = segue.destination as! TimelineDetailViewController
            destinationView.postModelInfo = sender as! ATimeLinePostInfoModel
            
        }
                
    }
 
    
    // MARK: - Button Like and DisLike status.
    
    internal func likeAndDislikeStatus(status: Bool, sender: UIButton) {
    
        if status {
        
            sender.isSelected = true
            sender.setTitle("liked", for: .normal)
            sender.setTitleColor(appColor.likedButton, for: .normal)
            
        } else {
        
            sender.isSelected = false
            sender.setTitle("like", for: .normal)
            sender.setTitleColor(appColor.likeButton, for: .normal)
            
        }
        
    }
    
    
    // MARK: - IBAction.
    // MARK: - Like Button Action
    
    func likeButtonAction(sender: UIButton!) {
        
        // write the task you want to perform on buttons click event..
        print("Liked")
        
        sender.isSelected = !sender.isSelected
        
        // Change Status.
        self.likeAndDislikeStatus(status: sender.isSelected, sender: sender)

        // Call Channel.
        let postModelInfo = arrayPostData[sender.tag]
        
        print(postModelInfo.content ?? "No Data Found")
        
        self.likeAndDislikeChannel(postModelInfo: postModelInfo, status: sender.isSelected)
        
    }
    
    func commentButtonAction(sender: UIButton!) {
        
        //write the task you want to perform on buttons click event..
        print("Comment")
        
        let postModelInfo = arrayPostData[sender.tag]
        self.performSegue(withIdentifier: "seguePostDetails", sender: postModelInfo)
        
    }
    
    // MARK: - Add Action Cable Subscribe Channels.
    
    internal func addActionCableSubscribeChannels() {
        
        // SubscribePostLikeChannel
        ActionCableClientSingleton.sharedInstance.subscribePostLikeChannel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSubscribePostLikeChannel), name: NSNotification.Name(rawValue: "reloadSubscribePostLikeChannelNotification"), object: nil)
        
        
        // SubscribePostCommentChannel
        ActionCableClientSingleton.sharedInstance.subscribePostCommentChannel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSubscribePostCommentChannel), name: NSNotification.Name(rawValue: "reloadSubscribePostCommentChannelNotification"), object: nil)
        
    }
    
    
    // MARK: - Like and Dislike Channel (Timeline Post)
    
    internal func likeAndDislikeChannel(postModelInfo: ATimeLinePostInfoModel, status: Bool) {
    
        // Channel name PostLike
        // param auth_token, status, post_id
        // Action timeline_post_like

        if ActionCableClientSingleton.sharedInstance.roomChannel_PostLike.isSubscribed {
        
            guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                return
            }
            
            let room_identifier = ["auth_token" : userInfoModel.authentication_token ?? "", "status": status == true ? 1 : 0, "post_id": "\(postModelInfo.id ?? 0)"] as [String : Any]
            print(room_identifier)
            
            ActionCableClientSingleton.sharedInstance.roomChannel_PostLike.action("timeline_post_like", with: room_identifier)
            
        }
        
    }
    
    
    // MARK: - reload Post Like Data.
    
    internal func reloadSubscribePostLikeChannel(notification: NSNotification) {

        if let json = notification.userInfo?["json"] as? Dictionary<String, AnyObject> {
        
            let responseCode =  json["responseCode"] as? Bool ?? false
            
            if responseCode == true {
                
                if let postObj = json["post_detail"] as? Dictionary<String, AnyObject> {
                    
                    if let timeLinePostInfoModel = Mapper<ATimeLinePostInfoModel>().map(JSONObject: postObj) {
                        
                        if self.arrayPostData.contains(where: { $0.id ==  timeLinePostInfoModel.id }) {
                            
                            _ = self.arrayPostData.index(where: { $0.id ==  timeLinePostInfoModel.id }).map({ (Index) in
                                
                                let timelinePostObj = self.arrayPostData[Index]
                                
                                timelinePostObj.like_flag = timeLinePostInfoModel.like_flag
                                timelinePostObj.like = timeLinePostInfoModel.like
                                
                                self.arrayPostData.remove(at: Index)
                                self.arrayPostData.insert(timelinePostObj, at: Index)
                                
                                self.collectionView!.reloadItems(at: [IndexPath(item: Index, section: 0)])
                                
                            })
                            
                        } else {
                            
                            print("post Like of dislike value not found.")
                            
                        }
                        
                        
                    }
                    
                }
                
                
            } else {
                
                print("respone code false")
                
            }
            
        }
        
    }
    
    
    // MARK: - reload Post Comment Data.
    
    internal func reloadSubscribePostCommentChannel(notification: NSNotification) {
        
        if let json = notification.userInfo?["json"] as? Dictionary<String, AnyObject> {
            
            let responseCode =  json["responseCode"] as? Bool ?? false
            
            if responseCode == true {
                
                if let postObj = json["post_detail"] as? Dictionary<String, AnyObject> {
                    
                    if let timeLinePostInfoModel = Mapper<ATimeLinePostInfoModel>().map(JSONObject: postObj) {
                        
                        if self.arrayPostData.contains(where: { $0.id ==  timeLinePostInfoModel.id }) {
                            
                            _ = self.arrayPostData.index(where: { $0.id ==  timeLinePostInfoModel.id }).map({ (Index) in
                                
                                let timelinePostObj = self.arrayPostData[Index]
                                
                                timelinePostObj.comment = timeLinePostInfoModel.comment
                                
                                self.arrayPostData.remove(at: Index)
                                self.arrayPostData.insert(timelinePostObj, at: Index)
                                self.collectionView!.reloadItems(at: [IndexPath(item: Index, section: 0)])
                                
                            })
                            
                        } else {
                            
                            print("post Like of dislike value not found.")
                            
                        }
                        
                        
                    }
                    
                }
                
            } else {
                
                print("respone code false")
                
            }
            
        }
        
    }
    
    
}



