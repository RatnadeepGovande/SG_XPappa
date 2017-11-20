//
//  NewsViewController.swift
//  App411
//
//  Created by osvinuser on 10/6/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, ShowAlert {

    @IBOutlet var collectionView_Main: UICollectionView!
    @IBOutlet var tableView_Main: UITableView!
    
    fileprivate var arraySourcesList: [Dictionary<String, AnyObject>] = []
    fileprivate var newsDict = Dictionary<String, AnyObject>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TableViewCellNewList
        if Reachability.isConnectedToNetwork() == true {
            
            self.getSourcesFromApi()

        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
        tableView_Main.register(UINib(nibName: "TableViewCellNewList", bundle: nil), forCellReuseIdentifier: "TableViewCellNewList")

        collectionView_Main.register(UINib(nibName: "SourcesCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SourcesCollectionViewCell")
        
        let sizeMake = CGSize(width: 1, height: 1)
        
        if let flowLayout = collectionView_Main.collectionViewLayout as? UICollectionViewFlowLayout { flowLayout.estimatedItemSize = sizeMake }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Get Event List API
    internal func getSourcesFromApi() {
     
        //Methods.sharedInstance.showLoader()
        
        WebServiceClass.sharedInstance.dataTask(urlName: NewsApiConstant.getSources, method: "GET", params: "") { (success, response, errorMsg) in
            
            if success == true {
                
                // Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["status"] as? String {
                        
                        //  print(responeCode)
                        self.arraySourcesList.removeAll()
                        
                        if responeCode == "ok" {
                            
                            if let eventList = jsonResult["sources"] as? [Dictionary<String, AnyObject>] {
                                
                                self.arraySourcesList = eventList
                                
                            }
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                        self.collectionView_Main.reloadData()

                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    
    
    // MARK: - Get Event List API
    internal func getNewsListFromChannelApi(channelID:String) {
        
        Methods.sharedInstance.showLoader()
        //https://newsapi.org/v1/articles?source=techcrunch&apiKey=bdd8a8a2aa7049988a3cd27441db0e87
        let paramsStr = NewsApiConstant.getNewsFromChannel + "source=\(channelID)&apiKey=\(NewsApiConstant.newsApiKey)"

        WebServiceClass.sharedInstance.dataTask(urlName: paramsStr, method: "GET", params:"") { (success, response, errorMsg) in
            
            if success == true {
                
                 Methods.sharedInstance.hideLoader()
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    // do whatever with jsonResult
                    if let responeCode = jsonResult["status"] as? String {
                        
                        //  print(responeCode)
                        self.newsDict.removeAll()
                        
                        if responeCode == "ok" {
                            
                            self.newsDict = jsonResult
                           
                        } else {
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                                self.showAlert(jsonResult["message"] as? String ?? "")
                            })
                            
                        }
                        
                        self.tableView_Main.reloadData()
                        
                    } else {
                        
                        print("Worng data found.")
                        
                    }
                    
                }
                
            } else {
                
                Methods.sharedInstance.hideLoader()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.showAlert(errorMsg)
                })
                
            }
            
        }
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let eventDetailsObj = segue.destination as! NewsDetailViewController
        eventDetailsObj.newsDetailDict = sender as! Dictionary<String, AnyObject>
    }
    

}

extension NewsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arraySourcesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SourcesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourcesCollectionViewCell", for: indexPath) as! SourcesCollectionViewCell
        
        // Get Model Data.
        let dict = self.arraySourcesList[indexPath.item]
        cell.labelSources.preferredMaxLayoutWidth = 50
        cell.labelSources.text = dict["name"] as? String
        cell.backgroundColor = UIColor.red
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let dict = self.arraySourcesList[indexPath.item]
        let nameChannelText = dict["name"] as? String ?? ""
        
        // Get Model Data.
        let size: CGSize = nameChannelText.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])

        return CGSize(width: size.width, height: collectionView.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Tap on image view.")
        // Get Model Data.
        let dict = self.arraySourcesList[indexPath.item]
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.getNewsListFromChannelApi(channelID: dict["id"] as? String ?? "")
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let newsDictModel = self.newsDict["articles"] as? [Dictionary<String, AnyObject>] ?? []

        return newsDictModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableViewCellNewList = tableView.dequeueReusableCell(withIdentifier: "TableViewCellNewList") as! TableViewCellNewList
        
        //1. get news array from Dict
        let newsDictModel = self.newsDict["articles"] as? [Dictionary<String, AnyObject>] ?? []
        
        //2. get news dict from array
        let newsInfoModel = newsDictModel[indexPath.row]
        
        //3. show the selected news to label
        cell.titleLabel.text = self.newsDict["source"] as? String ?? ""
        
        //4. show the data for selected news channel
         let upadateFormat  = newsInfoModel["publishedAt"] as? String ?? ""
        
        if let date = self.getDateFormatterFromServer(stringDate: upadateFormat, dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ") {
            cell.dateLabel.text  = date.timeAgo
        }
        
        cell.subtitleLabel.text = newsInfoModel["title"] as? String ?? ""
        cell.descriptionLabel.text = newsInfoModel["description"] as? String ?? ""
        cell.avatarImage.sd_setImage(with: URL(string: newsInfoModel["urlToImage"] as? String ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1. get news array from Dict
        let newsDictModel = self.newsDict["articles"] as? [Dictionary<String, AnyObject>] ?? []
        
        //2. get news dict from array
        let newsInfoModel = newsDictModel[indexPath.row]
        
        self.performSegue(withIdentifier: "newsDetail", sender: newsInfoModel)
    }
    
}
