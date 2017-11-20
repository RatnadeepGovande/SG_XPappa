//
//  AlertHelper.swift
//  ApkaApnaBazar
//
//  Created by osvinuser on 29/06/16.
//  Copyright © 2016 Swati. All rights reserved.
//

import Foundation
import UIKit

// MARK :
// MARK : Alert
protocol ShowAlert {}

extension ShowAlert where Self: UIViewController
{
    func showAlert(_ message: String)
    {
        let alertController = UIAlertController(title: Constants.appTitle.alertTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion:nil)
        
    }
    
    func showAlertWithActions(_ message:String) {
        
        let alertController = UIAlertController(title: Constants.appTitle.alertTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        { action -> Void in
            
            _ = self.navigationController?.popViewController(animated: true)

        })
        present(alertController, animated: true, completion:nil)
    }
    
    
    func showAlertWithActionsMoveToRootView(_ message:String) {
        
        let alertController = UIAlertController(title: Constants.appTitle.alertTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        { action -> Void in
            
            _ = self.navigationController?.popToRootViewController(animated: false)
            
        })
        present(alertController, animated: true, completion:nil)
    }
    
    func  showAlertWithTwoActions(_message:String) {
        
        
        let alertController = UIAlertController(title: Constants.appTitle.alertTitle, message: _message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        { action -> Void in
            
            _ = self.navigationController?.popViewController(animated: true)
            
        })
        present(alertController, animated: true, completion:nil)
        
    }
    
    
}
