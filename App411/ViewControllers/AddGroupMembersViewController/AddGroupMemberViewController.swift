//
//  AddGroupMemberViewController.swift
//  App411
//
//  Created by osvinuser on 8/10/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class AddGroupMemberViewController: UIViewController, ShowAlert {

    @IBOutlet var tableView_Main: UITableView!
    @IBOutlet var barButtonDoneItem: UIBarButtonItem!

    // Variables
    var array_FriendList = [AFriendInfoModel]()
    
    var array_SelectedFriends = [AFriendInfoModel]()

    var groupID: Int?
    
    //0 is for adding members in the group, 1 is for viewing group members, 2 is for adding hosts in the group
    var addMembers: Int?

    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barButtonDoneItem.isEnabled = false
        
        if addMembers == 2 || addMembers == 3 {
            self.title = addMembers == 2 ? "Make Hosts" : "Group Hosts"
        } else {
            self.title = addMembers == 1 ? "Group Members" : "Add Members"
        }
        

        /* Set view background */
        self.setViewBackground()
        
        /* Register nib files */
        self.tableCellNibs()
        
        /* Add refresh controller */
        self.refreshControlAPI()

    }
    
    // MARK: - table cell nibs
    internal func tableCellNibs() {
        tableView_Main.register(UINib(nibName: "TableViewCellFriendList", bundle: nil), forCellReuseIdentifier: "TableViewCellFriendList")
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
            
            if addMembers == 2 || addMembers == 3 || addMembers == 1 {
                self.getHostsFromServer()
            } else {
                // call Friend list API.
                self.getFriendRequestList()
            }
            
        } else {
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            
            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    // Get Friend Request List.
    func getFriendRequestList() {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        // auth_token,group_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&group_id=\(groupID ?? 0)"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.groupFriendList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if self.array_FriendList.count > 0 {
                                self.array_FriendList.removeAll()
                                self.array_FriendList.removeAll()

                            }
                            
                                if let friendList = jsonResult["friend_list"] as? [Dictionary<String, AnyObject>] {
                                    
                                    for friendInfoObj in friendList {
                                        
                                        if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                            
                                            self.array_FriendList.append(friendInfoMapperObj)
                                        }
                                        
                                    }
                                    
                                }
                           
                            self.tableView_Main.reloadData()
                            //self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            
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
                
                self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    func getHostsFromServer() {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        var dictKey = String()
        
        dictKey = "user"
        
        // auth_token,group_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&group_id=\(groupID ?? 0)"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.viewAllGroupMembers, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                self.refreshControl.endRefreshing()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            if self.array_FriendList.count > 0 {
                                self.array_FriendList.removeAll()
                                self.array_FriendList.removeAll()
                                
                            }
                            
                            if self.addMembers == 3 {
                                
                                if let friendList = jsonResult[dictKey]?["host"] as? [Dictionary<String, AnyObject>] {
                                    
                                    for friendInfoObj in friendList {
                                        
                                        if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                            
                                            self.array_FriendList.append(friendInfoMapperObj)
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                            if self.addMembers == 2 || self.addMembers == 1 {
                                
                                if let friendList = jsonResult[dictKey]?["not_host"] as? [Dictionary<String, AnyObject>] {
                                    
                                    for friendInfoObj in friendList {
                                        
                                        if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                            
                                            self.array_FriendList.append(friendInfoMapperObj)
                                        }
                                        
                                    }
                                    
                                }
                            }
                            self.tableView_Main.reloadData()
                            //self.showAlertWithActions(jsonResult["message"] as? String ?? "")
                            
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
                
                self.refreshControl.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    
    func addMemberToGroupServiceFunction(inviteUserIds: String, groupID: Int) {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        //auth_token,user_ids,group_id,status if 0 means disjoint 1 means joint
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_ids=\(inviteUserIds)&group_id=\(groupID)&status=\("1")"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.addMemberToGroup, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.showAlert(jsonResult["message"] as? String ?? "")
                            
                            self.navigationController?.popViewController(animated: true)
                            
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
    
    
    func createHostForGroup(inviteUserIds: String, groupID: Int) {
        
        // Get current user id.
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        //auth_token,user_ids,group_id, if status = 0 for unhost and status = 1 for host
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_ids=\(inviteUserIds)&group_id=\(groupID)&status=\("1")"
        print(paramsStr)
        
        // Friend list web service
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.addGroupHost, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.showAlert(jsonResult["message"] as? String ?? "")
                            
                            self.navigationController?.popViewController(animated: true)
                            
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
    
    // MARK:- IBAction.
    @IBAction func doneBarButtonAction(_ sender: Any) {
        
        let ids = array_SelectedFriends.flatMap { String($0.id ?? 0) }
        let joinIdsString = ids.joined(separator: ",")
        
        if addMembers == 2 {
            
            // Check network connection.
            if Reachability.isConnectedToNetwork() == true {
                
                // call Friend list API.
                self.createHostForGroup(inviteUserIds: joinIdsString, groupID: groupID ?? 0)
                
            } else {
                
                // Show Internet Connection Error
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
        } else if addMembers == 0 {
            
            // Check network connection.
            if Reachability.isConnectedToNetwork() == true {
                
                // call Friend list API.
                self.addMemberToGroupServiceFunction(inviteUserIds: joinIdsString, groupID: groupID ?? 0)
                
            } else {
                
                // Show Internet Connection Error
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
        }
        
    }

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

extension AddGroupMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 1
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_FriendList.count
    }
    
    // 3
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellFriendList = tableView.dequeueReusableCell(withIdentifier: "TableViewCellFriendList") as! TableViewCellFriendList
        
        // Get Model Data
        let aFriendInfoModel: AFriendInfoModel = array_FriendList[indexPath.row]
        
        cell.imageView_image.sd_setImage(with: URL(string: aFriendInfoModel.image ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
        
        cell.label_Title.text = aFriendInfoModel.fullname
        
        cell.label_description.text = aFriendInfoModel.email
        
        // Check Data contain or not.
        if array_SelectedFriends.contains(where: { $0.id == aFriendInfoModel.id }) {
        
            cell.accessoryType = .checkmark
            
        } else {
            
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    // 4
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if addMembers == 2 || addMembers == 0 {
            
            // Get table cell
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            
            // Get Friend Data.
            let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
            
            // Check Data contain or not.
            if array_SelectedFriends.contains(where: { $0.id == aFriendInfoModel.id }) {
                
                _ = array_SelectedFriends.index(where: { $0.id ==  aFriendInfoModel.id }).map({ (Index) in
                    array_SelectedFriends.remove(at: Index)
                })
                
                cell.accessoryType = .none
                
            } else {
                
                array_SelectedFriends.append(aFriendInfoModel)
                cell.accessoryType = .checkmark
                
            }
            
            barButtonDoneItem.isEnabled = array_SelectedFriends.count > 0 ? true : false
            
        }
    }
    // 5
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // 6
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 7
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 8
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    // 9
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
}

