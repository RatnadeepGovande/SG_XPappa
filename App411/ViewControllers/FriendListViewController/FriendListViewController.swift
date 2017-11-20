//
//  FriendListViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class FriendListViewController: UIViewController, ShowAlert {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    fileprivate var array_FriendList = [AFriendInfoModel]()
    fileprivate var array_RequestList = [AFriendInfoModel]()

    
    fileprivate var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        tableView_Main.register(UINib(nibName: "TableViewCellFriendList", bundle: nil), forCellReuseIdentifier: "TableViewCellFriendList")
        tableView_Main.register(UINib(nibName: "TableViewCellFriendRequest", bundle: nil), forCellReuseIdentifier: "TableViewCellFriendRequest")

        self.setViewBackground()
        
        self.refreshControlAPI()
        self.reloadAPI()
        
        print(tableView_Main.backgroundView ?? "View No found")
        
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
            
            self.getFriendRequestList()
            
        } else {
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    // Get Friend Request List.
    func getFriendRequestList() {
            
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.friendList, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            self.refreshControl.endRefreshing()
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.array_FriendList.removeAll()
                            if let friendList = jsonResult["user"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                        
                                        self.array_FriendList.append(friendInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                            self.array_RequestList.removeAll()
                            if let friendList = jsonResult["friend_request_list"] as? [Dictionary<String, AnyObject>] {
                                
                                for friendInfoObj in friendList {
                                    
                                    if let friendInfoMapperObj = Mapper<AFriendInfoModel>().map(JSONObject: friendInfoObj) {
                                        
                                        self.array_RequestList.append(friendInfoMapperObj)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                            self.tableView_Main.reloadData()

                            
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                //self.showAlert(jsonResult["message"] as? String ?? "")
                                
                                if self.array_FriendList.count <= 0 && self.array_RequestList.count <= 0 {
                                    
                                    let view_NoData = UIViewIllustration(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                    
                                    view_NoData.label_Text.text = "No Data Found"
                                                                                                            
                                    self.tableView_Main.backgroundView = view_NoData
                                    
                                } else {
                                    
                                    self.tableView_Main.backgroundView = nil
                                }
                                
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
    
    internal func reportSpamUserRequestApi(aFriendInfoModel: AFriendInfoModel) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        //auth_token,user_id,content
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&user_id=\(String(aFriendInfoModel.id ?? 0))&content=hgsadga"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.userSpam, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                    }
                    
                } else {
                    
                    print("Worng data found.")
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

extension FriendListViewController: TableViewCellFriendRequestDelegate {
    
    
    func acceptFriendRequest(tag: Int) {
        
        let aFriendInfoModel: AFriendInfoModel = self.array_RequestList[tag]
        self.acceptFriendRequestAPI(aFriendInfoModel: aFriendInfoModel, tag: tag)
        
    }
    
    
    func rejectFriendRequest(tag: Int) {
        
        let aFriendInfoModel: AFriendInfoModel = self.array_RequestList[tag]
        self.rejectFriendRequestAPI(aFriendInfoModel: aFriendInfoModel, tag: tag)
        
    }
    
    
    internal func acceptFriendRequestAPI(aFriendInfoModel: AFriendInfoModel, tag: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(String(aFriendInfoModel.id ?? 0))"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.accept_request, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.array_RequestList.remove(at: tag)
                            self.array_FriendList.insert(aFriendInfoModel, at: 0)
                            
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
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    internal func rejectFriendRequestAPI(aFriendInfoModel: AFriendInfoModel, tag: Int) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(String(aFriendInfoModel.id ?? 0))"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.delete_friend, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            self.array_RequestList.remove(at: tag)
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
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
        }
        
    }
    
    
    internal func unFriendUserRequestAPI(aFriendInfoModel: AFriendInfoModel, tag: Int, completionHandler:@escaping CallBackMethods.SourceCompletionHandler) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        Methods.sharedInstance.showLoader()
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(String(aFriendInfoModel.id ?? 0))"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.unfriendUser, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool {
                        
                        print(responeCode)
                        
                        if responeCode == true {
                            
                            completionHandler(true as AnyObject)
                            
                        } else {
                            
                            completionHandler(false as AnyObject)
                            
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
    
    internal func blockUserRequestApi(aFriendInfoModel: AFriendInfoModel) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //block_user
        Methods.sharedInstance.showLoader()
        
        //auth_token,friend_id
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&friend_id=\(aFriendInfoModel.id ?? 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.blockUserRequest, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        
                        print(responeCode)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                        
                    } else {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                            self.showAlert(jsonResult["message"] as? String ?? "")
                        })
                    }
                    
                } else {
                    
                    print("Worng data found.")
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


extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? self.array_RequestList.count : array_FriendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell:TableViewCellFriendRequest = tableView.dequeueReusableCell(withIdentifier: "TableViewCellFriendRequest") as! TableViewCellFriendRequest
            
            cell.delegate = self
            
            let aFriendInfoModel: AFriendInfoModel = self.array_RequestList[indexPath.row]
            
            cell.imageView_image.sd_setImage(with: URL(string: aFriendInfoModel.image ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
            
            cell.label_Title.text = aFriendInfoModel.fullname
            
            cell.label_description.text = aFriendInfoModel.facebookStatus == true ? "Facebook User" : aFriendInfoModel.email
            
            cell.rejectFriendRequestButton.tag = indexPath.row
            
            cell.acceptFriendRequestButton.tag = indexPath.row
            
            cell.selectionStyle = .none
            
            return cell
            
        } else {
            
            let cell:TableViewCellFriendList = tableView.dequeueReusableCell(withIdentifier: "TableViewCellFriendList") as! TableViewCellFriendList
            
            let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
            
            cell.imageView_image.sd_setImage(with: URL(string: aFriendInfoModel.image ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarSmallImage"))
            
            cell.label_Title.text = aFriendInfoModel.fullname
            
            cell.label_description.text = aFriendInfoModel.facebookStatus == true ? "Facebook User" : aFriendInfoModel.email
            
            cell.selectionStyle = .none
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return self.array_RequestList.count <= 0 ? 0.1 : 30.0
            
        } else {
            
            return 30.0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return self.array_RequestList.count <= 0 ? 0.1 : 10.0
            
        } else {
            
            return 10.0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        if section == 0 {
            
            if array_RequestList.count > 0 {
                
                hearderView.backgroundColor = UIColor.white
                hearderView.addSubview(self.addLabelAtHeaderView(text: "Invitations"))
                hearderView.addSubview(self.addLineATHeaderView(viewRect: CGRect(x: 0, y: 29, width: tableView.frame.size.width, height: 0.5)))
                
            }
            
        } else {
            
            if array_FriendList.count > 0 {
                
                hearderView.backgroundColor = UIColor.white
                hearderView.addSubview(self.addLabelAtHeaderView(text: "Friends"))
                hearderView.addSubview(self.addLineATHeaderView(viewRect: CGRect(x: 0, y: 29, width: tableView.frame.size.width, height: 0.5)))
                
            }
            
        }
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    internal func addLabelAtHeaderView(text: String) -> UILabel {
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 29))
        
        label_Title.text = text
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 16)
        
        return label_Title
        
    }
    
    internal func addLineATHeaderView(viewRect: CGRect) -> UIView {
        
        let viewLine: UIView = UIView(frame: viewRect);
        
        viewLine.backgroundColor = UIColor.lightGray
        
        return viewLine
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return false
        } else {
           return self.array_FriendList.count <= 0 ? false : true
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell:TableViewCellFriendList = tableView.cellForRow(at: indexPath) as! TableViewCellFriendList
        
        let height : CGFloat = cell.frame.size.height
        
        //1. Block Action
        let blockAction = UITableViewRowAction(style: .default, title: "      ", handler: { (action, IndexPath) in
            print("Edit tapped")
            
            let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
            
            self.alertFunctionsWithCallBack(title: "Are you sure you want to block \(aFriendInfoModel.fullname ?? "")? \nIf you're friends, blocking someone will also unfriend him.", completionHandler: { (isTrue) in
                
                if isTrue.boolValue {
                    
                    if Reachability.isConnectedToNetwork() == true {
                        
                        self.blockUserRequestApi(aFriendInfoModel: aFriendInfoModel)
                        
                    } else {
                        
                        self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                        
                    }
                }
                
            })
        })
        
        let block_BackgroundImage = self.setSwipeImage(image: #imageLiteral(resourceName: "ic_block"), height: height, color: UIColor(hex: "#9DA3A6"))
        
        blockAction.backgroundColor = UIColor(patternImage: block_BackgroundImage)
        
        
        
        //2. Report Action
        let reportAction = UITableViewRowAction(style: .default, title: "      ", handler: { (action, IndexPath) in
            print("Edit tapped")
            
            let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
            
            self.alertFunctionsWithCallBack(title: "Are you sure you want to report \(aFriendInfoModel.fullname ?? ""))?", completionHandler: { (isTrue) in
                
                if isTrue.boolValue {
                    
                    if Reachability.isConnectedToNetwork() == true {
                        
                        let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
                        self.reportSpamUserRequestApi(aFriendInfoModel: aFriendInfoModel)
                        
                    } else {
                        
                        self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                        
                    }
                }
                
            })
            
        })
        
        let report_BackgroundImage = self.setSwipeImage(image: #imageLiteral(resourceName: "ic_report"), height: height, color: UIColor(hex: "#F7CA18"))
        
        reportAction.backgroundColor = UIColor(patternImage: report_BackgroundImage)
        
        
        
        //3. Delete Action
        let deleteAction = UITableViewRowAction(style: .default, title: "      ", handler: { (action, IndexPath) in
            print("Delete tapped")
            
            if Reachability.isConnectedToNetwork() == true {
                
                let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
                
                self.unFriendUserRequestAPI(aFriendInfoModel: aFriendInfoModel, tag: indexPath.row, completionHandler: { (isTrue) in
                    
                    if isTrue.boolValue {
                        
                        self.array_FriendList.remove(at: indexPath.row)
                        self.tableView_Main.deleteRows(at: [indexPath], with: .fade)
                        
                    }
                })
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
        })
        
        
        let delete_BackgroundImage = self.setSwipeImage(image: #imageLiteral(resourceName: "ic_deleteCross"), height: height, color: UIColor(hex: "#FE3F35"))
        
        deleteAction.backgroundColor = UIColor(patternImage: delete_BackgroundImage)
        
        
        
        return [blockAction, reportAction, deleteAction]
        
    }
    
    func setSwipeImage(image: UIImage, height: CGFloat, color: UIColor) -> UIImage {
        
        let frame = CGRect(x: 0, y: 0, width: 60, height: height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 60, height: height), false, UIScreen.main.scale)
        
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(frame)
        
        let image = image
        image.draw(in: CGRect(x: ((frame.size.width / 2) - 12) , y: ((frame.size.height / 2) - 12), width: 24, height: 24))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let aFriendInfoModel: AFriendInfoModel = self.array_RequestList[indexPath.row]
            let userObj = AUserInfoModel(id: aFriendInfoModel.id ?? 0)
            self.showUserProfile(userObj)
            
        } else {
            
            let aFriendInfoModel: AFriendInfoModel = self.array_FriendList[indexPath.row]
            let userObj = AUserInfoModel(id: aFriendInfoModel.id ?? 0)
            self.showUserProfile(userObj)
        }
        
    }

}
