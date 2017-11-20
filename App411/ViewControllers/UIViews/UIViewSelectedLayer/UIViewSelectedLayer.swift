//
//  UIViewSelectedLayer.swift
//  App411
//
//  Created by osvinuser on 7/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class UIViewSelectedLayer: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        self.backgroundColor =  appColor.selectedLayerColor
        self.alpha = 0.50
        
        
        let imageView_tick = UIImageView(frame: self.frame)
        imageView_tick.image = #imageLiteral(resourceName: "TickImage")
        imageView_tick.contentMode = .center
        self.addSubview(imageView_tick)

    }
    

}
