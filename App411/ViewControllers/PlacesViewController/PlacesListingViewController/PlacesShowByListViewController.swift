//
//  PlacesShowByListViewController.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class PlacesShowByListViewController: UIViewController {
    
    @IBOutlet var collectionView_Main: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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

extension PlacesShowByListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Singleton.sharedInstance.array_PlacesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PlacesListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlacesListCollectionViewCell", for: indexPath) as! PlacesListCollectionViewCell
        
        // Configure the cell
        cell.layoutIfNeeded()
        cell.view_Shadow.layer.cornerRadius = (cell.view_Shadow.frame.size.width)/2
        cell.imageView_EventImage.layer.cornerRadius = (cell.imageView_EventImage.frame.size.width)/2
        cell.backgroundLabelView.layer.cornerRadius = (cell.backgroundLabelView.frame.size.width)/2
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cellCustom = cell as? PlacesListCollectionViewCell {
            
            let dict = Singleton.sharedInstance.array_PlacesList[indexPath.item]
            
            if let image = dict["icon"] as? String {
                cellCustom.imageView_EventImage.sd_setImage(with: URL(string: image), placeholderImage: nil)
            }
            
            if let name = dict["name"] as? String {
                cellCustom.label_EventData.text = name
            }
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict = Singleton.sharedInstance.array_PlacesList[indexPath.item]
        
        guard let geometry = dict["geometry"] as? Dictionary<String, AnyObject>  else {
            return
        }
        
        guard let location = geometry["location"] as? Dictionary<String, AnyObject>  else {
            return
        }
        
        guard let latitude = location["lat"] as? Double else {
            return
        }
        
        guard let logitude = location["lng"] as? Double else {
            return
        }
        
        let directionStr = "http://maps.google.com/maps?daddr=" + "\(latitude)" + "," + "\(logitude)"
        Methods.sharedInstance.openURL(url: URL(string: directionStr)!)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding : CGFloat = 30.0
        let collectionViewSize = collectionView_Main.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
}

