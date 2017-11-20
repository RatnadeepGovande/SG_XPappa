//
//  TableViewCellSignUpProfilePic.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellSignUpProfilePicDelegate {

    func uploadProfilePicClick(sender: UIButton)
    
}

class TableViewCellSignUpProfilePic: UITableViewCell {

    var delegate: TableViewCellSignUpProfilePicDelegate?
    
    @IBOutlet var imageView_Images: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func uploadProfilePicButton(_ sender: UIButton) {
        delegate?.uploadProfilePicClick(sender: sender)
    }
    
}
