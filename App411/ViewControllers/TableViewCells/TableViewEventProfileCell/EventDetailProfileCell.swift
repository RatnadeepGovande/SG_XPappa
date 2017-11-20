//
//  EventDetailProfileCell.swift
//  App411
//
//  Created by osvinuser on 7/27/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol EventDetailProfileCellDelegate {
    func clickOnActions(buttonTag:Int)
}

class EventDetailProfileCell: UITableViewCell {

    @IBOutlet var eventTitle: UILabel!
    @IBOutlet var eventSaveButton: UIButton!
    @IBOutlet var eventViewLbl: UILabel!
    @IBOutlet var eventImageButton: UIButton!
    @IBOutlet var eventImage: DesignableImageView!
    @IBOutlet var designView: DesignableView!
    
    var delegate :EventDetailProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Event Actions
    
    @IBAction func eventActions(_ sender: UIButton) {
        self.delegate?.clickOnActions(buttonTag: sender.tag)
    }
    
}
