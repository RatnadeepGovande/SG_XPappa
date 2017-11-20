//
//  BlockedTableViewCell.swift
//  App411
//
//  Created by osvinuser on 8/17/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol BlockedTableViewCellDelegate {
    func unblockAction(_ indexPathOfRow: Int)
}

class BlockedTableViewCell: UITableViewCell {
    
    // IBOutlet.
    @IBOutlet var avatarImage: DesignableImageView!
    
    @IBOutlet var nameLabel: ActiveLabel!
    
    @IBOutlet var removeButton: DesignableButton!
    
    
    var delegate: BlockedTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func clickonButton(_ sender : UIButton) {
        self.delegate?.unblockAction(sender.tag)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
