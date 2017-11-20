//
//  SaveEventsViewControllers.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class SaveEventsViewControllers: UIViewController, ShowAlert {
    
    @IBOutlet fileprivate var tableView_Main: UITableView!
    fileprivate var saveEventArray = [ACreateEventInfoModel]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewCellSaveEvents", bundle: nil), forCellReuseIdentifier: "TableViewCellSaveEvents")
        
        self.setViewBackground()
        
        self.refreshControlAPI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
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
        
        //check net connection
        if Reachability.isConnectedToNetwork() == true {
            self.showEventLists()
        } else {
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
    fileprivate func showEventLists() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.saveEventList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        if let eventList = jsonResult["event"] as? [Dictionary<String, AnyObject>] {
                            
                            self.saveEventArray.removeAll()
                            for eventInfoObj in eventList {
                                
                                if let eventInfoMapperObj = Mapper<ACreateEventInfoModel>().map(JSONObject: eventInfoObj) {
                                    self.saveEventArray.append(eventInfoMapperObj)
                                }
                                
                            }
                            
                        }
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            //self.showAlert(jsonResult["message"] as? String ?? "")
                            
                            if self.saveEventArray.count <= 0 {
                                
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
    
    
    // MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension SaveEventsViewControllers: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.saveEventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellSaveEvents = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSaveEvents") as! TableViewCellSaveEvents
        
        cell.avatarImage.layer.cornerRadius = (cell.avatarImage.frame.size.width)/2
        cell.avatarImage.clipsToBounds = true
        
        let aEventInfoModel: ACreateEventInfoModel = self.saveEventArray[indexPath.row]
        
        //If event_image contains video then below condition will execute or vice - versa.
        // Check Video.
        if aEventInfoModel.event_video_flag == "1" {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.event_Thumbnail ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        } else {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        }
        
        cell.eventTitleLabel.text = aEventInfoModel.title
        
        cell.descriptionLabel.text = aEventInfoModel.start_event_date! + "\n" + aEventInfoModel.event_place_name!
        
        cell.selectionStyle = .none
        
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
        
        self.moveToDetailEvent(row: indexPath.row, arrayObject: self.saveEventArray)
        
    }
    
}
