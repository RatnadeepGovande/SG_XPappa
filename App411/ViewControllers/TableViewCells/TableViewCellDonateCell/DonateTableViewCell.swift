//
//  DonateTableViewCell.swift
//  App411
//
//  Created by osvinuser on 9/14/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol DonateTableViewCellDelegate {
    
    func donationMethodType(type: Int8)
    
}

class DonateTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    let donationArray = ["Money", "Food", "Clothes", "Others"]
    var delegate : DonateTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //register Nibs
        collectionView.register(UINib(nibName: "DonateViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DonateViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DonateTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 1
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return donationArray.count
    }
    
    // 2
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DonateViewCell", for: indexPath) as! DonateViewCell
        
        //cell.backgroundColor = UIColor.blue
                
        cell.textDonationLabel?.text = donationArray[indexPath.item]
        
        return cell
    }
    
    // 3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding : CGFloat = 10.0
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2.0, height: 45)
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell : DonateViewCell = collectionView.cellForItem(at: indexPath) as! DonateViewCell
        
        cell.selectedDonationImage.image = #imageLiteral(resourceName: "ic_checkbox_selected")
        
        self.delegate?.donationMethodType(type: Int8(indexPath.item))
    }
    
    // 5
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell : DonateViewCell = collectionView.cellForItem(at: indexPath) as! DonateViewCell
        
        cell.selectedDonationImage.image = #imageLiteral(resourceName: "ic_checkbox_unselected")
    }
    
    
}
