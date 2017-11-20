//
//  ForgotPasswordViewController.swift
//  App411
//
//  Created by osvinuser on 7/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, ShowAlert {

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

    
    //MARK:- IBAction.
    @IBAction func sendForgotPassword(_ sender: Any) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.sendEmailForForgotPassword()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    // Mark:- Reset View Properties
    internal func resetViewProperties() {
        self.buttonUnSelected()
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

extension ForgotPasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        label_Title.text = "Forgot Password?"
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 22)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_TitleEmail: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 30))
        
        label_TitleEmail.text = "Enter valid e-mail. (e.g example@xyz.xom)"
        
        label_TitleEmail.textColor = UIColor.darkGray
        
        label_TitleEmail.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
        
        hearderView.addSubview(label_TitleEmail)
        
        
        let label_TitleMsg: UILabel = UILabel(frame: CGRect(x: 15, y: 30, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_TitleMsg.text = "Please enter your registered email. We will send you a password on email shortly."
        
        label_TitleMsg.textColor = UIColor.darkGray
        
        label_TitleMsg.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
        
        label_TitleMsg.numberOfLines = 0
        
        label_TitleMsg.lineBreakMode = .byWordWrapping
        
        hearderView.addSubview(label_TitleMsg)
        
        
        return hearderView
        
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        params["email"] = textField.text
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if newString.characters.count > 0 {
            
            if newString.isValidEmail() {
                self.buttonSelected()
            } else {
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
