//
//  SignUpPasswordViewController.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class SignUpPasswordViewController: UIViewController, ShowAlert {

    // private outlet
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    @IBOutlet var buttonNext: UIButton!

    var params = [String: String]()
    
    var textFieldPassword = UITextField()
    var strOTP: String = ""
    
    
    var signUpVerifyView = UIViewSignUPVerificationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.resetViewProperties()
        
        self.setViewBackground()
        
        tableView_Main.register(UINib(nibName: "TableViewCellTextFieldEnterText", bundle: nil), forCellReuseIdentifier: "TableViewCellTextFieldEnterText")
        
        print(params)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                signUpVerifyView.constraintYOTP.constant = 0.0
            } else {
                signUpVerifyView.constraintYOTP.constant -= ((endFrame?.size.height ?? 0.0) - 100)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    
    // Mark:- Reset View Properties
    func resetViewProperties() {
        self.buttonUnSelected()
    }
    
    @IBAction func SigUpButtonAction(_ sender: Any) {
        
        self.checkLocationServicesStatus()
        
    }
    
    func checkLocationServicesStatus() {
    
        if UserDefaults.standard.bool(forKey: "isuserlocationget") {
            
            if Reachability.isConnectedToNetwork() == true {
                self.callSignUpAPI()
            } else {
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }
            
        } else {
        
            if CLLocationManager.locationServicesEnabled() {
                
                switch(CLLocationManager.authorizationStatus()) {
                    
                    case .notDetermined, .restricted, .denied:
                        print("No access")
                        self.showPopIfLocationServiceIsDisable()
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                        appDelegateShared.locationManager.startUpdatingLocation()
                        self.getLocationData()
                }
                
            } else {
                
                print("Location services are not enabled")
                
            }
            
        }
        
    }
    
    func getLocationData() {
    
        let deadlineTime = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            
            if appDelegateShared.userCurrentLocation != nil {
                
                if Reachability.isConnectedToNetwork() == true {
                    
                    self.callSignUpAPI()
                    
                } else {
                    
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    
                }
                
            }
            
        }

    }

    

    
    

    
    
    //MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignUpPasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellTextFieldEnterText = tableView.dequeueReusableCell(withIdentifier: "TableViewCellTextFieldEnterText") as! TableViewCellTextFieldEnterText
        
        cell.textField_EnterData.placeholder = "Password"
        
        cell.textField_EnterData.delegate = self
        
        cell.textField_EnterData.tag = indexPath.section
        
        cell.textField_EnterData.isSecureTextEntry =  true
        
        textFieldPassword = cell.textField_EnterData
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0;
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 100.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
            
            label_Title.text = "You will need a password"
            
            label_Title.textColor = UIColor.darkGray
            
            label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 22)
            
            hearderView.addSubview(label_Title)
            
            return hearderView
            
        } else {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear

        
        let label_ErroeMsg: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_ErroeMsg.text = "Make sure it's 8 characters or more with atleats 1 Uppercase Alphabet, 1 Number & 1 Special Character."
        
        label_ErroeMsg.textColor = UIColor.darkGray
        
        label_ErroeMsg.numberOfLines = 0
        
        label_ErroeMsg.lineBreakMode = .byWordWrapping
        
        label_ErroeMsg.sizeToFit()
        
        label_ErroeMsg.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
        
        hearderView.addSubview(label_ErroeMsg)

        
        
        let label_Title: ActiveLabel = ActiveLabel(frame: CGRect(x: 15, y: label_ErroeMsg.frame.size.height, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        let customTypeTS = ActiveType.custom(pattern: "Terms of service") //Looks for "are"
        let customTypePP = ActiveType.custom(pattern: "Privacy Policy") //Looks for "are"

        label_Title.enabledTypes.append(customTypeTS)
        label_Title.enabledTypes.append(customTypePP)

        label_Title.textColor = UIColor.darkGray
        
        label_Title.text = "By siging up, you agree  to the Terms of service and Privacy Policy."
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 13)
        
        label_Title.customize { label in
            
            label.text = "By siging up, you agree  to the Terms of service and Privacy Policy."
            label.numberOfLines = 0
            
            //Custom types
            label.customColor[customTypeTS] = appColor.hyperURLLikeColor
            label.customColor[customTypePP] = appColor.hyperURLLikeColor
            
            label_Title.handleCustomTap(for: customTypeTS, handler: { (String) in
                print("Tap On Terms of service \(String)")
                //print(String)
                Methods.sharedInstance.openURL(url: URL(string: "http://xyphr.herokuapp.com/term_condition")!)
            })
            
            label_Title.handleCustomTap(for: customTypePP, handler: { (String) in
                print("Tap On Privacy Policy \(String)")
               //print(String)
                Methods.sharedInstance.openURL(url: URL(string: "http://xyphr.herokuapp.com/privacy_policy")!)
            })
        }
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
}

extension SignUpPasswordViewController: UITextFieldDelegate {
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textFieldPassword == textField {
            params["password"] = textField.text
        } else {
            strOTP = textField.text!
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            
            if textFieldPassword == textField {
                
                if newString.characters.count >= 8 {
                    
                    if newString.isPasswordValid() {
                        self.buttonSelected()
                    } else {
                        self.buttonUnSelected()
                    }
                    
                } else {
                    self.buttonUnSelected()
                }

            } else {
            
                strOTP = newString
                if newString.characters.count > 6 {
                  return false
                }
                
            }
            
        } else {
            
            strOTP = ""
            self.buttonUnSelected()
            
            return string == "" ? true : false
    
        } 
        
        return true
        
    }
    
    internal func buttonSelected() {
        buttonNext.isUserInteractionEnabled = true
        buttonNext.backgroundColor = appColor.appButtonSelectedColor
    }
    
    internal func buttonUnSelected() {
        buttonNext.isUserInteractionEnabled = false
        buttonNext.backgroundColor = appColor.appButtonUnSelectedColor
    }
    
}

extension SignUpPasswordViewController: UIViewSignUPVerificationViewDelegate {

    func sendOTPButtonAction() {
    
        if strOTP.isEmpty {
            self.showAlert(AKErrorHandler.CommonErrorMessages.Enter_OTP)
        } else {
        
            if Reachability.isConnectedToNetwork() == true {
                self.sendOTPForVerification()
            } else {
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }
            
        }
        
    }
    
    func resendOTPOnEmail() {
    
        if Reachability.isConnectedToNetwork() == true {
            
            self.resendOTPToUserOnEmail()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
}

