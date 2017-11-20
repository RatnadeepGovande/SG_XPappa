//
//  SaveCardViewController.swift
//  411Demo
//
//  Created by osvinuser on 9/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import Braintree

class SaveCardViewController: UIViewController, ShowAlert {

    @IBOutlet var amountTextField : DesignableTextField!
    @IBOutlet var nameTextField : DesignableTextField!
    @IBOutlet var cardNmTextField : DesignableTextField!
    @IBOutlet var expiryDateTextField : DesignableTextField!
    @IBOutlet var cvvTextField : DesignableTextField!
    @IBOutlet var main_scrollView: UIScrollView!
    @IBOutlet var showName: UIButton!

    var tokenStringForPayment = String()
    var eventModelData : ACreateEventInfoModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Transaction"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
        
        self.addToolBarFor(textField: self.amountTextField)
        self.addToolBarFor(textField: self.nameTextField)
        self.addToolBarFor(textField: self.cardNmTextField)
        self.addToolBarFor(textField: self.expiryDateTextField)
        self.addToolBarFor(textField: self.cvvTextField)


    }
    
    override func donePressed() {
        
        main_scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)

        view.endEditing(true)
    }
    
    
    override func addToolBarFor(textField: UITextField) {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = appColor.appTabbarSelectedColor
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.donePressed))
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([/*cancelButton,*/ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.inputAccessoryView = toolBar
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.getTokenFromServer()
            
        } else {
            // Refresh end.
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        main_scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    //MARK:- IBActions
    
    @IBAction func showYourName(_ sender : UIButton) {
        
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func proceedToDonateClothes(_ sender : UIButton) {
        
        self.performSegue(withIdentifier: "donateClothes", sender: self)

    }
    
    
    @IBAction func makeDonation(_ sender : UIButton) {
        
        print("press on Donation Button")
        
        if amountTextField.text?.characters.count == 0 {
            
            self.showAlert("Please enter amount for donation")
            
        } else if nameTextField.text?.characters.count == 0 {
            
            self.showAlert("Please enter name.")

        } else if cardNmTextField.text?.characters.count == 0 {
            
            self.showAlert("Please enter card number.")

        } else if expiryDateTextField.text?.characters.count == 0 {
            
            self.showAlert("Please enter expiry date.")
            
        } else if cvvTextField.text?.characters.count == 0 {
            
            self.showAlert("Please enter cvv.")

        } else {
            
            // Hit Donation
            if Reachability.isConnectedToNetwork() == true {
                
                self.generateNonceFromBrainTreeSdk()
                
            } else {
                // Refresh end.
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }

            
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            let destinationVC = segue.destination as! DonateClothesViewController
            destinationVC.eventModelData = eventModelData
            destinationVC.donationType = 2
            
    }
 

}


extension SaveCardViewController {
    
    internal func generateNonceFromBrainTreeSdk() {
        
        Methods.sharedInstance.showLoader()
        
        let expMonth: UInt = UInt(expiryDateTextField.text!.components(separatedBy: "/")[0])!
        let expYear: UInt = UInt(expiryDateTextField.text!.components(separatedBy: "/")[1])!
        
        let braintreeClient = BTAPIClient(authorization: tokenStringForPayment)!
        let cardClient = BTCardClient(apiClient: braintreeClient)
        let card = BTCard(number: cardNmTextField.text ?? "", expirationMonth: String(expMonth), expirationYear: String(expYear), cvv: nil)
        cardClient.tokenizeCard(card) { (tokenizedCard, error) in
            // Communicate the tokenizedCard.nonce to your server, or handle error
            
            if error == nil {
                
                print(tokenizedCard?.nonce ?? "")
                
                // Hit Donation
                if Reachability.isConnectedToNetwork() == true {
                    
                    self.sendPaymentToOurServer(nononceCode: tokenizedCard?.nonce ?? "")
                    
                } else {
                    // Refresh end.
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()

                self.showAlert(error?.localizedDescription ?? "")
 
            }
            
        }
        
    }
    
    internal func getTokenFromServer() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,user_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.getTokenPayment, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        self.tokenStringForPayment = jsonResult["client_token"] as? String ?? ""
                        
                    } else {
                        
                        self.showAlert("Your Token is not generated by the server. Please try again")
                    }
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
    }
    
    internal func sendPaymentToOurServer(nononceCode: String) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }

        //auth_token,user_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&amount=\(amountTextField.text!)&event_id=\(eventModelData.id ?? 0)&payment_method_nonce=\(nononceCode)&donation_type=\(0)&show_user=\(showName.isSelected == true ? 1 : 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.sendPaymentTo411Server, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()

            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        self.showAlert(jsonResult["message"] as? String ?? "")

                        DispatchQueue.main.async(execute: {
                            self.navigationController?.popToRootViewController(animated: false)
                        })

                        
                    } else {
                        
                        self.showAlert("Your Token is not generated by the server. Please try again")
                    }
                }
                
            } else {
                
                self.showAlert(errorMsg)
            }
        }
    }
}

