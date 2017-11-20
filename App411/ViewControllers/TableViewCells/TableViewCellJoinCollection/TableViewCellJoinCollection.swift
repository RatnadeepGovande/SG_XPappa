//
//  TableViewCellJoinCollection.swift
//  App411
//
//  Created by osvinuser on 7/28/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewCellJoinCollectionDelegate {
    func isGoingAction(_ sender: UIButton)
    
    func isClickOnUser(_ userData: AUserInfoModel)
}

class TableViewCellJoinCollection: UITableViewCell {

    @IBOutlet var goingButton: DesignableButton!
    @IBOutlet var joinCollectionView: UICollectionView!
    var delegate :TableViewCellJoinCollectionDelegate?
    var eventUserJoinArray = [AUserInfoModel]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinCollectionView.register(UINib(nibName: "JoinedEventCell", bundle: nil), forCellWithReuseIdentifier: "JoinedEventCell")
    }
    
    internal func updateJoinCollection(istrue:Bool) {
        
        if istrue {
            joinCollectionView.reloadData()
        }
    }
    
    @IBAction func goingAction(_ sender: UIButton) {
        
        self.delegate?.isGoingAction(sender)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TableViewCellJoinCollection: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventUserJoinArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JoinedEventCell", for: indexPath) as! JoinedEventCell
        
        let dict = self.eventUserJoinArray[indexPath.item]
        
        cell.avatarImage.sd_setImage(with: URL(string: dict.image ?? ""), placeholderImage: UIImage(named: "avatarSingleIcon"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict = self.eventUserJoinArray[indexPath.item]
        
        self.delegate?.isClickOnUser(dict)
        
    }
    
    
}

