//
//  DonateClothesViewController.swift
//  411Demo
//
//  Created by osvinuser on 9/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class DonateClothesViewController: UIViewController, ShowAlert {

    var isShowUserInf : Bool = false
    var donationType : Int = 0
    var eventModelData : ACreateEventInfoModel!

    @IBOutlet var textView : UITextView!
    @IBOutlet var showName: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = donationType == 1 ? "Food" : donationType == 2 ? "Clothes" : "Others"
        
        textView.text = self.eventModelData.causeAddress

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- IBActions
    
    @IBAction func showYourName(_ sender : UIButton) {
        
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func makeDonation(_ sender : UIButton) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.sendPaymentToOurServer()
            
        } else {
            // Refresh end.
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
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

extension DonateClothesViewController {
    
    internal func sendPaymentToOurServer() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //auth_token,user_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(self.eventModelData.id ?? 0)&donation_type=\(donationType)&show_user=\(showName.isSelected == true ? 1 : 0)"
        print(paramsStr)
        
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.makeDonation, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()

                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        DispatchQueue.main.async(execute: {
                            self.showAlertWithActionsMoveToRootView(jsonResult["message"] as? String ?? "")
                        })
                        
                    } else {
                        
                        DispatchQueue.main.async(execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })

                    }

                }
                
            } else {
                
                self.showAlert(errorMsg)
            }
        }
    }
}

