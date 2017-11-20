//
//  EventsInListCardViewController.swift
//  App411
//
//  Created by osvinuser on 6/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
//import Koloda

class EventsInListCardViewController: UIViewController, ShowAlert {

    @IBOutlet var kolodaView: KolodaView!
    fileprivate var array_eventList = [ACreateEventInfoModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEventList), name: NSNotification.Name(rawValue: "eventListReloadNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEventList), name: NSNotification.Name(rawValue: "updateSaveEvent"), object: nil)

        self.reloadEventList()
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal

        self.setViewBackground()
        self.setCardViewProperties()
        
    }
    
    func reloadEventList() {
        
        self.array_eventList.removeAll()
        self.array_eventList = Singleton.sharedInstance.array_eventList
        self.kolodaView.dataSource = self
        self.kolodaView.delegate = self
    }

    func setCardViewProperties() {
    
        kolodaView.layer.masksToBounds = false
        kolodaView.layer.shadowColor = UIColor.darkGray.cgColor
        kolodaView.layer.shadowOpacity = 0.5
        kolodaView.layer.shadowOffset = CGSize(width: 0, height: 0)
        kolodaView.layer.shadowRadius = 2
        
    }
    
    // MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    internal func saveEventForUser(eventId:Int, isSavedEvent:Bool, cardIndex: Int) {
        
            guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
                return
            }
        
        //auth_token,event_id,status =1 favourite status =0 for unfavourite

         //   Methods.sharedInstance.showLoader()
        
            let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isSavedEvent == false ? 0 : 1)"
            print(paramsStr)
            
            WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.saveEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
                
//                Methods.sharedInstance.hideLoader()

                if success == true {
                    
                    if let jsonResult = response as? Dictionary<String, AnyObject> {
                        
                        print(jsonResult)
                        
                        if let responeCode = jsonResult["responseCode"] as? Bool {
                            print(responeCode)
                            
                            let customCard : CustomCardView = self.kolodaView.viewForCard(at: cardIndex) as! CustomCardView
                            
                            customCard.saveEventButton.isSelected = isSavedEvent
                            
                            self.array_eventList[cardIndex].event_favorite = isSavedEvent
                            
                            self.showAlert(jsonResult["message"] as? String ?? "")
                           
                        } else {
                            
                            print("Worng data found.")
                            
                        }
                    }
                } else {
                    
                    self.showAlert(errorMsg)
                }
            }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueEventDetails" {
            let viewController = segue.destination as! EventDetailViewController
            viewController.eventModelData = sender as? ACreateEventInfoModel
        }
    }
    

}

extension EventsInListCardViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        koloda.reloadData()

    }
    
    func koloda(_ koloda: KolodaView, clickOnfavouriteButton index: Int) {
    
        let aEventInfoModel: ACreateEventInfoModel = self.array_eventList[index]
        
        if Reachability.isConnectedToNetwork() == true {
            
            print(aEventInfoModel.event_favorite ?? "Data Not Found")
            
            self.saveEventForUser(eventId: aEventInfoModel.id ?? 0, isSavedEvent: aEventInfoModel.event_favorite! == true ? false : true, cardIndex: index)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
    }

    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        let aEventInfoModel: ACreateEventInfoModel = self.array_eventList[index]
        self.navigationController?.view.backgroundColor = UIColor.white
        
        self.performSegue(withIdentifier: "segueEventDetails", sender: aEventInfoModel)
    }

}

extension EventsInListCardViewController: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }

    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return self.array_eventList.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let customCardView: CustomCardView = CustomCardView(frame: CGRect(x: 0, y: 0, width: kolodaView.frame.size.width, height: kolodaView.frame.size.height))
        
        // Event Model Class.
        let aEventInfoModel: ACreateEventInfoModel = self.array_eventList[index]
        
        // Configure the cell
        customCardView.layoutIfNeeded()
        //        customCardView.view_Shadow.layer.cornerRadius = (cell.view_Shadow.frame.size.width)/2
        customCardView.eventImage.layer.cornerRadius = (customCardView.eventImage.frame.size.width)/2
        customCardView.imageBackgroundView.layer.cornerRadius = (customCardView.imageBackgroundView.frame.size.width)/2
        
        //set saveEventButton selected according to data
        customCardView.saveEventButton.isSelected = aEventInfoModel.event_favorite!
        customCardView.saveEventButton.tag = index
        
        // Check Video.
        if aEventInfoModel.event_video_flag == "1" {
            
            customCardView.eventImage.sd_setImage(with: URL(string: aEventInfoModel.event_Thumbnail ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        } else {
            
            customCardView.eventImage.sd_setImage(with: URL(string: aEventInfoModel.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

        }

        
        let eventObject = self.getEventData(aEventInfoModel: aEventInfoModel)

        //show eventTitle
        customCardView.titleOfEventLabel.attributedText = eventObject.eventTitle
        
        //show event date and views count
        customCardView.dateLabel.attributedText = eventObject.eventDate
        
        return customCardView
    
    }

    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func getEventData(aEventInfoModel : ACreateEventInfoModel) -> (eventTitle: NSMutableAttributedString, eventDate: NSMutableAttributedString) {
        
        // Event Title and SubTitle.
        let formattedStringEventTitle = NSMutableAttributedString()
        formattedStringEventTitle.bold(aEventInfoModel.title ?? "", fontSize: 20).mid("\n" + (aEventInfoModel.sub_title ?? ""), fontSize: 16)
        

        // Event Date and Event Views.
        //create and NSTextAttachment and add your image to it.
        let formattedStringEventDateAndView :NSMutableAttributedString = NSMutableAttributedString()
        
        // Convert Event Details.
        let eventDate: Date = (aEventInfoModel.start_event_date ?? "").eventDataFormat()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "EEEE, MMM d, 'at' h:mm a"
        
        let eventDateStr: String = dateFormatterGet.string(from: eventDate)
 
        formattedStringEventDateAndView.bold(eventDateStr + "\n", fontSize: 18)
        
        
        // Event Views Count.
        let eventView = aEventInfoModel.event_views ?? 0
        let evenPhrases = eventView == 0 || eventView > 1 ? "s" :""
        let viewsCount = " \(eventView)" + " " + "\("view")" + evenPhrases
        
        
        let attachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "ViewerIcon")
        
        var bounds = CGRect()
        bounds.origin = CGPoint(x: 0, y: -8);
        bounds.size = #imageLiteral(resourceName: "ViewerIcon").size
        
        attachment.bounds = bounds


        //put your NSTextAttachment into and attributedString
        let attString = NSAttributedString(attachment: attachment)
        //add this attributed string to the current position.
        formattedStringEventDateAndView.insert(attString, at: eventDateStr.characters.count+1)
        
        formattedStringEventDateAndView.normal(viewsCount, fontSize: 16)

    
        return (formattedStringEventTitle, formattedStringEventDateAndView)
        
    }
    
}
