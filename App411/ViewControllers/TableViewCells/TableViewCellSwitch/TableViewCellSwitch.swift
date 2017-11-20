//
//  TableViewCellSwitch.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellSwitchDelegates {
    func changeSwitchButtonStatus(sender: UISwitch)
}


class TableViewCellSwitch: UITableViewCell {

    @IBOutlet var label_Text: UILabel!
    @IBOutlet var switch_ButtonOutlet: UISwitch!
    
    var delegate: TableViewCellSwitchDelegates?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchButtonClick(_ sender: UISwitch) {
        
        delegate?.changeSwitchButtonStatus(sender: sender)
        
    }
}
