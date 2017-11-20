//
//  SignUpProfilePicViewController.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import Cloudinary
import ObjectMapper
import MobileCoreServices


class SignUpProfilePicViewController: UIViewController, ShowAlert {

    // private outlet
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    @IBOutlet var buttonNext: UIButton!

    
    var params = [String: String]()
    
    var imageFullSize = UIImage()
    var imageThumbnailSize = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.resetViewProperties()
        
        self.setViewBackground()
        
        tableView_Main.register(UINib(nibName: "TableViewCellSignUpProfilePic", bundle: nil), forCellReuseIdentifier: "TableViewCellSignUpProfilePic")
        
    }

    // Mark:- Reset View Properties
    func resetViewProperties() {
        self.buttonUnSelected()
    }
    
    internal func buttonSelected() {
        buttonNext.isUserInteractionEnabled = true
        buttonNext.backgroundColor = appColor.appButtonSelectedColor
    }
    
    internal func buttonUnSelected() {
        buttonNext.isUserInteractionEnabled = false
        buttonNext.backgroundColor = appColor.appButtonUnSelectedColor
    }
    
    
    
    //MARK:- IBAtion.
    @IBAction func nextProfileButtonAction(_ sender: Any) {
        
        let decoded                         = UserDefaults.standard.object(forKey: "userinfo") as! Data
        let userDataStr: String             = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! String
        
        if let userInfoObj = Mapper<AUserInfoModel>().map(JSONString: userDataStr) {
        
            if Reachability.isConnectedToNetwork() == true {
                
                let profileName: String = "profile_user_id_" + String(userInfoObj.id!)
                self.uploadProfilePicName(imageName: profileName)
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
        }
        
    }
    
    
    //MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProfileNext" || segue.identifier == "segueProfileNotNow" {
            let viewController = segue.destination as! SignUpPasswordViewController
            viewController.params = params
        }
        
    }
 

}

extension SignUpProfilePicViewController: UITableViewDelegate, UITableViewDataSource, TableViewCellSignUpProfilePicDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellSignUpProfilePic = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSignUpProfilePic") as! TableViewCellSignUpProfilePic
        
        cell.delegate = self
        
        cell.selectionStyle = .none
        
        cell.backgroundColor = UIColor.clear
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 200.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 44.0 : 0.1;
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
            
            label_Title.text = "Pick a profile picture"
            
            label_Title.textColor = UIColor.darkGray
            
            label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 22)
            
            hearderView.addSubview(label_Title)
            
            return hearderView
            
        } else {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            return hearderView
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    
    //MARK:- Cell Delegates
    func uploadProfilePicClick(sender: UIButton) {
    
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            print("Take Photo")
            self.openImagePickerViewController(sourceType: .camera, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Choose Photo", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String])
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] else {
            picker.dismiss(animated: true, completion: nil)
            return
        }

        imageFullSize = image as! UIImage
        
        let imageThumbnail = (image as! UIImage).createImageThumbnailFromImage()
        imageThumbnailSize = imageThumbnail
        
        let cell: TableViewCellSignUpProfilePic = tableView_Main.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellSignUpProfilePic
        cell.imageView_Images.image = imageThumbnail
        
        self.buttonSelected()
        
        picker.dismiss(animated: true, completion: nil)
    
    }
    
}

