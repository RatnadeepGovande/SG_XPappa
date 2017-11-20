//
//  GMSMarkerLocationView.swift
//  WaitrRater
//
//  Created by osvinuser on 2/8/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class GMSMarkerLocationView: UIView {
    
    @IBOutlet var imageView_MakerIcon: UIImageView!
    
    @IBOutlet var imageView_MakerImage: DesignableImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        loadViewFromNib ()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        loadViewFromNib ()
        
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "GMSMarkerLocationView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        
    }

}
