//
//  GMSMarkerInforWindow.swift
//  WaitrRater
//
//  Created by osvinuser on 2/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol GMSMarkerInforWindowDelegate {
    
    func goingActionDelegate(_ sender: UIButton, eventInfoModel: ACreateEventInfoModel)
    func previewActionDelegate(_ sender: UIButton, eventInfoModel: ACreateEventInfoModel)
    func favouriteActionDelegate(_ sender: UIButton, eventInfoModel: ACreateEventInfoModel)
    
}

class GMSMarkerInforWindow: UIView {
    
    // Outlet
    @IBOutlet var imageView_EventImage: DesignableImageView!
    
    @IBOutlet var label_EventName: UILabel!
    
    @IBOutlet var label_EventTime: UILabel!
    
    @IBOutlet var button_favourite: UIButton!
    @IBOutlet var donateButton: UIButton!
    @IBOutlet var previewButton: UIButton!

    var delegate:GMSMarkerInforWindowDelegate!
    
    var eventInfoModel : ACreateEventInfoModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "GMSMarkerInforWindow", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        
    }
    
    
    // MARK: - IBAction.
    
    @IBAction func buttonGoingAction(_ sender: UIButton) {
        self.delegate.goingActionDelegate(sender, eventInfoModel:eventInfoModel)
    }
    
    @IBAction func buttonPreviewAction(_ sender: UIButton) {
        self.delegate.previewActionDelegate(sender, eventInfoModel:eventInfoModel)
        
    }
    
    @IBAction func buttonFavouriteAction(_ sender: UIButton) {
        self.delegate.favouriteActionDelegate(sender, eventInfoModel:eventInfoModel)
    }
    
}
