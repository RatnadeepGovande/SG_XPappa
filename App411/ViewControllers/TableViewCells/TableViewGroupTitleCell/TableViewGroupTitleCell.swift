//
//  TableViewGroupTitleCell.swift
//  App411
//
//  Created by osvinuser on 7/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewGroupTitleCellDelegate {
    func clickGropImage()
}


class TableViewGroupTitleCell: UITableViewCell {

    @IBOutlet var textField_GroupText: UITextField!
    
    @IBOutlet var label_CharCount: UILabel!
    
    @IBOutlet var imageView_GroupIcon: DesignableImageView!
    
    
    var delegate: TableViewGroupTitleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - IBAction
    
    @IBAction func clickGroupImage(_ sender: Any) {
        delegate?.clickGropImage()
    }
    
}
