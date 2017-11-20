//
//  ViewController.swift
//  411Demo
//
//  Created by osvinuser on 9/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

/*

 Button Corner Radius is Pending
 
*/

import UIKit
import ObjectMapper

class DonateViewController: UIViewController, ShowAlert {
    
    let donationArray = ["Money", "Food", "Clothes", "Others"]
    var selectedValue : Int = 4
    @IBOutlet weak var collectionView: UICollectionView!
    var eventModelData : ACreateEventInfoModel!
    var isFromExplore = false

    //MARK:- View Start
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register Nibs
        collectionView.register(UINib(nibName: "DonateViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DonateViewCell")
        
        if isFromExplore == true {
            self.reloadAPI()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.showCauseDetailFor(causeID: eventModelData.id ?? 0)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
    internal func showCauseDetailFor(causeID: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
            
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(causeID)"
        print(paramsStr)
        
        Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.eventDetail, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            Methods.sharedInstance.hideLoader()

            // Refresh end.
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        if let eventList = jsonResult["event"] as? [Dictionary<String, AnyObject>] {
                            
                            for eventInfoObj in eventList {
                                
                                if let eventInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: eventInfoObj) {
                                    
                                    self.eventModelData = eventInfoMapperObj
                                    
                                }
                                
                            }
                        }
                    
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    //MARK:- IBActions
    @IBAction func makeDonation(_ sender : UIButton) {
        
        print("press on Donation Button")
        
        if selectedValue < 4 {
            
            if selectedValue == 0 {
                
                self.performSegue(withIdentifier: "donateMoney", sender: eventModelData.id ?? 0)
                
            } else {
                
                self.performSegue(withIdentifier: "donateClothes", sender: self)
                
            }
            
        } else {
            
            self.showAlert("Please select your donation type")
            
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "donateMoney" {
            let destinationVC = segue.destination as! SaveCardViewController
            destinationVC.eventModelData = eventModelData
        } else {
            
            let destinationVC = segue.destination as! DonateClothesViewController
            destinationVC.eventModelData = eventModelData
            destinationVC.donationType = selectedValue

        }
    }
    
    //MARK:- Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DonateViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 1
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return donationArray.count
    }
    
    // 2
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DonateViewCell", for: indexPath) as! DonateViewCell
        
        cell.textDonationLabel?.text = donationArray[indexPath.item]
        
        return cell
    }
    
    // 3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding : CGFloat = 10.0
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2.0, height: 35)
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell : DonateViewCell = collectionView.cellForItem(at: indexPath) as! DonateViewCell
        
        cell.selectedDonationImage.image = #imageLiteral(resourceName: "ic_checkbox_selected")
        
        selectedValue = indexPath.item
        
    }
    
    // 5
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell : DonateViewCell = collectionView.cellForItem(at: indexPath) as! DonateViewCell
        
        cell.selectedDonationImage.image = #imageLiteral(resourceName: "ic_checkbox_unselected")
    }
    

}



