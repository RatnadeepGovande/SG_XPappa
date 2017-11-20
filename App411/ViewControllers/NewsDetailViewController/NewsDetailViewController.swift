//
//  NewsDetailViewController.swift
//  App411
//
//  Created by osvinuser on 10/10/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {

    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptiontextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var openUrlButton: UIButton!

    var newsDetailDict = Dictionary<String, AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showNewsDetail()
    }
    
    func showNewsDetail() {
        
        //3. show the selected news to label
        titleLabel.text = self.newsDetailDict["title"] as? String ?? ""
        
        //4. show the data for selected news channel
        let upadateFormat  = self.newsDetailDict["publishedAt"] as? String ?? ""
        
        if let date = self.getDateFormatterFromServer(stringDate: upadateFormat, dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ") {
            dateLabel.text  = date.timeAgo

        }
        
        descriptiontextView.text = self.newsDetailDict["description"] as? String ?? ""
        avatarImage.sd_setImage(with: URL(string: self.newsDetailDict["urlToImage"] as? String ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
        
        self.openUrlButton.setTitle(self.newsDetailDict["url"] as? String ?? "", for: .normal)
    }
    
    
    @IBAction func openURLFromButton(_sender : UIButton) {
        
        guard let url = URL(string: self.newsDetailDict["url"] as? String ?? "") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

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
