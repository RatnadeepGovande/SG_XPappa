//
//  ChooseFlyerViewController.swift
//  App411
//
//  Created by osvinuser on 7/11/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

protocol ChooseFlyerViewControllerDelegate {
    func selectedImageFromList(image: UIImage)
}

class ChooseFlyerViewController: UIViewController, ShowAlert {

    // Variables.
    @IBOutlet var collectionView_FlyerOptions: UICollectionView!
    
    @IBOutlet var collectionView_FlyerList: UICollectionView!
    
    
    var array_CategoryList = [AFilterCategoriesInfoModel]()
    
    var array_FlyerObjList = [AFlyerInfoModel]()
    
    
    var selectedCategory: Int = 0
    
    var array_SelectedFlyerObjList = [AFlyerInfoModel]()
    
    
    var selectedFlyerForShow: UIImage!
    
    var delegate: ChooseFlyerViewControllerDelegate?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setViewBackground()

        collectionView_FlyerOptions.register(UINib(nibName: "FlyerOptionsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FlyerOptionsCollectionViewCell")
        collectionView_FlyerList.register(UINib(nibName: "FlyerListCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FlyerListCollectionViewCell")
        
        
        self.reloadFilterCategories()
        
        self.longPressGesture()
        
    }
    
    //MARK:- Long Press Gesture
    internal func longPressGesture() {
    
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.delegate = self
        
        collectionView_FlyerList.addGestureRecognizer(longPressGesture)
        
    }

    
    //MARK:- Reload Get Filter Categories.
    internal func reloadFilterCategories() {
        
        self.array_CategoryList = Singleton.sharedInstance.categoryListInfo
        
        let getCategoryId: String = String(self.array_CategoryList[selectedCategory].id ?? 0)
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.getFlyerByCategoriesFromAPI(categoryId: getCategoryId)
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
        collectionView_FlyerOptions.reloadData()
        
    }
    
    
    //MARK:- Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueFlyerImage" {
        
            let destinationView: ShowImageViewController = segue.destination as! ShowImageViewController
            destinationView.image = selectedFlyerForShow
        }
        
    }
    

}


// MARK: - UIGestureRecognizerDelegate

extension ChooseFlyerViewController: UIGestureRecognizerDelegate {

    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
        
        let point = gestureReconizer.location(in: self.collectionView_FlyerList)
        let indexPath = collectionView_FlyerList.indexPathForItem(at: point)
        
        if let index = indexPath {
            
            let cell: FlyerListCollectionViewCell = collectionView_FlyerList.cellForItem(at: index) as! FlyerListCollectionViewCell
            // do stuff with your cell, for example print the indexPath
            print(index.row)
            
            selectedFlyerForShow = cell.imageView_image.image
            self.performSegue(withIdentifier: "segueFlyerImage", sender: self)
            
        } else {
            
            print("Could not find index path")
            
        }
        
    }
    
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ChooseFlyerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == collectionView_FlyerOptions ? self.array_CategoryList.count : self.array_FlyerObjList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionView_FlyerOptions {
        
            let cell: FlyerOptionsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlyerOptionsCollectionViewCell", for: indexPath) as! FlyerOptionsCollectionViewCell
            
            let categoryInfoMapperObj: AFilterCategoriesInfoModel = self.array_CategoryList[indexPath.row]
            
            // Configure the cell
            if selectedCategory == indexPath.row {
            
                cell.view_categoryColor.layer.borderColor = UIColor(hex: categoryInfoMapperObj.color_code ?? "").cgColor
                cell.view_categoryColor.backgroundColor   = UIColor(hex: categoryInfoMapperObj.color_code ?? "")
                
                cell.label_Text.textColor = UIColor.white
                
                cell.label_Text.font = UIFont(name: "SourceSansPro-SemiBold", size: 15)
                
            } else {
                
                cell.view_categoryColor.backgroundColor   = UIColor.white
                cell.view_categoryColor.layer.borderColor = UIColor(hex: categoryInfoMapperObj.color_code ?? "").cgColor
                cell.view_categoryColor.layer.borderWidth = 1.0
                
                cell.label_Text.textColor = UIColor(hex: categoryInfoMapperObj.color_code ?? "")
                
                cell.label_Text.font = UIFont(name: "SourceSansPro-SemiBold", size: 13)

            }
            
            cell.label_Text.text = categoryInfoMapperObj.event_name ?? ""
            
            return cell
            
        } else {
        
            let cell: FlyerListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlyerListCollectionViewCell", for: indexPath) as! FlyerListCollectionViewCell
            
            let flyerInfoModelObj: AFlyerInfoModel = self.array_FlyerObjList[indexPath.row]
            
            cell.imageView_image.sd_setImage(with: URL(string: flyerInfoModelObj.flyer_image ?? ""), placeholderImage: nil)
            
            
            if array_SelectedFlyerObjList.contains(where: { $0.id == flyerInfoModelObj.id }) {
            
                let layerView = UIViewSelectedLayer(frame: cell.frame)
                cell.contentView.addSubview(layerView)
                
            } else {
            
                for view in cell.contentView.subviews {
                    if view is UIViewSelectedLayer {
                        view.removeFromSuperview()
                    }
                }
                
            }
        
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        if collectionView == collectionView_FlyerOptions {
        
            selectedCategory = indexPath.row
            
            let getCategoryId: String = String(self.array_CategoryList[selectedCategory].id ?? 0)
            
            if Reachability.isConnectedToNetwork() == true {
                
                self.getFlyerByCategoriesFromAPI(categoryId: getCategoryId)
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
                
            }
            
            //self.getFlyerByCategoriesFromAPI(categoryId: String(self.array_CategoryList[selectedCategory].id ?? 0))

        } else {
        
            let cell: FlyerListCollectionViewCell = collectionView.cellForItem(at: indexPath) as! FlyerListCollectionViewCell
            
            if let image = cell.imageView_image.image {
                
                let flyerInfoModelObj: AFlyerInfoModel = self.array_FlyerObjList[indexPath.row]
                
                if array_SelectedFlyerObjList.contains(where: { $0.id == flyerInfoModelObj.id }) {
                    
                    let element = array_SelectedFlyerObjList.index(where: { $0.id == flyerInfoModelObj.id  }).map({ (index) in
                        self.array_SelectedFlyerObjList.remove(at: index)
                    })
                    
                    print(element?.id ?? "Id Not Found")
                    print(array_SelectedFlyerObjList.count)
                    
                } else {
                    
                    array_SelectedFlyerObjList.removeAll()
                    array_SelectedFlyerObjList.append(flyerInfoModelObj)
                    
                }
                
                // We are save all selected image on array.
                // If user want the multiple selection for flyer
                // Pop view for now.
                
                delegate?.selectedImageFromList(image: image)
                self.navigationController?.popViewController(animated: true)
                
            }
            
        }
        
        collectionView.reloadData()

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionView_FlyerOptions {
            
            let categoryInfoMapperObj: AFilterCategoriesInfoModel = self.array_CategoryList[indexPath.row]
            
            let textCategoryString = String(categoryInfoMapperObj.event_name ?? "")
            
            let font = UIFont(name: "SourceSansPro-SemiBold", size: 13)
            
            let stringWidth:  CGFloat = textCategoryString?.widthOfString(usingFont: font!) ?? 20
            
            return  CGSize(width: 30 + stringWidth, height: 40)
            
        } else {
        
            return CGSize(width: collectionView.bounds.size.width/4.05, height: collectionView.bounds.size.width/4.05)
            
        }
        
    }
    
}
