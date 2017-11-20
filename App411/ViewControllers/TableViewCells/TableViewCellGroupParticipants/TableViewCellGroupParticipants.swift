//
//  TableViewCellGroupParticipants.swift
//  App411
//
//  Created by osvinuser on 8/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TableViewCellGroupParticipants: UITableViewCell {

    @IBOutlet var imageView_Profile: UIImageView!
    
    @IBOutlet var label_Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
}
