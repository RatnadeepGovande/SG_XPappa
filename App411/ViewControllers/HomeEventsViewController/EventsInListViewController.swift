//
//  EventsInListViewController.swift
//  App411
//
//  Created by osvinuser on 6/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class EventsInListViewController: UIViewController, ShowAlert {

    @IBOutlet var collectionView_Main: UICollectionView!
    
    var array_eventList = [ACreateEventInfoModel]()

    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        self.collectionView_Main?.addSubview(refreshControl) // not required when using UITableViewController

        // Do any additional setup after loading the view.
        collectionView_Main.register(UINib(nibName: "HomeEventCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeEventIdentifier")

        // Set View Background.
        self.setViewBackground()
        self.reloadEventList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEventList), name: NSNotification.Name(rawValue: "eventListReloadNotification"), object: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Reload API
    func reloadAPI() {
        
        // Check network connection.
        if Reachability.isConnectedToNetwork() == true {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventListAPIReloadNotification"), object: self, userInfo: ["":""])
            
        } else {
            
            // Show Internet Connection Error
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    
    // MARK: - reload Event List.

    internal func reloadEventList() {
        self.array_eventList = Singleton.sharedInstance.array_eventList
        DispatchQueue.main.async {
            
            self.refreshControl.endRefreshing()

            self.collectionView_Main.reloadData()
        }
    }
    
    /*
    // MARK: - refresh control For API
    internal func refreshControlAPI() {
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAPI), for: .valueChanged)
        tableView_Main.addSubview(refreshControl) // not required when using UITableViewController
        
        // First time automatically refreshing.
        refreshControl.beginRefreshingManually()
        self.perform(#selector(self.reloadAPI), with: nil, afterDelay: 0)
        
    }
    */
    
    
    
    
    // MARK: - Did  Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueEventDetails" {
            
            let eventDetailsObj = segue.destination as! EventDetailViewController
            eventDetailsObj.eventModelData = sender as! ACreateEventInfoModel
        } else {
            
            let eventDetailsObj = segue.destination as! CauseDetailViewController
            eventDetailsObj.eventModelData = sender as! ACreateEventInfoModel

        }
        
    }

}

extension EventsInListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.array_eventList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let homeCell: HomeEventCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeEventIdentifier", for: indexPath) as! HomeEventCollectionViewCell
        
        // Configure the cell
        homeCell.layoutIfNeeded()
        homeCell.view_Shadow.layer.cornerRadius = (homeCell.view_Shadow.frame.size.width)/2
        homeCell.imageView_EventImage.layer.cornerRadius = (homeCell.imageView_EventImage.frame.size.width)/2
        homeCell.backgroundLabelView.layer.cornerRadius = (homeCell.backgroundLabelView.frame.size.width)/2
        
      //  let homeCell: HomeEventCollectionViewCell = cell as! HomeEventCollectionViewCell
        
        let aEventInfoModel: ACreateEventInfoModel = self.array_eventList[indexPath.item]
        
        if aEventInfoModel.event_category_id == 10 {
            
            homeCell.groupImage.isHidden = false
            homeCell.groupImage.image = #imageLiteral(resourceName: "ic_heart_pink")
            
        } else {
            homeCell.groupImage.image = #imageLiteral(resourceName: "ic_dummy_users")
            
            //check whether event is group or not
            homeCell.groupImage.isHidden = aEventInfoModel.group_event_flag == false ? true : false
        }
        
        // Check Video.
        if aEventInfoModel.event_video_flag == "1" {
           
            homeCell.imageView_EventImage.sd_setImage(with: URL(string: aEventInfoModel.event_Thumbnail ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

        } else {

            homeCell.imageView_EventImage.sd_setImage(with: URL(string: aEventInfoModel.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

        }
        
        
        let eventDate: Date = (aEventInfoModel.start_event_date ?? "").eventDataFormat()
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, MMM d, 'at' h:mm a"
        
        let eventDateStr: String = dateFormatterGet.string(from: eventDate)
        
        //show the event title in bold color and date in simple text
        let formattedString = NSMutableAttributedString()
        formattedString.bold(aEventInfoModel.title ?? "", fontSize: 20).mid("\n" + (aEventInfoModel.sub_title ?? ""), fontSize: 16).normal("\n" + eventDateStr, fontSize: 13)
        
        homeCell.label_EventData.attributedText = formattedString
        
        
        return homeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.view.backgroundColor = UIColor.white
        
        let eventDict = self.array_eventList[indexPath.item]
        
        if eventDict.event_category_id == 10 {
            
            self.performSegue(withIdentifier: "segueCauseDetails", sender: eventDict)

        } else {
            
            self.performSegue(withIdentifier: "segueEventDetails", sender: eventDict)

        }

    }
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding : CGFloat = 30.0
        let collectionViewSize = collectionView_Main.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        
    }
    
}

