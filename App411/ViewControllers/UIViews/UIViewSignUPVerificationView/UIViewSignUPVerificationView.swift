//
//  UIViewSignUPVerificationView.swift
//  App411
//
//  Created by osvinuser on 6/29/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol UIViewSignUPVerificationViewDelegate {
    func sendOTPButtonAction()
    func resendOTPOnEmail()
}

class UIViewSignUPVerificationView: UIView, UITextFieldDelegate {
    
    var delegate: UIViewSignUPVerificationViewDelegate?
    
    @IBOutlet var textField_Verification: UITextField!
    
    @IBOutlet var constraintYOTP: NSLayoutConstraint!
    
    @IBOutlet var label_ShowVerfiyMsg: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        
        let view = UINib(nibName: "UIViewSignUPVerificationView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view);
        
    }

    //MARK:- IBAction.
    @IBAction func clickOnCrossButton(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func sendButtonClick(_ sender: Any) {
        delegate?.sendOTPButtonAction()
    }
    
    @IBAction func resetOTPAtEmail(_ sender: Any) {
        delegate?.resendOTPOnEmail()
    }
    
}
