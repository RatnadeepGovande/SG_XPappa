//
//  TimelineDetailViewController.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ActionCableClient
import ObjectMapper
import AVFoundation
import AVKit


private let reuseIdentifierPostDetails = "CellPostDetail"
private let reuseIdentifierPostComment = "CellPostComment"


class TimelineDetailViewController: UIViewController, ShowAlert {

    
    @IBOutlet var view_TypingView: UIView!
    @IBOutlet var textView_Comment: DesignableTextView!
    @IBOutlet var collectionView_Main: UICollectionView!
    @IBOutlet var sendCommentButton: UIButton!
    @IBOutlet var constraintOfHeight: NSLayoutConstraint!
    @IBOutlet var buttomLayoutConstraint: NSLayoutConstraint!
    
    
    var postModelInfo: ATimeLinePostInfoModel!
    var refreshControl: UIRefreshControl!
    var array_Comments = [ATimeLineCommentInfoModel]()
    
    
    
    
    // MARK: - Black Background view
    var blackBackgroundView = UIView()
    var staticPostImageView = UIImageView()
    var zoomImageView = UIImageView()
    var navBarView = UIView()
    var tabBarView = UIView()

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.collectionView_Main.alwaysBounceVertical = true
        
        sendCommentButton.isEnabled = false
        
        
        self.collectionView_Main.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // Register cell classes
        self.collectionView_Main.register(TimelineFeedCell.self, forCellWithReuseIdentifier: reuseIdentifierPostDetails)
        self.collectionView_Main.register(TimelineCommentCell.self, forCellWithReuseIdentifier: reuseIdentifierPostComment)
        self.collectionView_Main.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView_Main.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        
        // Do any additional setup after loading the view.
        
        // self.refreshControlAPI()
        
