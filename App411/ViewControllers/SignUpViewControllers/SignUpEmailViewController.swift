//
//  SignUpEmailViewController.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class SignUpEmailViewController: UIViewController, ShowAlert {

    // private outlet
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    @IBOutlet fileprivate var buttonNext: UIButton!

    
    var params = [String: String]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.resetViewProperties()
        
        self.setViewBackground()
        
        tableView_Main.register(UINib(nibName: "TableViewCellTextFieldEnterText", bundle: nil), forCellReuseIdentifier: "TableViewCellTextFieldEnterText")

    }
    
    // Mark:- Reset View Properties
    internal func resetViewProperties() {
        self.buttonUnSelected()
    }
    
    
    //MARK:- checkEmailIsExitOrNot
    internal func checkEmailIsExitOrNot() {
                
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "email=\(self.params["email"] ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.emailValidation, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                print(response )
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)

                        if responeCode == true {
                            
                            DispatchQueue.main.async(execute: {
                                self.buttonSelected()
                                Methods.sharedInstance.hideLoader()
                            })
                            
                        } else {
                            
                            DispatchQueue.main.async(execute: {
                                self.buttonUnSelected()
                                Methods.sharedInstance.hideLoader()
                            })
                            
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueEmail" {
            let viewController = segue.destination as! SignUpBirthdayViewController
            viewController.params = params
        }
    }

}

extension SignUpEmailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellTextFieldEnterText = tableView.dequeueReusableCell(withIdentifier: "TableViewCellTextFieldEnterText") as! TableViewCellTextFieldEnterText
        
        cell.textField_EnterData.placeholder = "Email"
        
        cell.textField_EnterData.delegate = self
        
        cell.textField_EnterData.tag = indexPath.section
        
        cell.textField_EnterData.text = params["email"]
        
        cell.textField_EnterData.becomeFirstResponder()

        cell.textField_EnterData.keyboardType = .emailAddress
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 80.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_Title.text = "What's your email?"
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 22)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 80))
        
        label_Title.text = "Enter valid e-mail. (e.g example@xyz.xom)"
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
        
        label_Title.numberOfLines = 0
        
        label_Title.lineBreakMode = .byWordWrapping
        
        label_Title.sizeToFit()
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
}

extension SignUpEmailViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        params["email"] = textField.text
        
        let emailString = textField.text ?? ""
//        if emailString.characters.count > 0, emailString.isValidEmail()
        if  emailString.length > 0, emailString.isValidEmail()
        {
                
            if Reachability.isConnectedToNetwork() == true {
                
                self.checkEmailIsExitOrNot()
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
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
            
            if !newString.isValidEmail() {
                self.buttonUnSelected()
            }
            
        } else {
            
            self.buttonUnSelected()

            return string == "" ? true : false
            
        } // end else.
        
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
