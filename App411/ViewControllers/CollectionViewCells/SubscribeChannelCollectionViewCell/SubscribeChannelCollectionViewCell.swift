//
//  SubscribeChannelCollectionViewCell.swift
//  App411
//
//  Created by osvinuser on 9/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol SubscribeChannelCollectionViewCellDelegate {
    func clickOnSubscribeOrUnSubscribeButton(_ sender: UIButton)
}

class SubscribeChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView_Channel: DesignableImageView!
    
    @IBOutlet var label_Title: UILabel!
    
    @IBOutlet var label_ViewerCount: UILabel!
    
    @IBOutlet var button_subscribe: DesignableButton!
    
    var delegate: SubscribeChannelCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func clickOnButtonSubscribe(_ sender: UIButton) {
        delegate?.clickOnSubscribeOrUnSubscribeButton(sender)
    }
}
