//
//  UIViewIllustration.swift
//  App411
//
//  Created by osvinuser on 7/13/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class UIViewIllustration: UIView {

    @IBOutlet var label_Text: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "UIViewIllustration", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
        self.addSubview(view);
        
    }

}