        // Add refresh controller
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
    
        
        // KeyBoard Notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
        textView_Comment.becomeFirstResponder()
        
        
        // Add Action Cable Subscribe Channels
        self.addActionCableSubscribeChannels()
        
    }

    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.buttomLayoutConstraint?.constant = 0.0
            } else {
                self.buttomLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            
            UIView.animate(withDuration: duration, delay: TimeInterval(0),  options: animationCurve,  animations: {
                
                if self.collectionView_Main.contentOffset.y+self.collectionView_Main.bounds.height <= self.collectionView_Main.contentSize.height {
                    self.tableViewScrollToBottom(animated: true, milliseconds: 300)
                }
 
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
        
    }
    
    
    // MARK: - refresh control For API
    internal func refreshControlAPI() -> UIRefreshControl {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        return refreshControl
    }
    
    
    // MARK: - Reload API
    func reloadAPI() {
        
        // Check network connection.
        if Reachability.isConnectedToNetwork() == true {
            
            let postId: String = String(postModelInfo.id ?? 0)
            
            // call Friend list API.
            self.getTimePostDetailDataFromAPI(post_id: postId)
            
        } else {
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    
    
    // MARK: - IBAction.
    // MARK: - Like Button Action
    
    func likeButtonAction(sender: UIButton!) {
        
        //write the task you want to perform on buttons click event..
        print("Liked")
        
        sender.isSelected = !sender.isSelected
        
        // Change Status.
        self.likeAndDislikeStatus(status: sender.isSelected, sender: sender)
        
        // channel like and dislike.
        self.likeAndDislikeChannel(postModelInfo: postModelInfo, status: sender.isSelected)
        
    }
    
    func commentButtonAction(sender: UIButton!) {
        
        //write the task you want to perform on buttons click event..
        print("Comment")
        
        textView_Comment.becomeFirstResponder()
        
    }
    
    @IBAction func postCommentAction(_ sender: Any) {
        
        // channel comment.
        self.postCommentChannel(postModelInfo: postModelInfo, content: textView_Comment.text)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
                        
                        postModelInfo.like_flag = timeLinePostInfoModel.like_flag
                        postModelInfo.like = timeLinePostInfoModel.like
                        self.collectionView_Main.reloadItems(at: [IndexPath(item: 0, section: 0)])
                        
                    }
                    
                }
                
            } else {
                
                print("respone code false")
                
            }
            
        }
    
    }
    
    
    
    // MARK: - Comment Channel (Timeline Post)
    
    internal func postCommentChannel(postModelInfo: ATimeLinePostInfoModel, content: String) {
        
        // Channel name PostLike
        // param auth_token, status, post_id
        // Action timeline_post_like
        
        if ActionCableClientSingleton.sharedInstance.roomChannel_PostComment.isSubscribed {
            
            guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                return
            }
            
            let room_identifier = ["auth_token" : userInfoModel.authentication_token ?? "", "content": content, "post_id": postModelInfo.id ?? 0] as [String : Any]
            print(room_identifier)
            
            ActionCableClientSingleton.sharedInstance.roomChannel_PostComment.action("timeline_post_comment", with: room_identifier)

            // update Text View Layout
            textView_Comment.text = ""
            sendCommentButton.isEnabled = false

            self.view.endEditing(true)
            
            self.constraintOfHeight.constant = 50
            UIView.animate(withDuration: 0.25, animations: {
                if self.collectionView_Main.contentOffset.y+self.collectionView_Main.bounds.height <= self.collectionView_Main.contentSize.height {
                    self.tableViewScrollToBottom(animated: true, milliseconds: 300)
                }
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
    }
    
    
    // MARK: - reload Post Comment Data.
    
    internal func reloadSubscribePostCommentChannel(notification: NSNotification) {
        
        if let json = notification.userInfo?["json"] as? Dictionary<String, AnyObject> {
            
            let responseCode =  json["responseCode"] as? Bool ?? false
            
            if responseCode == true {
                
                self.array_Comments.removeAll()
                
                if let postObj = json["post_detail"] as? Dictionary<String, AnyObject> {
                    
                    if let timeLinePostInfoModel = Mapper<ATimeLinePostInfoModel>().map(JSONObject: postObj) {
                        postModelInfo.comment = timeLinePostInfoModel.comment
                    }

                    if let commentList = json["post_detail"]?["comment_list"] as? [Dictionary<String, AnyObject>] {
                        
                        for commentInfoObj in commentList {
                            if let commentInfoModel = Mapper<ATimeLineCommentInfoModel>().map(JSONObject: commentInfoObj) {
                                self.array_Comments.append(commentInfoModel)
                            }
                            
                        }
                        
                    }
                    
                }
                
                self.collectionView_Main.reloadData()
                
            } else {
                
                print("respone code false")
                
            }
            
        }
        
    }
    
}


extension TimelineDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, TimelineFeedCellDelegate {

    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return section == 0 ? 1 : array_Comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierPostDetails, for: indexPath) as! TimelineFeedCell
            
            cell.delegate = self
            
            cell.postModelInfo = postModelInfo
            
            
            cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(sender:)), for: .touchUpInside) //add button action
            cell.likeButton.tag = indexPath.section
            
            // Change status.
            self.likeAndDislikeStatus(status: postModelInfo.like_flag == 1 ? true : false, sender: cell.likeButton)
            
            cell.commentButton.addTarget(self, action: #selector(self.commentButtonAction(sender:)), for: .touchUpInside) //add button action
            cell.commentButton.tag = indexPath.section
            
            return cell
            
        } else {
            
            let cell: TimelineCommentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierPostComment, for: indexPath) as! TimelineCommentCell
            
            cell.backgroundColor = UIColor.white
            
            cell.commentModelInfo = array_Comments[indexPath.item]
            
            return cell
            
        }
        
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            let cellSize = Singleton.sharedInstance.calculateCellHeightByPostModelInfo(postModelInfo: postModelInfo, frame: collectionView.frame, indexPath: indexPath)
            
            return cellSize
            
        } else {
            
            
            let staticHeight: CGFloat =  8 + 16 + 8 + 16

            var cellSize: CGSize = CGSize(width: collectionView.frame.size.width, height: staticHeight)

            let commentInfoModel: ATimeLineCommentInfoModel = array_Comments[indexPath.item]
            
            if let statusText = commentInfoModel.content {

                let textheight = statusText.height(withConstrainedWidth: collectionView.frame.size.width - 60, font: UIFont.systemFont(ofSize: 14))
                
                cellSize.height += textheight

            }
            
            return  cellSize
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            
            return CGSize(width: collectionView.frame.size.width, height: 0.1)
            
        } else {
            
            return CGSize(width: collectionView.frame.size.width, height: 0.3)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if section == 0 {
            
            return CGSize(width: collectionView.frame.size.width, height: 0.1)
            
        } else {
            
            return CGSize(width: collectionView.frame.size.width, height: 10.0)
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
            case UICollectionElementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
                
                headerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                
                return headerView
                
            case UICollectionElementKindSectionFooter:
                
                if indexPath.section == 0 {
                    
                    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                    
                    footerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                    
                    return footerView
                    
                } else {
                    
                    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                    
                    footerView.backgroundColor = UIColor.clear
                    
                    return footerView
                    
                }
                
            default:
                fatalError("Unexpected element kind")
            
        }
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    
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
        
        // update Text View Layout
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            if self.collectionView_Main.contentOffset.y+self.collectionView_Main.bounds.height <= self.collectionView_Main.contentSize.height {
                self.tableViewScrollToBottom(animated: true, milliseconds: 300)
            }
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        
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


extension TimelineDetailViewController: UITextViewDelegate {

    //MARK:- UITextView Delegate.
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let screenBounds = UIScreen.main.bounds
        let maxTextViewHeight = screenBounds.size.height - (self.buttomLayoutConstraint.constant + 164)
        
        if maxTextViewHeight > 50 + (newSize.height - ((textView.font?.lineHeight)! * 2)) {
            
            UIView.animate(withDuration:  0.25, animations: {
                
                if newSize.height - (textView.font?.lineHeight)! > 20 {
                    
                    self.constraintOfHeight.constant = 50 + (newSize.height - ((textView.font?.lineHeight)! * 2))
                    
                    DispatchQueue.main.async(execute: {
                        textView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    })
                    
                } else {
                    
                    textView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    self.constraintOfHeight.constant = 50
                    
                }
                
            }, completion: { (finish) in
                
                DispatchQueue.main.async(execute: {
                    if self.array_Comments.count > 0 {
                        let lastItemIndex = IndexPath(row: self.array_Comments.count-1, section: 1)
                        self.collectionView_Main.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
                    } // end if
                })
                
                
            })
            
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let messagetext = ((textView.text ?? "") as NSString).replacingCharacters(in: range, with: text)
        let newString = messagetext.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            sendCommentButton.isEnabled = true
        } else {
            
            sendCommentButton.isEnabled = false
            return text == "" ? true : false
            
        } // end else.
        
        return true
        
    }
    
    
    //MARK:- TableView Set To bottom
    func tableViewScrollToBottom(animated: Bool, milliseconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            let numberOfSections = self.collectionView_Main.numberOfSections
            let numberOfRows = self.collectionView_Main.numberOfItems(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let item = self.collectionView(self.collectionView_Main, numberOfItemsInSection: 0) - 1
                let lastItemIndex = IndexPath(row: item, section: 1)
                self.collectionView_Main.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
            } // end if
        } // end diapatch
    }
    
}
