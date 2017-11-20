//
//  TableViewCellFriendList.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TableViewCellFriendList: UITableViewCell {

    @IBOutlet var imageView_image: DesignableImageView!
    
    @IBOutlet var label_Title: UILabel!
    
    @IBOutlet var label_description: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
