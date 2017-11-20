//
//  ChannelPostImageCell.swift
//  App411
//
//  Created by osvinuser on 9/5/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import AVFoundation


protocol ChannelPostImageCellDelegate {
    func zoomImageAnimationWithTapGesture(postImageView: UIImageView)
    func playPostVideoWithTapGesture(playerItem: AVPlayerItem)
    func clickOnUserName(user: AUserInfoModel)
}


class ChannelPostImageCell: UICollectionViewCell {

    
    var postModelInfo: AEventPostInfoModel? {
        
        didSet {
            
            if let videoFlag = postModelInfo?.postVideoFlag {
                
                if videoFlag == 0 {
                    
                    let imageWidth = NumberFormatter().number(from: postModelInfo?.postImageWidth ?? "320")
                    let imageHeight = NumberFormatter().number(from: postModelInfo?.postImageHeight ?? "480")
                    
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
            if let profieImage = postModelInfo?.postUserDict?.image {
                profileImageView.sd_setImage(with: URL(string: profieImage), placeholderImage: nil)
            }
            
            
            // Set Name of user.
            // Post Name.
            if let name = postModelInfo?.postUserDict?.fullname {
                // Customize label text.
                nameLabel.customize { label in
                    self.updateLabelStatusValue(label: label, nameStr: name)
                }
                
            }
            
            
            // Post Content..
            if let statusText = postModelInfo?.postContent {
                statusTextView.text = statusText
            }
            
            
            if let videoFlag = postModelInfo?.postVideoFlag {
                
                // Flag 0 of image with test.
                // Flag 1 of video with test.
                // Flag 2 only of test.
                
                if videoFlag == 0 {
                    
                    // Set post image.
                    if let postImage = postModelInfo?.postImageURL {
                        self.downloadPostImageFromURL(postImage: postImage)
                    }
                    
                    imageViewPlay.isHidden = true

                    
                } else if videoFlag == 1 {
                    
                    // Set post image.
                    if let postImage = postModelInfo?.postImageThumbnail {
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
        
        if let upadateFormat  = postModelInfo?.postCreatedDate {
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
            
             if let userModel = self.postModelInfo?.postUserDict {
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
    var delegate: ChannelPostImageCellDelegate?
    
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
    
    
    func zoomImageViewTapGesture(_ sender: UITapGestureRecognizer) {
        
        print("Add Zoom Image View")
        
        print(postModelInfo ?? "No object found.")
        
        if let videoFlag = postModelInfo?.postVideoFlag {
            
            // Flag 0 of image with test.
            // Flag 1 of video with test.
            // Flag 2 only of test.
            
            if videoFlag == 0 {
                
                // Using for image
                delegate?.zoomImageAnimationWithTapGesture(postImageView: postImageView)
                
            } else if videoFlag == 1 {
                
                if let videoStrURL = postModelInfo?.postImageURL {
                    
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
        
        addContraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        addContraintsWithFormat(format: "H:|-4-[v0]-4-|", views: statusTextView)
        addContraintsWithFormat(format: "H:|[v0]|", views: postImageView)
        
        addContraintsWithFormat(format: "V:|-12-[v0]", views: nameLabel)
        addContraintsWithFormat(format: "V:|-8-[v0(44)]-4-[v1]-4-[v2(0)]-8-|", views: profileImageView, statusTextView, postImageView)
        
        
        
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

extension UIView {
    
    func addContraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary  = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
    
}

