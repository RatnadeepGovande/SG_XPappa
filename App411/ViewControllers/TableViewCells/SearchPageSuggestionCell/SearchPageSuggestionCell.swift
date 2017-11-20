//
//  SearchPageSuggestionCell.swift
//  App411
//
//  Created by osvinuser on 10/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class SearchPageSuggestionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var descriptionLabel : UILabel?
    @IBOutlet weak var avatarImage : DesignableImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
