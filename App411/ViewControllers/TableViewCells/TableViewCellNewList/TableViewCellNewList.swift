//
//  TableViewCellNewList.swift
//  App411
//
//  Created by osvinuser on 10/10/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TableViewCellNewList: UITableViewCell {
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
