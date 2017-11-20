//
//  UIViewCreatedEventSuccessfullyVIew.swift
//  App411
//
//  Created by osvinuser on 8/2/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol UIViewCreatedEventSuccessfullyVIewDelegate {
    func inviteFriendsAction(eventInfoMapperObj: ACreateEventInfoModel)
    func crossInviteAction()
}

class UIViewCreatedEventSuccessfullyVIew: UIView {

    var delegate: UIViewCreatedEventSuccessfullyVIewDelegate?
    var eventInfoMapperObj: ACreateEventInfoModel!
    @IBOutlet var nameLabel: ActiveLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "UIViewCreatedEventSuccessfullyVIew", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        
    }

    // MARK: - IBAction
    @IBAction func crossButtonAction(_ sender: Any) {
        delegate?.crossInviteAction()

        self.removeFromSuperview()
    }
    
    @IBAction func inviteFriendsButtonAction(_ sender: Any) {
        delegate?.inviteFriendsAction(eventInfoMapperObj: eventInfoMapperObj)
        self.removeFromSuperview()
    }
    
}
