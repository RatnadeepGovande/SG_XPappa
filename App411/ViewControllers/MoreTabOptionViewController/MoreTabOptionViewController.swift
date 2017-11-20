//
//  MoreTabOptionViewController.swift
//  App411
//
//  Created by osvinuser on 6/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class MoreTabOptionViewController: UIViewController {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    var array_TableOptions = ["Create Event", "My Profile", "My Channel", "Notifications", "Saved Events", "Calender", "Friends List", "Group List", "Block List", "Settings"]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView_Main.register(UINib(nibName: "TableViewCellDetailsOption", bundle: nil), forCellReuseIdentifier: "TableViewCellDetailsOption")
        
        self.setViewBackground()
    
    }

    
    // MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func openActionSheet() {
        
        // Create the AlertController and add its actions like button in ActionSheet
        let actionSheetController = UIAlertController(title: nil, message: "Option to select", preferredStyle: .actionSheet)
        
        let singleActionButton = UIAlertAction(title: "Create Single Event", style: .default) { action -> Void in
            print("Create Single Event")
            
            self.performSegue(withIdentifier: "createEvent", sender: self)
            
        }
        actionSheetController.addAction(singleActionButton)
        
        let groupActionButton = UIAlertAction(title: "Create Group Event", style: .default) { action -> Void in
            print("Create Group Event")
            
            self.performSegue(withIdentifier: "createGroup", sender: self)
            
        }
        actionSheetController.addAction(groupActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueMyProfile" {
            
            let userInfoModel = Methods.sharedInstance.getUserInfoData()
            
            let profileViewController: MyProfileViewController = segue.destination as! MyProfileViewController
            profileViewController.selectedUserProfile = userInfoModel
            
        } else if segue.identifier == "createEvent" {
            
            let destination = segue.destination as! FilterViewController
            destination.filterType = false
        }
    }
}

extension MoreTabOptionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return array_TableOptions.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellDetailsOption = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDetailsOption") as! TableViewCellDetailsOption
        
        cell.label_Text.text = array_TableOptions[indexPath.section]
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            self.openActionSheet()
        case 1:
            self.performSegue(withIdentifier: "segueMyProfile", sender: self)
        case 2:
            self.performSegue(withIdentifier: "segueChannelList", sender: self)
        case 3:
            self.performSegue(withIdentifier: "segueNotificationOption", sender: self)
        case 4:
            self.performSegue(withIdentifier: "segueSaveEvent", sender: self)
        case 5:
            self.performSegue(withIdentifier: "segueCalendar", sender: self)
        case 6:
            self.performSegue(withIdentifier: "segueFriendList", sender: self)
        case 7:
            self.performSegue(withIdentifier: "segueAllGroups", sender: self)
        case 8:
            self.performSegue(withIdentifier: "segueBlockOptions", sender: self)
        default:
            self.performSegue(withIdentifier: "segueSettingOption", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
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
