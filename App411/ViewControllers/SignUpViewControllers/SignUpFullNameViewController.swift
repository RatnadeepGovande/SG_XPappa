//
//  SignUpFullNameViewController.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class SignUpFullNameViewController: UIViewController {

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
    
        params["email"] = ""
        params["password"] = ""
        params["fullname"] = ""
        params["image"] = ""
        params["dob"] = ""
        
        self.buttonUnSelected()

    }
    
    // MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueFullName" {
            let viewController = segue.destination as! SignUpEmailViewController
            viewController.params = params
        }
                
    }
    

}

extension SignUpFullNameViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellTextFieldEnterText = tableView.dequeueReusableCell(withIdentifier: "TableViewCellTextFieldEnterText") as! TableViewCellTextFieldEnterText
        
        cell.textField_EnterData.placeholder = "Full Name"
        
        cell.textField_EnterData.delegate = self
        
        cell.textField_EnterData.tag = indexPath.section
        
        cell.textField_EnterData.text = params["fullname"]
        
        // cell.textField_EnterData.becomeFirstResponder()
        
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
        
        label_Title.text = "Hi. What's your name?"
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 22)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 80))
        
        label_Title.text = "Enter only Alphabets, Min 3 & Max 20 Characters."

        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
        
        label_Title.numberOfLines = 0
        
        label_Title.lineBreakMode = .byWordWrapping
        
        label_Title.sizeToFit()
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }
    
}

extension SignUpFullNameViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        params["fullname"] = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        
        let newString = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        let invalidCharSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
        let filtered: String = (string.components(separatedBy: invalidCharSet) as NSArray).componentsJoined(by: "")
        
        if string != filtered {
            return false
        }
        
        if newString.characters.count > 0 {
            
            if newString.characters.count >= 3 {
                self.buttonSelected()
            } else {
                self.buttonUnSelected()
            }
            
            if newString.characters.count <= 20 {
            
                return true
                
            } else {
            
                return false

            }
            
        } else {
            
            self.buttonUnSelected()
            return string == "" ? true : false
        } // end else.
        
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
