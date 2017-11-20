//
//  CalendarViewController.swift
//  App411
//
//  Created by osvinuser on 6/22/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, ShowAlert {

    @IBOutlet weak var calender_view: FSCalendar!
    @IBOutlet weak var calenderTableView: UITableView!
    
    lazy var eventsArray = [ACreateEventInfoModel]()

    var dateArray = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calenderTableView.register(UINib(nibName: "TableViewCellSaveEvents", bundle: nil), forCellReuseIdentifier: "TableViewCellSaveEvents")
        
        self.setupCalender()
        
        let parameters = self.getMonthNameAndYearValue(dateObject: Date())

        self.calenderServiceFunction(month: parameters.monthName, yearInt: "\(parameters.yearValue)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    //MARK:- Class Functions
    func setupCalender() {
        
        /* Calender setup */
        calender_view.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        calender_view.delegate = self
        calender_view.select(calender_view.currentPage)
        
    }
    
    internal func calenderServiceFunction(month: String, yearInt: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            
          self.getCalendarDatesServiceFunction(month:month, yearInt: yearInt)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
    }
    
    internal func calenderEventDetailServiceFunction(date: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.getParticularDateEventFunction(date: date)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
    }
    
    internal func getMonthNameAndYearValue(dateObject: Date) -> (monthName: String, yearValue: Int) {
        
        let currentMonthAndYear = Calendar.current.dateComponents([.month, .year], from: dateObject)
        
        let dateFormatter = DateFormatter()
        let months = dateFormatter.monthSymbols
        let monthSymbol = months?[currentMonthAndYear.month! - 1] // month - from your date components
        
        return (monthSymbol ?? "", currentMonthAndYear.year ?? 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    
}

extension CalendarViewController : FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let convertedDate = self.convertDateToString(dateInstance: date, dateformat: "MMM d, yyyy") ?? ""
        
        if dateArray.contains(where: { $0 as? String == convertedDate }) {
            return 1
        } else {
           return 0
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let parameters = self.getMonthNameAndYearValue(dateObject: calendar.currentPage)
        
        self.calenderServiceFunction(month: parameters.monthName, yearInt: "\(parameters.yearValue)")
        
    }
    
    func convertDateToString(dateInstance: Date, dateformat:String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateformat
        
        let date = dateFormatter.string(from: dateInstance)
        return date
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        
        //set the selected value into string
        let convertedDate = self.convertDateToString(dateInstance: date, dateformat: "MMM d, yyyy") ?? ""
        
        if dateArray.contains(where: { $0 as? String == convertedDate }) {
            self.calenderEventDetailServiceFunction(date: convertedDate)
        } else {
            self.eventsArray.removeAll()
            self.calenderTableView.reloadData()
        }
        
    }
    
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorForDate date: Date) -> UIColor? {
        
        let convertedDate = self.convertDateToString(dateInstance: date, dateformat: "MMM d, yyyy") ?? ""
        
        if dateArray.contains(where: { $0 as? String == convertedDate }) {
            return UIColor.black
        }
        
        return UIColor.red
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        //Also, remember that scheduled workouts must have a yellow dot. When the user completes the workout, the dot is then green. If a user misses a workout, the dot will then become red.
        let imageName = UIImage()

        return imageName
        
    }
    
}
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.eventsArray.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellSaveEvents = tableView.dequeueReusableCell(withIdentifier: "TableViewCellSaveEvents") as! TableViewCellSaveEvents
        
        cell.avatarImage.layer.cornerRadius = (cell.avatarImage.frame.size.width)/2
        cell.avatarImage.clipsToBounds = true
        
        let aEventInfoModel: ACreateEventInfoModel = self.eventsArray[indexPath.row]
        
        // If event_image contains video then below condition will execute or vice - versa.
        // Check Video.
        if aEventInfoModel.event_video_flag == "1" {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.event_Thumbnail ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        } else {
            
            cell.avatarImage.sd_setImage(with: URL(string: aEventInfoModel.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
            
        }
        
        
        cell.eventTitleLabel.text = aEventInfoModel.title
        
        cell.descriptionLabel.text = aEventInfoModel.start_event_date! + "\n" + aEventInfoModel.event_place_name!
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 100
    
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        return 40
    
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = self.setHeaderView(title: "Events")
        
        return headerView
        
    }
    
    
    // MARK: - Header View.
    
    internal func setHeaderView(title: String) -> UIView {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        let label_Title: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH - 30, height: 40))
        
        label_Title.text = title
        
        label_Title.textColor = UIColor.darkGray
        
        label_Title.font = UIFont(name: FontNameConstants.SourceSansProSemiBold, size: 16)
        
        hearderView.addSubview(label_Title)
        
        return hearderView
        
    }

    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let hearderView: UIView = UIView()
        
        hearderView.backgroundColor = UIColor.clear
        
        return hearderView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.moveToDetailEvent(row: indexPath.row, arrayObject: self.eventsArray)

    }
    
}

