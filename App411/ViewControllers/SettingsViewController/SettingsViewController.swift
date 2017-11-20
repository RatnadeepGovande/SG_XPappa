//
//  SettingsViewController.swift
//  App411
//
//  Created by osvinuser on 6/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper

class SettingsViewController: UIViewController, ShowAlert {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    var array_TableOptions = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            print(userInfoModel.facebook_uid ?? "not found")
            
            let faceBookID = userInfoModel.facebook_uid ?? ""
            
            if faceBookID.isEmpty {
                
                array_TableOptions +=  ["Push Notifications", "Change Password", "View Terms & Conditions", "Privacy Policy"]
            } else {
                array_TableOptions +=  ["Push Notifications", "View Terms & Conditions", "Privacy Policy"]
            }
            
        }
        
        tableView_Main.register(UINib(nibName: "TableViewCellSwitch", bundle: nil), forCellReuseIdentifier: "TableViewCellSwitch")
        tableView_Main.register(UINib(nibName: "TableViewCellDetailsOption", bundle: nil), forCellReuseIdentifier: "TableViewCellDetailsOption")

        self.setViewBackground()
        
    }

    
    
    
    // MARK:- Did Receive Memory Warning.
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return array_TableOptions.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        
            let cell:TableViewCellSwitch = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSwitch") as! TableViewCellSwitch
            
            cell.label_Text.text = array_TableOptions[indexPath.section]
            
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            return cell
            
        } else {
        
            let cell:TableViewCellDetailsOption = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDetailsOption") as! TableViewCellDetailsOption
            
            cell.label_Text.text = array_TableOptions[indexPath.section]
            
            cell.selectionStyle = .none
            
            return cell
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         if indexPath.section == 1 {
            
            if array_TableOptions.count == 4 {
                
                self.performSegue(withIdentifier: "SegueChangePassword", sender: self)

            } else {
                
                Methods.sharedInstance.openURL(url: URL(string: "http://xyphr.herokuapp.com/term_condition")!)

            }
            
        } else if indexPath.section == 2 {
            
            if array_TableOptions.count == 4 {
                
                Methods.sharedInstance.openURL(url: URL(string: "http://xyphr.herokuapp.com/term_condition")!)
                
            } else {
                
                Methods.sharedInstance.openURL(url: URL(string: "http://xyphr.herokuapp.com/privacy_policy")!)
                
            }
        } else {
        
            Methods.sharedInstance.openURL(url: URL(string: "http://xyphr.herokuapp.com/privacy_policy")!)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == array_TableOptions.count - 1 ? 50.0 : 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == array_TableOptions.count - 1 {
        
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            let label_Title: ActiveLabel = ActiveLabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 50))
            
            let customType = ActiveType.custom(pattern: "Log out")
            
            label_Title.enabledTypes.append(customType)
            
            label_Title.textColor = appColor.appTabbarSelectedColor
            
            label_Title.textAlignment = .center
            
            label_Title.text = "Log out"
            
            label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 16)
            
            label_Title.customColor[customType] =  appColor.appTabbarSelectedColor
            
            label_Title.handleCustomTap(for: customType, handler: { (String) in
                
                print("Log out")
                
                if Reachability.isConnectedToNetwork() == true {
                    
                    self.logoutUserSession()
                    
                } else {
                    
                    self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                    
                }
                
            })
            
            hearderView.addSubview(label_Title)
            
            return hearderView
            
        } else {
        
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        }

    }
    
    
    //MARK:-  Push Notification Enable/Disable
    internal func pushNotificationStatus(notificationStatus: Bool) {
    
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&notification_status=\(notificationStatus)"
        print(paramsStr)

        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.pushNotificationStatus, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        // Update auth token.
                        userInfoModel.authentication_token = jsonResult["auth_token"] as? String ?? ""
                        
                        // create json string.
                        if let JSONString = Mapper().toJSONString(userInfoModel, prettyPrint: true) {
                            
                            // save new user data.
                            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                            UserDefaults.standard.set(encodedData, forKey: "userinfo")
                            
                        }
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        self.showAlert(jsonResult["message"] as? String ?? "")
                    })
                    
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    
    //MARK:- logout user (session API)
    internal func logoutUserSession() {
    
        Methods.sharedInstance.showLoader()
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_id=\(userInfoModel.id ?? 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.signoutUser, method: "Delete", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            Methods.sharedInstance.userlogout()
                            
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
    
    
}

extension SettingsViewController: TableViewCellSwitchDelegates {

    func changeSwitchButtonStatus(sender: UISwitch) {
        
        print(sender.isOn)
        
        self.pushNotificationStatus(notificationStatus: sender.isOn ? true : false)
        
    }
    
}
