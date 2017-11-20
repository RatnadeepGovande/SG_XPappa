//
//  HomeEventsViewController.swift
//  App411
//
//  Created by osvinuser on 6/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class HomeEventsViewController: UIViewController, ShowAlert {
    
    @IBOutlet fileprivate var view_LayoutViewOptions: UIView!
    
    // This show option of event list layout.
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    @IBOutlet var containerListView: UIView!
    @IBOutlet var containerCardView: UIView!
    @IBOutlet var containerMapView: UIView!
    var bottomSheetView: PlacesViewController!

    
    var array_LayoutImages: [String] = ["ListViewIcon", "CardViewIcon", "MapViewIcon"]
    var array_eventList = [ACreateEventInfoModel]()
    
    fileprivate var isOpenLayoutOption: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegateShared.setupLocationManagerServices()
        
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewCellLayoutView", bundle: nil), forCellReuseIdentifier: "TableViewCellLayoutView")
        
        self.setViewBackground()
        
        // Reload Event List Data.
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEventAPI), name: NSNotification.Name(rawValue: "eventListAPIReloadNotification"), object: nil)
                
        self.reloadEventAPI()
    }

    
    //MAR:- UIActions.
    @IBAction func clickOnLayoutOption(_ sender: Any) {
    
        if isOpenLayoutOption == false {
        
            self.openLayoutViewController()
            
        } else {
        
            self.closeLayoutViewController()
            
        }
        
    }
    
    // MARK: - Add Bottom Sheet View.
    func addBottomSheetView() {
        
        // 1- Init bottomSheetVC
        if let bottomSheetVC = self.storyboard?.instantiateViewController(withIdentifier: "PlacesViewController") as? PlacesViewController {
            
            bottomSheetView = bottomSheetVC
            
            // 2- Add bottomSheetVC as a child view
            self.addChildViewController(bottomSheetVC)
            self.view.addSubview(bottomSheetVC.view)
            bottomSheetVC.didMove(toParentViewController: self)
            
            // 3- Adjust bottomSheet frame and initial position.
            let height = view.frame.height
            let width  = view.frame.width
            
            var partialView: CGFloat {
                return UIScreen.main.bounds.height - (170 + UIApplication.shared.statusBarFrame.height)
            }
            
            bottomSheetVC.view.frame = CGRect(x: 0, y: partialView, width: width, height: height)
            
        }
        
    }
    
    
    //MARK:- Layout options open and close.
    internal func openLayoutViewController() {
        
        isOpenLayoutOption = true
        
        view_LayoutViewOptions.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH-60, y: -180, width: 60, height: 180)
        self.view.addSubview(self.view_LayoutViewOptions)
        
        UIView.animate(withDuration: 0.25) { 
            self.view_LayoutViewOptions.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH-60, y: 0, width: 60, height: 180)
        }
    
    }
    
    internal func closeLayoutViewController() {
        
        isOpenLayoutOption = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view_LayoutViewOptions.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH-60, y: -180, width: 60, height: 180)
        }, completion: { (finish) in
            self.view_LayoutViewOptions.removeFromSuperview()
        })
        
    }
    
    @IBAction func createEventAction(_ sender: Any) {
        
        self.openActionSheet()
    }
    
    internal func openActionSheet() {
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
        let singleActionButton = UIAlertAction(title: "Create Single Event", style: .default) { action -> Void in
            print("Create Single Event")
            
            self.performSegue(withIdentifier: "chooseCategoryType", sender: self)

        }
        actionSheetController.addAction(singleActionButton)
        
        let groupActionButton = UIAlertAction(title: "Create Group Event", style: .default) { action -> Void in
            print("Create Group Event")
            
            self.performSegue(withIdentifier: "groupEvent", sender: self)
            
        }
        actionSheetController.addAction(groupActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    // MARK: - Reload Event.
    internal func reloadEventAPI() {
    
        if Reachability.isConnectedToNetwork() == true {
            self.getEventsDetailsAPI()
        } else {
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
    
    // MARK: - Get Event List API
    internal func getEventsDetailsAPI() {
    
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        //Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)

        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.eventList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
               // Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                      //  print(responeCode)
                        self.array_eventList.removeAll()
                        
                        if responeCode == true {
                            
                            if let eventList = jsonResult["event"] as? [Dictionary<String, AnyObject>] {
                                
                                for eventInfoObj in eventList {
                                    
                                    if let eventInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: eventInfoObj) {
                                        self.array_eventList.append(eventInfoMapperObj)
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                        Singleton.sharedInstance.array_eventList = self.array_eventList
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventListReloadNotification"), object: self, userInfo: ["":""])
                        
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

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
         if segue.identifier == "chooseCategoryType" {
         
             let destination = segue.destination as! FilterViewController
             destination.filterType = false
         
         }
     }

}

extension HomeEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_LayoutImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellLayoutView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellLayoutView") as! TableViewCellLayoutView
        
        let imageiCon: UIImage = UIImage(named: array_LayoutImages[indexPath.row])!
        
        cell.button_Layout.setImage(imageiCon, for: .normal)
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            containerListView.isHidden = false
            containerCardView.isHidden = true
            containerMapView.isHidden = true
            if bottomSheetView != nil {
                bottomSheetView.view.removeFromSuperview()
                bottomSheetView = nil

            }
            
        case 1:
            containerListView.isHidden = true
            containerCardView.isHidden = false
            containerMapView.isHidden = true
            if bottomSheetView != nil {
                bottomSheetView.view.removeFromSuperview()
                bottomSheetView = nil
            }
            
        case 2:
            containerListView.isHidden = true
            containerCardView.isHidden = true
            containerMapView.isHidden = false
            if bottomSheetView == nil {
                self.addBottomSheetView()
            }
            
            
        default:
            containerListView.isHidden = false
            containerCardView.isHidden = true
            containerMapView.isHidden = true
            if bottomSheetView != nil {
                bottomSheetView.view.removeFromSuperview()
                bottomSheetView = nil
            }
        }
        
        self.closeLayoutViewController()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
}
