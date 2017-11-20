//
//  TableViewCellDatePicker.swift
//  App411
//
//  Created by osvinuser on 7/12/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellDatePickerDelegate {
    func selectedDateAndTime(datePicker: UIDatePicker)
}

class TableViewCellDatePicker: UITableViewCell {

    @IBOutlet var datePicker_Outlet: UIDatePicker!
    
    var delegate: TableViewCellDatePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func datepickerSetMinimumDate(row:Int, startDate: Date?) {
        
        if row == 104  {
            
            let secondsInMonth: TimeInterval = 24 * 60 * 60
            datePicker_Outlet.minimumDate = Date(timeInterval: secondsInMonth , since: Date())
            
            if let startDateEvent = startDate {
                datePicker_Outlet.setDate(startDateEvent, animated: true)
            }
            
        } else {
            
            if let startDateEvent = startDate {
                
                datePicker_Outlet.minimumDate = Date(timeInterval: 3600 , since: startDateEvent)
                
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        delegate?.selectedDateAndTime(datePicker: datePicker_Outlet)
        
    }
}
