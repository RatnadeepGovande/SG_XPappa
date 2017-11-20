//
//  GroupDetailsShowViewController.swift
//  App411
//
//  Created by osvinuser on 8/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class ParticipantsInfo: NSObject {

    var userName: String?
    var avatarImage: String?
    var userId: String?
    
    init(dict: Dictionary<String, AnyObject>) {
    
        self.userName = dict["user_display_name"] as? String ?? ""
        self.avatarImage = dict["avatar_image"] as? String ?? ""
        self.userId = dict["user_id"] as? String ?? ""
    }
    
}

class GroupDetailsShowViewController: UIViewController {

    // Variables
    @IBOutlet var tableView_main: UITableView!

    
    var groupMetaData: [String : Any]?
    
    var array_ParticipantsInfo: [ParticipantsInfo] = []
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view.

        print(groupMetaData ?? "No Data found.")
        
        self.title = groupMetaData?["title"] as? String ?? "Unknow Group"
        
        // Register Nibs.
        self.registerCellsForTableView()
        
        // Get Participants.
        self.getParticipantsInfo()
    }
    
    
    // MARK: - Register cells
    
    internal func registerCellsForTableView() {
    
        tableView_main.register(UINib(nibName: "TableViewCellGroupProfile", bundle: nil), forCellReuseIdentifier: "TableViewCellGroupProfile" )
        tableView_main.register(UINib(nibName: "TableViewCellGroupParticipants", bundle: nil), forCellReuseIdentifier: "TableViewCellGroupParticipants")
    }
    
    
    // MARK: - Get Participants (Convert data into model class)
    
    internal func getParticipantsInfo() {
    
        array_ParticipantsInfo.removeAll()
        
        if let participantsData = groupMetaData?["users"] {
        
            let data = (participantsData as AnyObject).data(using: String.Encoding.utf8.rawValue)
            
            let participants_JSON = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [Dictionary<String, AnyObject>]
            print(participants_JSON)
            
            for user in participants_JSON {
                let participantsObj = ParticipantsInfo(dict: user)
                self.array_ParticipantsInfo.append(participantsObj)
            }
            
        }
        
        tableView_main.reloadData()
        
    }
    

    
    
    // MARK: - Did Receive Memory Warning.
    
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

extension GroupDetailsShowViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.array_ParticipantsInfo.count        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
        
            let cell: TableViewCellGroupProfile = tableView.dequeueReusableCell(withIdentifier: "TableViewCellGroupProfile") as! TableViewCellGroupProfile
            
            if let groupImage = groupMetaData?["group_imageURL"] as? String {
                cell.imageView_Profile.sd_setImage(with: URL(string: groupImage), placeholderImage: UIImage(named: "ic_no_image"))
            }
            
            return cell
            
        } else {
        
            let cell: TableViewCellGroupParticipants = tableView.dequeueReusableCell(withIdentifier: "TableViewCellGroupParticipants") as! TableViewCellGroupParticipants
            
            cell.selectionStyle = .none
            
            let participantsObj: ParticipantsInfo = self.array_ParticipantsInfo[indexPath.row]
            
            if let participantsProfile = participantsObj.avatarImage {
                cell.imageView_Profile.sd_setImage(with: URL(string: participantsProfile), placeholderImage: UIImage(named: "ic_no_image"))
            }
            
            if let participantsName = participantsObj.userName {
                cell.label_Name.text = participantsName
            }
            
            return cell
            
        }
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.section == 1 {
    
            if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
                
                let authUserID: String = String(userInfoModel.id ?? 0)
                
                let participantsObj: ParticipantsInfo = self.array_ParticipantsInfo[indexPath.row]

                
                if let userID = participantsObj.userId {
                    
                    if authUserID != userID {
                        let userModel = AUserInfoModel(id: Int(userID)!)
                        self.showUserProfile(userModel)
                    }
                }
                
            }
            
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 140 : 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 35.0 : 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        if section != 0 {
        
            let headerView = UIView()
            
            headerView.backgroundColor = UIColor.clear
            
            let subview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
            
            subview.backgroundColor = UIColor.clear
            
            
            let labelText = UILabel(frame: CGRect(x: 8, y: 8, width: tableView.frame.size.width, height: 22))
            
            labelText.text = "\(self.array_ParticipantsInfo.count)" + " PARTICIPANTS"
            
            labelText.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)
            
            labelText.textColor = UIColor.lightGray
            
            subview.addSubview(labelText)
            
            
            headerView.addSubview(subview)
            
            return headerView
            
        } else {
        
            let headerView = UIView()
            
            headerView.backgroundColor = UIColor.clear
            
            return headerView
            
        }
    
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section != 0 {
            
            let footerView = UIView()
            
            footerView.backgroundColor = UIColor.clear
            
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
            
            lineView.backgroundColor = UIColor.lightGray
            
            footerView.addSubview(lineView)
            
            return footerView
            
        } else {
            
            let footerView = UIView()
            
            footerView.backgroundColor = UIColor.clear
            
            return footerView
            
        }
        
    }
    
    
}

