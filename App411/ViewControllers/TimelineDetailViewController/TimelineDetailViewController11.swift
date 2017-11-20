//
//  TimelineDetailViewController.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

private let reuseIdentifierPostDetails = "CellPostDetail"
private let reuseIdentifierPostComment = "CellPostComment"


class TimelineDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ShowAlert {

    @IBOutlet var view_TypingView: UIView!

    @IBOutlet var textView_Comment: DesignableTextView!
    
    
    
    var postModelInfo: ATimeLinePostInfoModel!
    
    var refreshControl: UIRefreshControl!
    
    var array_Comments = [ATimeLineCommentInfoModel]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.collectionView!.alwaysBounceVertical = true
        
        self.collectionView!.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifierPostDetails)
        self.collectionView!.register(TimelineCommentCell.self, forCellWithReuseIdentifier: reuseIdentifierPostComment)
        self.collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")

        // Do any additional setup after loading the view.
        
        // self.refreshControlAPI()
        
        // Add refresh controller
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)

        textView_Comment.frame = CGRect(x: 0, y: self.view.frame.size.h, width: self.view.frame.size.width, height: 50)
        self.view.addSubview(textView_Comment)
        textView_Comment.inputAccessoryView = view_TypingView
        //textView_Comment.becomeFirstResponder()
        
    }

    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - refresh control For API
    internal func refreshControlAPI() -> UIRefreshControl {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        return refreshControl
        // First time automatically refreshing.
//         self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
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
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return section == 0 ? 1 : array_Comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierPostDetails, for: indexPath)
            
            cell.backgroundColor = UIColor.white
            
            // Remove subview
            for subView in cell.contentView.subviews {
                subView.removeFromSuperview()
            }
            
            
            // Configure the cell

            let viewFrame: CGRect = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
            
            let feedView = TimelineFeedView(postModelInfo: postModelInfo, frame: viewFrame)
            
            feedView.tag = indexPath.row
            
            feedView.postModelInfo = postModelInfo
            
            cell.contentView.addSubview(feedView)
            
            
            feedView.likeButton.addTarget(self, action: #selector(self.likeButtonAction(sender:)), for: .touchUpInside) //add button action
            feedView.likeButton.tag = indexPath.section
            
            feedView.commentButton.addTarget(self, action: #selector(self.commentButtonAction(sender:)), for: .touchUpInside) //add button action
            feedView.commentButton.tag = indexPath.section
            
            return cell
            
        } else {
        
            let cell: TimelineCommentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierPostComment, for: indexPath) as! TimelineCommentCell
            
            cell.backgroundColor = UIColor.white
            
            // array_Comments
            
            return cell
        
        }
        
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
        
            let cellSize = Singleton.sharedInstance.calculateCellHeightByPostModelInfo(postModelInfo: postModelInfo, frame: collectionView.frame, indexPath: indexPath)
            
            return cellSize // CGSize(width: view.frame.width, height: cellHeight)
            
        } else {
        
            
//            let staticHeight: CGFloat =  8 + 44 + 4 + 4 + 24 + 8 + 0.5 + 8 + 40 + 16
//            
//            var cellSize: CGSize = CGSize(width: frame.size.width, height: staticHeight)
//            
//            if let statusText = postModelInfo.content {
//                
//                let textheight = statusText.height(withConstrainedWidth: frame.size.width-16, font: UIFont.systemFont(ofSize: 14))
//                
//                cellSize.height += textheight
//                
//            }
            
            // let cellSize = Singleton.sharedInstance.calculateCellHeightByPostModelInfo(postModelInfo: postModelInfo, frame: collectionView.frame, indexPath: indexPath)
            
            return  CGSize(width: view.frame.width, height: 100)
            
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
    
    
    
    /*
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //description is a String variable defined in the class
        let size:CGSize = (description as NSString).boundingRectWithSize(CGSizeMake(CGRectGetWidth(collectionView.bounds) - 20.0, 180.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 16.0)], context: nil).size
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), ceil(size.height))
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
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
                assert(false, "Unexpected element kind")
            
        }
        
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
    // MARK: - Like Button Action
    
    func likeButtonAction(sender: UIButton!) {
        
        //write the task you want to perform on buttons click event..
        print("Liked")
        
        sender.isSelected = !sender.isSelected
        // self.likeAndDislikeChannel(postModelInfo: postModelInfo, status: sender.isSelected)
        
    }
    
    func commentButtonAction(sender: UIButton!) {
        
        //write the task you want to perform on buttons click event..
        print("Comment")
        
    }

    @IBAction func postCommentAction(_ sender: Any) {
        
        
    }
}