extension SaveCardViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nameTextField {
            main_scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - textField.frame.size.height), animated: true)
            
        } else if textField == cardNmTextField {
            main_scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - textField.frame.size.height + 50), animated: true)
            
        } else if textField == expiryDateTextField {
            main_scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - textField.frame.size.height + 50), animated: true)
            
        } else if textField == cvvTextField {
            main_scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - textField.frame.size.height + 50), animated: true)
            
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            cardNmTextField.becomeFirstResponder()
            
        } else if textField == cardNmTextField {
            expiryDateTextField.becomeFirstResponder()
            
        } else if textField == expiryDateTextField {
            cvvTextField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
            main_scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
        return true
        
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSet = NSCharacterSet(charactersIn: "0123456789")
        var enterString = string
        
        enterString = enterString.replacingOccurrences(of: " ", with: "")
        enterString = enterString.replacingOccurrences(of: "/", with: "")
        
        if (enterString as NSString).rangeOfCharacter(from: characterSet.inverted).location != NSNotFound {
            return false
        }
        
        if textField == cardNmTextField {
            
            var text: String = textField.text!
            text = (text as NSString).replacingCharacters(in: range, with: string)
            text = text.replacingOccurrences(of: " ", with: "")
            var newString: String = ""
            while text.characters.count > 0 {
                let subString: String? = (text as NSString).substring(to: min(text.characters.count, 4))
                newString = newString + (subString!)
                if (subString?.characters.count ?? 0) == 4 {
                    newString = newString + (" ")
                }
                text = (text as NSString).substring(from: min(text.characters.count, 4))
            }
            newString = newString.trimmingCharacters(in: characterSet.inverted)
            if newString.characters.count >= 20 {
                return false
            }
            textField.text = newString
            
            return false
            
        } else if textField == expiryDateTextField {
            
            var text: String = textField.text!
            text = (text as NSString).replacingCharacters(in: range, with: string)
            text = text.replacingOccurrences(of: "/", with: "")
            var newString: String = ""
            while (text.characters.count ) > 0 {
                let subString: String? = (text as NSString).substring(to: min((text.characters.count ), 2))
                newString = newString + (subString)!
                if (subString!.characters.count ) == 2 {
                    newString = newString + ("/")
                }
                text = (text as NSString).substring(from: min(text.characters.count , 2))
            }
            newString = newString.trimmingCharacters(in: characterSet.inverted)
            
            print("\(newString)")
            if newString.characters.count > 6 {
                return false
            }
            textField.text = newString
            
            return false
            
        } else {
            
            return string == "" ? true : textField.text!.characters.count < 3 ? true : false;
            
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == cardNmTextField {
            
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            
             if (trimmedString?.characters.count)! < 19 {
                
                self.showAlert("Please enter a valid Card Number.")

            }
            
        } else if textField == expiryDateTextField {
            
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            
             if (trimmedString?.characters.count)! < 5 {
                
                self.showAlert("Please enter a valid Expiry Date.")
            }
            
        } else {
            
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            
           if (trimmedString?.characters.count)! < 3 {
                
                self.showAlert("Please enter a valid Cvv Number.")

            }
            
        }
        
    }
    
    
}
