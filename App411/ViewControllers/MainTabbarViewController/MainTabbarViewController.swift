//
//  MainTabbarViewController.swift
//  App411
//
//  Created by osvinuser on 6/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class MainTabbarViewController: UITabBarController, ShowAlert {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBar.tintColor = appColor.appTabbarSelectedColor
        self.tabBar.unselectedItemTintColor = appColor.appTabbarUnSelectedColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFilterCategories), name: NSNotification.Name(rawValue: "categoryListReloadNotification"), object: nil)
        
        
        self.reloadFilterCategories()

    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
//        if (tabBar.selectedItem?.tag) != nil {
//
//            let secondItemView = self.tabBar.subviews[item.tag]
//            let secondItemImageView = secondItemView.subviews.first as! UIImageView
//
//            secondItemImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            UIView.animate(withDuration: 1) {
//                secondItemImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
//            }
//
//        }
        
    }
    
    
    //MARK:- Reload Get Filter Categories.
    internal func reloadFilterCategories() {
        
        self.getFilterCategories()
        
    }
    
    //MARK:- Get Filter Categories
    internal func getFilterCategories() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
      //  Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.filter_category_list, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
              //  Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let categoryList = jsonResult["event_category"] as? [Dictionary<String, AnyObject>] {
                                
                                var array_CategoryList = [AFilterCategoriesInfoModel]()
                                
                                for categoryListInfoObj in categoryList {
                                    
                                    if let categoryInfoMapperObj = Mapper<AFilterCategoriesInfoModel>().map(JSONObject: categoryListInfoObj) {
                                        
                                        print(categoryInfoMapperObj.color_code ?? "")
                                        array_CategoryList.append(categoryInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                                Singleton.sharedInstance.categoryListInfo = array_CategoryList
                                
                            }
                            
                        } else {
                            
                            //self.showAlert(jsonResult["message"] as? String ?? "")
                            
                        }
                        
                    } else {
                        
                        //print("Worng data found.")
                        
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
    
    
    //MARK:- Get All Event Data
    internal func getAllEventData() {
    
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.filter_category_list, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if let categoryList = jsonResult["event_category"] as? [Dictionary<String, AnyObject>] {
                                
                                var array_CategoryList = [AFilterCategoriesInfoModel]()
                                
                                for categoryListInfoObj in categoryList {
                                    
                                    if let categoryInfoMapperObj = Mapper<AFilterCategoriesInfoModel>().map(JSONObject: categoryListInfoObj) {
                                        
                                        print(categoryInfoMapperObj.color_code ?? "")
                                        array_CategoryList.append(categoryInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                                Singleton.sharedInstance.categoryListInfo = array_CategoryList
                                
                            }
                            
                        } else {
                            
                            //self.showAlert(jsonResult["message"] as? String ?? "")
                            
                        }
                        
                    } else {
                        
                        //print("Worng data found.")
                        
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
