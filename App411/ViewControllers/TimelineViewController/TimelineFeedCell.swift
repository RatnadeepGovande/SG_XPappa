//
//  TimelineFeedCell.swift
//  App411
//
//  Created by osvinuser on 9/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import AVFoundation


protocol TimelineFeedCellDelegate {
    func zoomImageAnimationWithTapGesture(postImageView: UIImageView)
    func playPostVideoWithTapGesture(playerItem: AVPlayerItem)
    func clickOnUserName(user: AUserInfoModel)
}


class TimelineFeedCell: UICollectionViewCell {

    var postModelInfo: ATimeLinePostInfoModel? {
        
        didSet {
            
            if let videoFlag = postModelInfo?.video_flag {
                
                if videoFlag == 0 {
                    
                    let imageWidth = NumberFormatter().number(from: postModelInfo?.image_width ?? "320")
                    let imageHeight = NumberFormatter().number(from: postModelInfo?.image_height ?? "480")
                    
                    var imageViewHeight = Singleton.sharedInstance.calculateImageViewSize(imageW: imageWidth as! CGFloat, imageH: imageHeight as! CGFloat, cellW: frame.size.width)
                    imageViewHeight -= 16
                    
                    // Get all contraints
                    for constraint in self.constraints {
                        
                        // Get Height of imageView.
                        if constraint.firstItem as? UIImageView == postImageView && constraint.firstAttribute == NSLayoutAttribute.height {
                            
                            // Update imageView contraints
                            let constraintUpdate = constraint
                            constraintUpdate.constant = imageViewHeight
                            
                        }
                        
                    }
                    
                } else if videoFlag == 1 {
                    
                    for constraint in self.constraints {
                        
                        if constraint.firstItem as? UIImageView == postImageView && constraint.firstAttribute == NSLayoutAttribute.height {
                            let constraintUpdate = constraint
                            constraintUpdate.constant = 300
                        } else if constraint.firstItem as? UIImageView == imageViewPlay && constraint.firstAttribute == NSLayoutAttribute.centerX {
                            let constraintUpdate = constraint
                            constraintUpdate.constant = 0
                        } else if constraint.firstItem as? UIImageView == imageViewPlay && constraint.firstAttribute == NSLayoutAttribute.centerY {
                            let constraintUpdate = constraint
                            constraintUpdate.constant = 0
                        }
                        
                    }
                    
                    
                } else {
                    
                    for constraint in self.constraints {
                        
                        if constraint.firstItem as? UIImageView == postImageView && constraint.firstAttribute == NSLayoutAttribute.height {
                            let constraintUpdate = constraint
                            constraintUpdate.constant = 0
                        }
                        
                    }
                    
                }
                
            }
            
            self.layoutIfNeeded()
            
            
            
            
            // Set Profile image on user.
            if let profieImage = postModelInfo?.user?.image {
                profileImageView.sd_setImage(with: URL(string: profieImage), placeholderImage: nil)
            }
            
            
            // Set Name of user.
            // Post Name.
            if let name = postModelInfo?.user?.fullname {
                // Customize label text.
                nameLabel.customize { label in
                    self.updateLabelStatusValue(label: label, nameStr: name)
                }
                
            }
            
            
            // Post Content..
            if let statusText = postModelInfo?.content {
                statusTextView.text = statusText
            }
            
            
            var likesAndComment = ""
            if let like = postModelInfo?.like {
                likesAndComment = like > 1 ? "\(like) likes " : "\(like) like "
            }
            
            if let comment = postModelInfo?.comment {
                likesAndComment += comment > 1 ? " \(comment) Comments" : " \(comment) Comment"
            }
            
            likesCommentsLabel.text = likesAndComment
            
            
            if let videoFlag = postModelInfo?.video_flag {
                
                // Flag 0 of image with test.
                // Flag 1 of video with test.
                // Flag 2 only of test.
                
                if videoFlag == 0 {
                    
                    // Set post image.
                    if let postImage = postModelInfo?.image_url {
                        self.downloadPostImageFromURL(postImage: postImage)
                    }
                    
                    imageViewPlay.isHidden = true
                    
                } else if videoFlag == 1 {
                    
                    // Set post image.
                    if let postImage = postModelInfo?.thumbnail {
                        self.downloadPostImageFromURL(postImage: postImage)
                    }
                    
                    imageViewPlay.isHidden = false
                    
                } else if videoFlag == 2 {
                
                    imageViewPlay.isHidden = true

                    
                }
                
            }
            
            
        }
        
    }
    
    
    // MARK: - update Status label values.
    
    internal func updateLabelStatusValue(label: ActiveLabel, nameStr: String) {
        
        var subString: String!
        
        if let upadateFormat  = postModelInfo?.updated_at {
            if let date = Singleton.sharedInstance.getDateFormatterFromServer(stringDate: upadateFormat) {
                let trimmedString = nameStr.replacingOccurrences(of: " ", with: "")
                subString = trimmedString + "\n" + date.timeAgo
                
            }
        }
        
        label.text = "@" + subString
        label.numberOfLines = 2
        
        //label.textColor = UIColor.black
        label.mentionColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 12)
        
