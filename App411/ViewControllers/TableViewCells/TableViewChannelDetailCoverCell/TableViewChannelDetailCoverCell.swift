//
//  TableViewChannelDetailCoverCell.swift
//  App411
//
//  Created by osvinuser on 8/23/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewChannelDetailCoverCellDelegate {
    
    func imageButtonMethod(_ sender : UIButton)
}

class TableViewChannelDetailCoverCell: UITableViewCell {

    @IBOutlet var avatarImage : DesignableImageView!
    
    @IBOutlet var coverImage : DesignableImageView!
    
    
    var delegate : TableViewChannelDetailCoverCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func clickonImageButton(_ sender : UIButton) {
        
        self.delegate?.imageButtonMethod(sender)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
