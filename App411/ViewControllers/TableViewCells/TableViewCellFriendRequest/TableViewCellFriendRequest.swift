//
//  TableViewCellFriendRequest.swift
//  App411
//
//  Created by osvinuser on 7/13/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellFriendRequestDelegate {
    func acceptFriendRequest(tag: Int)
    func rejectFriendRequest(tag: Int)
}

class TableViewCellFriendRequest: UITableViewCell {

    @IBOutlet var imageView_image: DesignableImageView!
    
    @IBOutlet var label_Title: UILabel!
    
    @IBOutlet var label_description: UILabel!

    
    @IBOutlet var rejectFriendRequestButton: UIButton!
    
    @IBOutlet var acceptFriendRequestButton: UIButton!
    
    
    var delegate: TableViewCellFriendRequestDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- IBAction.
    @IBAction func acceptFriendRequest(_ sender: UIButton) {
        delegate?.acceptFriendRequest(tag: sender.tag)
    }
    
    @IBAction func rejectFriendRequest(_ sender: UIButton) {
        delegate?.rejectFriendRequest(tag: sender.tag)
    }
    
}
