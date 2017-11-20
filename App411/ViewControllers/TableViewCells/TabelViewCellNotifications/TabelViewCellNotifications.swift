//
//  TabelViewCellNotifications.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TabelViewCellNotifications: UITableViewCell {

    @IBOutlet var imageView_Image: UIImageView!
    
    @IBOutlet var label_Text: ActiveLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
