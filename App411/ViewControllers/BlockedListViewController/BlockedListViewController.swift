//
//  BlockedListViewController.swift
//  App411
//
//  Created by osvinuser on 8/17/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import SDWebImage


class BlockedListViewController: UIViewController, ShowAlert {
    
    // Variables.
    @IBOutlet var tableView_Main: UITableView!
    
    var arrayBlockedList = [AUserInfoModel]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        tableView_Main.register(UINib(nibName: "BlockedTableViewCell", bundle: nil), forCellReuseIdentifier: "BlockedTableViewCell")
        
        self.setViewBackground()
        self.refreshControlAPI()
        self.reloadAPI()

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

    // MARK: - Reload API.
    
    internal func reloadAPI() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.blockUserListAPI()
            
        } else {
            
            // Refresh end.
            self.refreshControl.endRefreshing()
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension BlockedListViewController : BlockedTableViewCellDelegate {
    
    func unblockAction(_ indexPathOfRow: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            let userInfo = self.arrayBlockedList[indexPathOfRow]
            
            self.unBlockUserRequestApi(friendId: "\(userInfo.id ?? 0)", indexRemove: indexPathOfRow)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
}

extension BlockedListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 1
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 2
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayBlockedList.count
        
    }
    
    // 3
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: BlockedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BlockedTableViewCell") as! BlockedTableViewCell
        
        cell.selectionStyle = .none

        
        // user info.
        let aUserInfoObject: AUserInfoModel = self.arrayBlockedList[indexPath.row]
        
        cell.delegate = self
        
        cell.nameLabel.text = aUserInfoObject.fullname ?? ""
        
        cell.removeButton.tag = indexPath.row
        
        cell.avatarImage.sd_setImage(with: URL(string:aUserInfoObject.image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

        
        return cell
        
    }
    
    // 4
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // 5
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 6
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // 7
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        hearderView.backgroundColor = UIColor.clear
        return hearderView
        
    }
    
    // 8
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        hearderView.backgroundColor = UIColor.clear
        return hearderView
        
    }
    
}

