//
//  GroupChatCollectionViewCell.swift
//  App411
//
//  Created by osvinuser on 7/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol GroupChatCollectionViewCellDelegate {
    func clickOnCrossButtonClick(sender: UIButton)
}

class GroupChatCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView_Profile: DesignableImageView!
    
    @IBOutlet var label_Text: UILabel!
    
    @IBOutlet var crossButtonClick: UIButton!
    
    var delegate: GroupChatCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func crossButtonClick(_ sender: UIButton) {
        delegate?.clickOnCrossButtonClick(sender: sender)
    }
}
