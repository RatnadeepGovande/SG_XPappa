//
//  CustomCardView.swift
//  App411
//
//  Created by osvinuser on 6/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class CustomCardView: UIView {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleOfEventLabel: UILabel!
    @IBOutlet var saveEventButton: UIButton!
    @IBOutlet var eventImage: DesignableImageView!
    @IBOutlet var imageBackgroundView: DesignableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "CustomCardView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        
    }
    
    @IBAction func saveEventAction(_ sender: UIButton) {
        //self.delegate?.saveEventClick(sender:sender)
    }
    
}
