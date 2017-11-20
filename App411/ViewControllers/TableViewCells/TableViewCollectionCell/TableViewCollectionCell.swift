//
//  TableViewCollectionCell.swift
//  App411
//
//  Created by osvinuser on 7/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import LayerKit
import Atlas

class TableViewCollectionCell: UITableViewCell {

    @IBOutlet var collectionView_Main: UICollectionView!
    
    var array_SelectedParticipants = [AnyHashable]()
    
    var createGroupButton: UIBarButtonItem!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView_Main.register(UINib(nibName: "GroupChatCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "GroupChatCollectionViewCell")
        
        self.collectionView_Main.delegate = self
        self.collectionView_Main.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Func
    func reloadCollectionView() {
        self.collectionView_Main.reloadData()
    }
    
}

extension TableViewCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GroupChatCollectionViewCellDelegate {
    
    // MARK: - Data source and delegate.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_SelectedParticipants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: GroupChatCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupChatCollectionViewCell", for: indexPath) as! GroupChatCollectionViewCell
        
        cell.delegate = self
        
        cell.crossButtonClick.tag = indexPath.row
        
        
        let participant: ATLParticipant = array_SelectedParticipants[indexPath.row] as! ATLParticipant
        
        cell.imageView_Profile.sd_setImage(with: participant.avatarImageURL, placeholderImage: nil)
        
        cell.label_Text.text = participant.displayName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfCellsPerRow: CGFloat = 4
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (Constants.ScreenSize.SCREEN_WIDTH - max(0, numberOfCellsPerRow - 1)*horizontalSpacing)/numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: (cellWidth+(cellWidth*0.20)))
            
            return flowLayout.itemSize
        }
        
        return CGSize(width: 0, height: 0)
        
    }
    
    
    // MARK: - delegate profile from array.
    func clickOnCrossButtonClick(sender: UIButton) {
        array_SelectedParticipants.remove(at: sender.tag)
        self.collectionView_Main.reloadData()
        
        self.createGroupButton.isEnabled = array_SelectedParticipants.count > 0 ? true : false
        
    }
    
}
