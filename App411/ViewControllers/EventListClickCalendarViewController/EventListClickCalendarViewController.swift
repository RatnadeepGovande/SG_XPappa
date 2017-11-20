//
//  EventListClickCalendarViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class EventListClickCalendarViewController: UIViewController {

    @IBOutlet fileprivate var tableView_Main: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
   
        // Do any additional setup after loading the view.
        tableView_Main.register(UINib(nibName: "TableViewCellCalendarEvent", bundle: nil), forCellReuseIdentifier: "TableViewCellCalendarEvent")
        
        self.setViewBackground()
        
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

extension EventListClickCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellCalendarEvent = tableView.dequeueReusableCell(withIdentifier: "TableViewCellCalendarEvent") as! TableViewCellCalendarEvent
        
        return cell
        
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
    
}
