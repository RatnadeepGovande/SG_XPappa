//
//  TableViewButtonCell.swift
//  App411
//
//  Created by osvinuser on 8/10/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewButtonCellDelegate {
    func clickOnAction(_ sender: UIButton)
}

class TableViewButtonCell: UITableViewCell {

    @IBOutlet var addButton: UIButton!
    @IBOutlet var makeHost: UIButton!

    var delegate :TableViewButtonCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func clickonButton(_ sender : UIButton) {
    
        self.delegate?.clickOnAction(sender)
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
