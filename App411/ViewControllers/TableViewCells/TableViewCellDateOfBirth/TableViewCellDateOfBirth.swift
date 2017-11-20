//
//  TableViewCellDateOfBirth.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellDateOfBirthDelegate {
    func getDateFromDatePicker(sender: UIDatePicker)
}

class TableViewCellDateOfBirth: UITableViewCell {

    @IBOutlet var datePick_Birthday: UIDatePicker!
    
    var delegate: TableViewCellDateOfBirthDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- UIDatePicker Value Change Action.
    @IBAction func getDateFromDatePicker(_ sender: UIDatePicker) {
        delegate?.getDateFromDatePicker(sender: sender)
    }
    
}
