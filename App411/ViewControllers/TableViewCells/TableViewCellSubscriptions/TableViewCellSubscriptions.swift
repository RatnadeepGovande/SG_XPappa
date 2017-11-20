//
//  TableViewCellSubscriptions.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellSubscriptionsDelegate {
    func clickOnSubscribeButton(_ sender: Any)
}

class TableViewCellSubscriptions: UITableViewCell {

    @IBOutlet var imageView_Channel: DesignableImageView!
    
    @IBOutlet var label_Title: UILabel!
    
    @IBOutlet var label_ViewerCount: UILabel!
    
    @IBOutlet var button_subscribe: DesignableButton!
    
    var delegate: TableViewCellSubscriptionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    @IBAction func clickOnButtonSubscribe(_ sender: Any) {
        delegate?.clickOnSubscribeButton(sender)
    }
    
    
}