        label.highlightFontName = FontNameConstants.SourceSansProSemiBold
        label.highlightFontSize = 16
        
        label.minimumLineHeight = 10
        
        label.handleMentionTap {_ in
            
            print("Mention")
            
            if let userModel = self.postModelInfo?.user {
                self.delegate?.clickOnUserName(user: userModel)
            }
 
        }
        
    }
    
    
    // load image from URL.
    
    internal func downloadPostImageFromURL(postImage: String) {
        
        URLSession.shared.dataTask(with: URL(string: postImage)!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print("error found!")
                return
            }
            
            let image = UIImage(data: data!)
            DispatchQueue.main.async {
                self.postImageView.image = image
            }
            
        }).resume()
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(code: ) has not be implemented")
    }
    
    // Create Delegate.
    var delegate: TimelineFeedCellDelegate?
    
    // Name Label
    let nameLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 2
        label.textColor = UIColor(red: 151/255, green: 161/255, blue: 171/255, alpha: 1.0)
        return label
    }()
    
    
    // Profile Imageview
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius =  22
        return imageView
    }()
    
    
    // Status TextView
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    
    // Post ImageView
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let imageViewPlay: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "ic_play")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    // Likes Comments Lable
    let likesCommentsLabel: UILabel = {
        let likesCommentsLabel = UILabel()
        likesCommentsLabel.font = UIFont.systemFont(ofSize: 12)
        likesCommentsLabel.textColor = UIColor.darkGray
        return likesCommentsLabel
    }()
    
    
    // Line View
    let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 225/255, green: 228/255, blue: 232/255, alpha: 1.0)
        return lineView
    }()
    
    
    // Button Like
    let likeButton = TimelineFeedCell.buttonForTitle(title: "like", image:  #imageLiteral(resourceName: "Like_icon"), selectedImage: #imageLiteral(resourceName: "ic_Liked"))
    let commentButton = TimelineFeedCell.buttonForTitle(title: "Comment", image: #imageLiteral(resourceName: "commet_icon"), selectedImage: #imageLiteral(resourceName: "commet_icon"))
    
    // Create Button By Title and Image.
    static func buttonForTitle(title: String, image: UIImage, selectedImage: UIImage) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(appColor.likeButton, for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        button.setImage(image, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }
    
    
    func zoomImageViewTapGesture(_ sender: UITapGestureRecognizer) {
        
        print("Add Zoom Image View")
        
        print(postModelInfo ?? "No object found.")
        
        if let videoFlag = postModelInfo?.video_flag {
            
            // Flag 0 of image with test.
            // Flag 1 of video with test.
            // Flag 2 only of test.
            
            if videoFlag == 0 {
                
                // Using for image
                delegate?.zoomImageAnimationWithTapGesture(postImageView: postImageView)
                
            } else if videoFlag == 1 {
                
                if let videoStrURL = postModelInfo?.image_url {
                    
                    if  let videoURL = URL(string: videoStrURL) {
                        
                        // Using for video
                        delegate?.playPostVideoWithTapGesture(playerItem: AVPlayerItem(url: videoURL))
                        
                    }
                    
                }
                
            } else if videoFlag == 2 {
                // Gesture not working on Text post.
                
            }
            
        }
        
        
    }

    
    // Setup views.
    
    func setupViews() {
        
        backgroundColor = UIColor.white
        
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(statusTextView)
        addSubview(postImageView)
        addSubview(imageViewPlay)
        
        addSubview(likesCommentsLabel)
        addSubview(lineView)
        
        addSubview(likeButton)
        addSubview(commentButton)
        
        // H
        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: statusTextView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: postImageView)
        addConstraintsWithFormat(format: "H:|-12-[v0]|", views: likesCommentsLabel)
        addConstraintsWithFormat(format: "H:|[v0]|", views: lineView)
        addConstraintsWithFormat(format: "H:|[v0(v1)][v1]|", views: likeButton, commentButton)
        
        // V
        addConstraintsWithFormat(format: "V:|-6-[v0]", views: nameLabel)
        addConstraintsWithFormat(format: "V:[v0(44)]|", views: commentButton)
        addConstraintsWithFormat(format: "V:|-8-[v0(44)]-4-[v1]-4-[v2(0.1)]-8-[v3(24)]-8-[v4(0.5)]-8-[v5(40)]|", views: profileImageView, statusTextView, postImageView, likesCommentsLabel, lineView, likeButton)
        
        
        
        
        let centerHorizontally = NSLayoutConstraint(item: imageViewPlay,
                                                    attribute: .centerX,
                                                    relatedBy: .equal,
                                                    toItem: postImageView,
                                                    attribute: .centerX,
                                                    multiplier: 1.0,
                                                    constant: 30.0)
        
        let centerVertically = NSLayoutConstraint(item: imageViewPlay,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: postImageView,
                                                    attribute: .centerY,
                                                    multiplier: 1.0,
                                                    constant: 30.0)
        
        
        addConstraint(centerHorizontally)
        addConstraint(centerVertically)
        
        
        
        // Add Gesture for zoom view.
        postImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.zoomImageViewTapGesture(_:))))
        postImageView.tag = self.tag
        
    }

}
