//
//  TableViewCellChannelHeader.swift
//  App411
//
//  Created by osvinuser on 8/23/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit


class TableViewCellChannelHeader: UITableViewCell {
    
    @IBOutlet var avatarImage : DesignableImageView!
    @IBOutlet var coverImage : DesignableImageView!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var descriptionLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
