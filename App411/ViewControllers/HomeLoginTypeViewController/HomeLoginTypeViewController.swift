//
//  HomeLoginTypeViewController.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import ObjectMapper

class HomeLoginTypeViewController: UIViewController, LTMorphingLabelDelegate, ShowAlert {

    // private outlet
    @IBOutlet fileprivate var label_Welcome: LTMorphingLabel!
    @IBOutlet fileprivate var button_login: UIButton!
    @IBOutlet fileprivate var button_Facebook: UIButton!
    @IBOutlet fileprivate var button_SignUp: UIButton!
    
    
    /* Create array for text animation */
    fileprivate var i = -1
    fileprivate var textArray = [
        "Welcome to 411"
    ]
    
    fileprivate var text: String {
        i = i >= textArray.count - 1 ? 0 : i + 1
        return textArray[i]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true;

        label_Welcome.delegate = self
        
        self.setViewBackground()
        
        // Call All view animations.
        self.callUIAnimation()
        
    }
    
    /* UI view animations of button and text. */
    // MARK:- UI view animations.
    internal func callUIAnimation() {
        
        let deadlineTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.showLableAnimation()
        }
        
        button_login.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        button_Facebook.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        button_SignUp.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.button_login.transform = CGAffineTransform(scaleX: 1,y: 1)
            self.button_Facebook.transform = CGAffineTransform(scaleX: 1,y: 1)
            self.button_SignUp.alpha = 1.0
        }
        
    }
    
    internal func showLableAnimation() {
        
        if let effect = LTMorphingEffect(rawValue: 1) {
            label_Welcome.morphingEffect = effect
            label_Welcome.text = text
        }
    }
    
    

    //MARK:- IBActions.
    @IBAction func loginButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueLoginView", sender: self)
    }
    
    @IBAction func facebookButtonAction(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logIn([.email,.publicProfile], viewController: self) { loginResult in
            
            debugPrint("myResult", loginResult) // user to print data.
            
            self.getFBUserDataAPI() // Call facebook login api.
            
        }

    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "SegueSignUpFullNameView", sender: self)
    }
    

    //Mark:- Get Facebook Data.
    internal func getFBUserDataAPI() {
        
        // Show loader.
        Methods.sharedInstance.showLoader()
        
        let params = ["fields" : "email, name"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start { (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                // Hidden Loader.
                Methods.sharedInstance.hideLoader()
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    
                    // Hidden Loader.
                    print(responseDictionary)
                    
                    let fbName  = responseDictionary["name"]   as? String ?? ""
                    let fbEmail = responseDictionary["email"]  as? String ?? ""
                    let fbId    = responseDictionary["id"]     as? String ?? ""
                    
                    let profileURL = NSString(format:"https://graph.facebook.com/\(fbId)/picture?type=large" as NSString)
                    
                    print("\nFacebooId:- \(fbId)", "\nFacebooName:- \(fbName)", "\nFacebooEmail:- \(fbEmail)", "\nFacebooProfileURL:- \(profileURL)")
                    
                    if Reachability.isConnectedToNetwork() == true {
                        
                        let getLatitude: String = "\(appDelegateShared.userCurrentLocation.latitude)"
                        let getLongitude: String = "\(appDelegateShared.userCurrentLocation.longitude)"

                        let deviceToken: String = UserDefaults.standard.value(forKey: "device_token") as? String ?? ""
                        
                        self.userLoginWithFacebook(facebookId: fbId, fullName: fbName, dob: "", latitude: getLatitude, longitude: getLongitude, device_token: deviceToken)
                        
                    } else {
                        
                        Methods.sharedInstance.hideLoader()
                        self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                        
                    }
                    
                }
            }
        }
    }
    
    
    //MARK:- user login with facebook.
    internal func userLoginWithFacebook(facebookId: String, fullName: String, dob: String, latitude: String, longitude: String, device_token: String) {
        
    
        let paramsStr = "facebook_uid=\(facebookId)&fullname=\(fullName)&dob=\(dob)&latitute=\(latitude)&longitute=\(longitude)&device_token=\(device_token)"
        
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.facebookLogin, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            // Convet response to mapper object.
                            if let userInfoObj = Mapper<AUserInfoModel>().map(JSONObject: jsonResult["user"]) {
                                
                                if let JSONString = Mapper().toJSONString(userInfoObj, prettyPrint: true) {
                                    
                                    /* Save User info data in local */
                                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: JSONString)
                                    UserDefaults.standard.set(encodedData, forKey: "userinfo")
                                    
                                    /* Get User info data From local */
                                    let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
                                    let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
                                    
                                    print(userDataStr)
                                    
                                }
                                
                            }
                            
                            
                            if let filterInfoList = jsonResult["filter"] as? [Dictionary<String, AnyObject>] {
                                
                                Singleton.sharedInstance.filterSelectedListInfo.removeAll()
                                
                                for filterInfoObj in filterInfoList {
                                    if let filterInfoMapperObj = Mapper<ASelectedFiltersInfoModel>().map(JSONObject: filterInfoObj) {
                                        Singleton.sharedInstance.filterSelectedListInfo.append(filterInfoMapperObj)
                                    }
                                }
                                
                                UserDefaults.standard.set(filterInfoList, forKey: "selectedFilter")
                                
                            }
                            
                            
                            if let distance = jsonResult["distance"] as? String {
                                Singleton.sharedInstance.filterDistance = distance
                                UserDefaults.standard.set(distance, forKey: "selectedDistance")
                            }
                            
                            
                            
                            
                            
                            // Create login session.
                            UserDefaults.standard.set(true, forKey: "loginsession")
                            
                            self.performSegue(withIdentifier: "segueFacebook", sender: self)
                            
                            appDelegateShared.allocLayerClient()
                            
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

extension HomeLoginTypeViewController {
    
    func morphingDidStart(_ label: LTMorphingLabel) {
        
    }
    
    func morphingDidComplete(_ label: LTMorphingLabel) {
        
    }
    
    func morphingOnProgress(_ label: LTMorphingLabel, progress: Float) {
        
    }
    
}
