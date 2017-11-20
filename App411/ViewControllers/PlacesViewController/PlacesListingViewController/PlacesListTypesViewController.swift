//
//  PlacesListViewController.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class PlacesListTypesViewController: UIViewController {
    
    
    @IBOutlet var container_PlacesListView: UIView!
    
    @IBOutlet var container_PlacesCardView: UIView!
    
    @IBOutlet var container_PlacesMapView: UIView!
    
    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    @IBOutlet fileprivate var view_LayoutViewOptions: UIView!
    
    
    
    var array_LayoutImages: [String] = ["ListViewIcon", "CardViewIcon", "MapViewIcon"]
    
    fileprivate var isOpenLayoutOption: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewCellLayoutView", bundle: nil), forCellReuseIdentifier: "TableViewCellLayoutView")
        
    }
    
    //MAR:- UIActions.
    @IBAction func clickOnLayoutOption(_ sender: Any) {
        
        if isOpenLayoutOption == false {
            
            self.openLayoutViewController()
            
        } else {
            
            self.closeLayoutViewController()
            
        }
        
    }
    
    
    // MARK:- Layout options open and close.
    
    internal func openLayoutViewController() {
        
        isOpenLayoutOption = true
        
        view_LayoutViewOptions.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH-60, y: -180, width: 60, height: 180)
        self.view.addSubview(self.view_LayoutViewOptions)
        
        UIView.animate(withDuration: 0.25) {
            self.view_LayoutViewOptions.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH-60, y: 0, width: 60, height: 180)
        }
        
    }
    
    internal func closeLayoutViewController() {
        
        isOpenLayoutOption = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view_LayoutViewOptions.frame = CGRect(x: Constants.ScreenSize.SCREEN_WIDTH-60, y: -180, width: 60, height: 180)
        }, completion: { (finish) in
            self.view_LayoutViewOptions.removeFromSuperview()
        })
        
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

extension PlacesListTypesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_LayoutImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellLayoutView = tableView.dequeueReusableCell(withIdentifier: "TableViewCellLayoutView") as! TableViewCellLayoutView
        
        let imageiCon: UIImage = UIImage(named: array_LayoutImages[indexPath.row])!
        
        cell.button_Layout.setImage(imageiCon, for: .normal)
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            container_PlacesListView.isHidden = false
            container_PlacesCardView.isHidden = true
            container_PlacesMapView.isHidden = true
            
            
        case 1:
            container_PlacesListView.isHidden = true
            container_PlacesCardView.isHidden = false
            container_PlacesMapView.isHidden = true
            
            
        case 2:
            container_PlacesListView.isHidden = true
            container_PlacesCardView.isHidden = true
            container_PlacesMapView.isHidden = false
            
        default:
            container_PlacesListView.isHidden = false
            container_PlacesCardView.isHidden = true
            container_PlacesMapView.isHidden = true
            
        }
        
        self.closeLayoutViewController()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
    
}

