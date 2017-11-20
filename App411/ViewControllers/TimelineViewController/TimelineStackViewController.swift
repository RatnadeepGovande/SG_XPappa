//
//  TimelineStackViewController.swift
//  App411
//
//  Created by osvinuser on 10/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TimelineStackViewController: UIViewController {

    @IBOutlet var avatarImageButton: DesignableButton!
    @IBOutlet var timeLineView: UIView!
    @IBOutlet var NewsView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageButton.applyNavBarConstraints(size: (width: 30, height: 30))
        self.updateUserProfilePic()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserProfilePic), name: NSNotification.Name(rawValue: "updateProfilePic"), object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    internal func updateUserProfilePic() {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        avatarImageButton.sd_setImage(with: URL(string: userInfoModel.image ?? ""), for: .normal)
        
    }
    
    @IBAction func userProfilePic(_ sender: UIButton) {
        
        //Here you can initiate your new ViewController
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        self.clickOnUserName(user:userInfoModel)
    }
    
    
    @IBAction func changeViewController(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            NewsView.isHidden = false
            timeLineView.isHidden = true

        } else {
            
            NewsView.isHidden = true
            timeLineView.isHidden = false
        }
        
    }
    
    func clickOnUserName(user: AUserInfoModel) {
        self.showUserProfile(user)
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
