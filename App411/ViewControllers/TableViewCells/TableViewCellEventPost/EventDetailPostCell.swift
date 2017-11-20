//
//  EventDetailPostCell.swift
//  App411
//
//  Created by osvinuser on 7/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol EventDetailPostCellDelegate {
    func isLikedAction(_ sender: UIButton)
}

class EventDetailPostCell: UITableViewCell {

    @IBOutlet var imageView_Image: DesignableImageView!
    
    @IBOutlet var postImage: DesignableImageView!
    @IBOutlet var label_Text: ActiveLabel!
    @IBOutlet var label_name: ActiveLabel!
    
    @IBOutlet var postImageConstraint: NSLayoutConstraint!
    @IBOutlet var likeButton: DesignableButton!

    var delegate :EventDetailPostCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func clickOnLikeButton(_ sender: UIButton) {
        self.delegate?.isLikedAction(sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
