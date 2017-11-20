//
//  SignUpBirthdayViewController.swift
//  App411
//
//  Created by osvinuser on 6/16/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class SignUpBirthdayViewController: UIViewController {

    // private outlet
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    @IBOutlet fileprivate var buttonNext: UIButton!
    
    
    var params = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.resetViewProperties()
        
        self.setViewBackground()
        
        tableView_Main.register(UINib(nibName: "TableViewCellLabel", bundle: nil), forCellReuseIdentifier: "TableViewCellLabel")
        tableView_Main.register(UINib(nibName: "TableViewCellDateOfBirth", bundle: nil), forCellReuseIdentifier: "TableViewCellDateOfBirth")

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueDOB" {
            let viewController = segue.destination as! SignUpPasswordViewController
            viewController.params = params
        }
    }
 

}

extension SignUpBirthdayViewController: UITableViewDelegate, UITableViewDataSource, TableViewCellDateOfBirthDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
        
            let cell:TableViewCellLabel = tableView.dequeueReusableCell(withIdentifier: "TableViewCellLabel") as! TableViewCellLabel
            
            cell.label_Text.text = params["dob"] == "" ? "Please select DOB" : params["dob"]
            
            cell.selectionStyle = .none
            
            return cell
            
        } else {
        
            let cell:TableViewCellDateOfBirth = tableView.dequeueReusableCell(withIdentifier: "TableViewCellDateOfBirth") as! TableViewCellDateOfBirth
            
            cell.delegate = self
            
            cell.selectionStyle = .none
            
            cell.datePick_Birthday.maximumDate = NSDate() as Date

            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? 50 : 216
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 44.0 : 0.1;
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.5
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let hearderView: UIView = UIView()
            
            hearderView.backgroundColor = UIColor.clear
            
            let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 2, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
            
            label_Title.text = "Add your Birthday"
            
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
        
        hearderView.backgroundColor = UIColor.darkGray
        
        return hearderView
        
    }
    
    
    //MARK:- Delegates
    func getDateFromDatePicker(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let selectedDate = dateFormatter.string(from: sender.date)
        params["dob"] = selectedDate
    
        tableView_Main.reloadSections(IndexSet(integer: 0), with: .automatic)
        self.buttonSelected()
        
    }
    
}

