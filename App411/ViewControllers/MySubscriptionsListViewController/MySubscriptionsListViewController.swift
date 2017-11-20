//
//  MySubscriptionsListViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper

class ChannelListMoadelInfo: Mappable {

    var id: Int?
    var channelName: String?
    var image: String?
    var imageLink: String?
    var user_id: Int?
    var subcription_count: Int?
    var subcription_status: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id                   <- map["id"]
        image                <- map["image"]
        imageLink            <- map["image_link"]
        channelName          <- map["channel_name"]
        user_id              <- map["user_id"]
        subcription_count    <- map["subcription_count"]
        subcription_status   <- map["subcription_status"]
    }
    
}



protocol MySubscriptionsListViewControllerDelegate {
    func selectedUserChannelID(channelID: Int, isUserChannel: Bool)
}



class MySubscriptionsListViewController: UIViewController, ShowAlert {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    @IBOutlet var barButton_MyChannel: UIBarButtonItem!
    
    fileprivate var refreshControl: UIRefreshControl!

    
    var array_ChannelList: [ChannelListMoadelInfo] = []
    
    
    var delegate: MySubscriptionsListViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewCellSubscriptions", bundle: nil), forCellReuseIdentifier: "TableViewCellSubscriptions")
        
        self.setViewBackground()
        self.refreshControlAPI()
        //self.reloadAPI()
    }

    
    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        tableView_Main.addSubview(refreshControl) // not required when using UITableViewController
        
        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    
    
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.subscribedChannelListAPI()
            
        } else {
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    
    // MARK: - Subscribed channel list API.
    
    internal func subscribedChannelListAPI() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.channel_list, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        self.array_ChannelList.removeAll()
                        
                        if responeCode == true {
                            
                            if let channelList = jsonResult["channel"] as? [Dictionary<String, AnyObject>] {
                                
                                for channelInfoObj in channelList {
                                    
                                    if let channelInfoMapperObj = Mapper<ChannelListMoadelInfo>().map(JSONObject: channelInfoObj) {
                                        self.array_ChannelList.append(channelInfoMapperObj)
                                    }
                                    
                                }
                            
                            }
                            
                            self.tableView_Main.reloadData()
                            
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
    
    
    // Mark: - IBAction
    
    @IBAction func MyChannelBarButton(_ sender: Any) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        delegate?.selectedUserChannelID(channelID: userInfoModel.channelId ?? 0, isUserChannel: true)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }


}

extension MySubscriptionsListViewController: UITableViewDelegate, UITableViewDataSource, TableViewCellSubscriptionsDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_ChannelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: TableViewCellSubscriptions = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSubscriptions") as! TableViewCellSubscriptions
        
        cell.delegate = self
        
        cell.button_subscribe.tag = indexPath.row
        
        
        let channelObj = self.array_ChannelList[indexPath.row]
        
        if let channelName = channelObj.channelName {
            cell.label_Title.text = channelName
        }
        
        cell.imageView_Channel.sd_setImage(with: URL(string: channelObj.imageLink ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
        
        
        if let channelViewersCount = channelObj.subcription_count {
            cell.label_ViewerCount.text = channelViewersCount > 0 ? "\(channelViewersCount) Subscribers" : "\(channelViewersCount) Subscriber"
        }

        
        if let channelViewersCount = channelObj.subcription_status {
            cell.button_subscribe.setTitle(channelViewersCount == "0" ? "Subscribe" : "Subscribed",for: .normal)
        } else {
            cell.button_subscribe.setTitle("Subscribe",for: .normal)
        }
        
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channelObj = self.array_ChannelList[indexPath.row]
        
        delegate?.selectedUserChannelID(channelID: channelObj.id ?? 0, isUserChannel: false)
        
        self.navigationController?.popViewController(animated: true)
        
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
    
    
    // MARK: - click subscribe button delegate.
    func clickOnSubscribeButton(_ sender: Any) {
    
        let channelObj = self.array_ChannelList[(sender as AnyObject).tag]
        
        //check net connection
        if Reachability.isConnectedToNetwork() == true {
            
            // Current User
            guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                return
            }
            
            self.subscribeAndUnSubscribeAPI(authToken: userInfoModel.authentication_token ?? "", channelID: channelObj.id ?? 0, sender: sender, isSubscribe: channelObj.subcription_status ?? "0")
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    // MARK: - Subscribe and UnSubscribe API.
    
    internal func subscribeAndUnSubscribeAPI(authToken: String, channelID: Int, sender: Any, isSubscribe: String) {
        
        // API's param.
        let paramsStr = "auth_token=\(authToken)&channel_id=\(channelID)&subscription_status=\(isSubscribe == "0" ? "1" : "0")"
        print(paramsStr)
        
        // Auth_token, Channel_id
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.subscribe_unsubscribe_channel, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        if isSubscribe == "0" {
                            (sender as AnyObject).setTitle("Subscribed",for: .normal)
                        } else {
                            (sender as AnyObject).setTitle("Subscribe",for: .normal)
                        }
                        
                        let tagValue = (sender as AnyObject).tag
                        self.array_ChannelList[tagValue!].subcription_status = isSubscribe == "0" ? "1" : "0"
                        
                    } else {
                        
                        // self.tableView_Main.setBackGroundOfTableView(arrayBlockedList: [])
                        // When data Not found.
                    }
                    
                }
                
            } else {
                
                self.showAlert(errorMsg)
                
            }
            
        }
        
    }
    
    
}

