//
//  HomeEventCollectionViewCell.swift
//  App411
//
//  Created by osvinuser on 6/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class HomeEventCollectionViewCell: UICollectionViewCell {

    @IBOutlet var view_Shadow: DesignableView!
    
    @IBOutlet var imageView_EventImage: DesignableImageView!
    @IBOutlet var groupImage: DesignableImageView!

    @IBOutlet var backgroundLabelView: DesignableView!
    
    @IBOutlet var label_EventData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
