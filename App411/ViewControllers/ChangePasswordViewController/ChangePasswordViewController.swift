//
//  ChangePasswordViewController.swift
//  App411
//
//  Created by osvinuser on 7/7/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper

class ChangePasswordViewController: UIViewController, ShowAlert {

    @IBOutlet fileprivate var textField_OldPassword: UITextField!
    @IBOutlet fileprivate var textField_NewPassword: UITextField!
    @IBOutlet fileprivate var textField_ReenterNewPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    //MARK:- IBAction
    @IBAction func changePasswordAction(_ sender: Any) {
        
        if self.textFieldValidation() == true {
            
            if Reachability.isConnectedToNetwork() == true {
                
                self.changePasswordAPI()
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            } // end else
            
        } // end if
        
    }
    
    
    //MARK:- Text Field Validations.
    internal func textFieldValidation() -> Bool {
        
        if textField_OldPassword.text?.isEmpty == true && textField_NewPassword.text?.isEmpty == true && textField_ReenterNewPassword.text?.isEmpty == true {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.AllFields_Message)
            
            return false
            
        } else {
            
            if textField_OldPassword.text?.isEmpty == true || (textField_OldPassword.text?.characters.count)! < 6 {
            
                self.showAlert("Old Password " + AKErrorHandler.CommonErrorMessages.Blank_Fields + " and " + AKErrorHandler.CommonErrorMessages.Password_Valid)
                return false

                
            } else if textField_NewPassword.text?.isEmpty == true || (textField_NewPassword.text?.characters.count)! < 6 {
            
                self.showAlert("New Password " + AKErrorHandler.CommonErrorMessages.Blank_Fields + " and " + AKErrorHandler.CommonErrorMessages.Password_Valid)
                return false
                
            } else if textField_ReenterNewPassword.text?.isEmpty == true || (textField_ReenterNewPassword.text?.characters.count)! < 6 {
            
                self.showAlert("Re-enter Password " + AKErrorHandler.CommonErrorMessages.Blank_Fields + " and " + AKErrorHandler.CommonErrorMessages.Password_Valid)
                return false
                
            } else if textField_ReenterNewPassword.text != textField_NewPassword.text  {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.Fields_Same)
                return false
                
            }
            
        }
        
        return true

    }
    
    
    //MARK:- change Password API.
    internal func changePasswordAPI() {
    
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&current_password=\(textField_OldPassword.text ?? "")&new_password=\(textField_NewPassword.text ?? "")&password_confirm=\(textField_ReenterNewPassword.text ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.resetPassword, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            // Get Old User data.
                            let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                            let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                            
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
                                
                                // Update auth token.
                                userInfoObj.authentication_token = jsonResult["auth_token"] as? String ?? ""
                                
                                // create json string.
                                if let JSONString = Mapper().toJSONString(userInfoObj, prettyPrint: true) {
                                    
                                    // save new user data.
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                    UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                    
                                    // get user data.
                                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                                    
                                    print(userDataStr)
                                    
                                }
                                
                            }
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            })
                            
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
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

extension ChangePasswordViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            
            /* Set statment block */
            
        } else {
            
            return string == "" ? true : false
            
        } // end else.
        
        return true
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}



