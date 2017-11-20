//
//  TimelineCommentCell.swift
//  App411
//
//  Created by osvinuser on 8/9/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TimelineCommentCell: UICollectionViewCell {
    
    
    // Set Model Data.
    var commentModelInfo: ATimeLineCommentInfoModel? {
        
        didSet {
            
            var statusString = ""
            
            // Post Name.
            if let name = commentModelInfo?.user?.fullname {
                statusString = name
            }
            
            let attributedText = NSMutableAttributedString(string: statusString, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])

            
            // Post Profile Image
            if let profieImage = commentModelInfo?.user?.image {
                profileImageView.sd_setImage(with: URL(string: profieImage), placeholderImage: nil)
            }
            
            
            // Post Status.
            if let statusText = commentModelInfo?.content {
                attributedText.append(NSAttributedString(string: "\n" + statusText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.black]))
            }
            
            
            if let upadateFormat  = commentModelInfo?.updated_at {
                if let date = Singleton.sharedInstance.getDateFormatterFromServer(stringDate: upadateFormat) {
                    attributedText.append(NSAttributedString(string: "\n" + date.timeAgo, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor(red: 151/255, green: 161/255, blue: 171/255, alpha: 1.0)]))

                }
            }
            
            nameLabel.attributedText = attributedText
            
        }
        
    }
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(code: ) has not be implemented")
    }
    
    
    // Name Label
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 14)
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
    
    /* Setup Sub Views */
    func setupViews() {
        
        backgroundColor = UIColor.white
        
        addSubview(nameLabel)
        addSubview(profileImageView)

        // H
        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        
        // V
        addConstraintsWithFormat(format: "V:|-8-[v0(44)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-|", views: nameLabel)

    }
    
    
}
