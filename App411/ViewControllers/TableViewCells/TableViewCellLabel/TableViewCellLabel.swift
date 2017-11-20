//
//  TableViewCellLabel.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TableViewCellLabel: UITableViewCell {

    @IBOutlet var label_Text: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
