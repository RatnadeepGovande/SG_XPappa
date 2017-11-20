//
//  EventGroupListViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class EventGroupListViewController: UIViewController, ShowAlert {

    // Variables.
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    fileprivate var groupEventArray = [AGroupEventInfoModel]()
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewCellSaveEvents", bundle: nil), forCellReuseIdentifier: "TableViewCellSaveEvents")
        
        self.setViewBackground()
        
        self.refreshControlAPI()
        
    }

    // MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - refresh control For API
    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        tableView_Main.addSubview(refreshControl) // not required when using UITableViewController
        
        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    // MARK: - Reload API
    func reloadAPI() {
        
        // Check network connection.
        if Reachability.isConnectedToNetwork() == true {
            
            self.showGroupEventLists()
           
        } else {
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    internal func showGroupEventLists() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.groupOfEventList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            self.refreshControl.endRefreshing()

            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        if let eventList = jsonResult["group_list"] as? [Dictionary<String, AnyObject>] {
                            
                            self.groupEventArray.removeAll()
                            for eventInfoObj in eventList {
                                
                                if let groupEventMapperObj = Mapper<AGroupEventInfoModel>().map(JSONObject: eventInfoObj) {
                                    self.groupEventArray.append(groupEventMapperObj)
                                }
                                
                            }
                            
                        }
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            //self.showAlert(jsonResult["message"] as? String ?? "")
                            
                            if self.groupEventArray.count <= 0 {
                                
                                let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                
                                view_NoData.label_Text.text = "No Data Found"
                                
                                self.tableView_Main.backgroundView = view_NoData
                                
                            } else {
                                
                                self.tableView_Main.backgroundView = nil
                            }
                            
                        })
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView_Main.reloadData()
                    }
                }
            } else {
                
                self.showAlert(errorMsg)
            }
        }
    }


    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "groupEventDetail" {
            
            let destinationView: GroupEventDetailViewController = segue.destination as! GroupEventDetailViewController
            destinationView.groupEventData = sender as? AGroupEventInfoModel

        }
    }

}

extension EventGroupListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupEventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellSaveEvents = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSaveEvents") as! TableViewCellSaveEvents
        
        cell.avatarImage.layer.cornerRadius = (cell.avatarImage.frame.size.width)/2
        
        cell.avatarImage.clipsToBounds = true
        
        let aEventInfoModel: AGroupEventInfoModel = self.groupEventArray[indexPath.row]
        
        // If event_image contains video then below condition will execute or vice - versa.
        // Check Video.
        if aEventInfoModel.videoFlag == 1 {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.groupImageUrl ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        } else {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.groupImageUrl ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        }

        cell.eventTitleLabel.text = aEventInfoModel.groupName
        
        cell.descriptionLabel.text = aEventInfoModel.groupDescription
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let object = self.groupEventArray[indexPath.row]
        
        self.performSegue(withIdentifier: "groupEventDetail", sender: object)
        
    }
    
}
