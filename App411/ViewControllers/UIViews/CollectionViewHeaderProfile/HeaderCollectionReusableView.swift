//
//  HeaderCollectionReusableView.swift
//  App411
//
//  Created by osvinuser on 9/4/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol HeaderCollectionReusableViewDelegate {
    func clickOnSettingButtAction()
    func clickOnSubscribeButtonAction(_ sender: UIButton)
}

class HeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet var imageView_CoverImage: DesignableImageView!
    @IBOutlet var imageView_ProfileImage: DesignableImageView!
    @IBOutlet var label_Name: UILabel!
    @IBOutlet var label_Viewers: UILabel!
    

    @IBOutlet var settingButton: UIButton!
    @IBOutlet var subcribeButton: DesignableButton!
    

    var delegate: HeaderCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    // MARK: - IBAction
    @IBAction func SubcribeActionButton(_ sender: UIButton) {
        delegate?.clickOnSubscribeButtonAction(sender)
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        delegate?.clickOnSettingButtAction()
    }
}
