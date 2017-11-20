//
//  FilterViewController.swift
//  App411
//
//  Created by osvinuser on 6/21/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class FilterViewController: UIViewController, ShowAlert {

    // Outlet
    @IBOutlet var collectionView_Main: UICollectionView!
    
    @IBOutlet var sliderValue: UISlider!
    
    @IBOutlet var viewHeight: NSLayoutConstraint!
    var filterType: Bool = true
    @IBOutlet var applyButton: UIButton!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet var milesTextLabel: UILabel!

    // Variables
    var array_CategoryList = [AFilterCategoriesInfoModel]()
    
    var array_SelectedFilters = [AFilterCategoriesInfoModel]()
    
    var selectedRadiusValue: Int = 50
    var groupEventID : Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderValue.minimumValue = 2
        sliderValue.maximumValue = 100
        
        // Register Nibs.
        collectionView_Main.register(UINib(nibName: "FilterCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        //DispatchQueue.main.async {
            self.viewHeight.constant = self.filterType == true ? 80 : 0
            self.bottomViewHeight.constant = self.filterType == true ? 64 : 0
            
            self.applyButton.isHidden = !self.filterType
            self.view.layoutIfNeeded()
        //}
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload Filter Data.
        self.reloadFilterCategories()
        
    }
    
    // MARK:- Reload Get Filter Categories.
    
    internal func reloadFilterCategories() {
        
        self.array_CategoryList = Singleton.sharedInstance.categoryListInfo
        
        if self.filterType {
            
            for filterInfoObj in Singleton.sharedInstance.filterSelectedListInfo {
                //print(filterInfoObj.event_category_id ?? 0)
                if let categoryID = filterInfoObj.event_category_id {
                    
                    let AFilterView: AFilterCategoriesInfoModel = AFilterCategoriesInfoModel(id: categoryID, color_code: "", created_at: "", event_name: "", status: "", updated_at: "")
                    array_SelectedFilters.append(AFilterView)
                    
                }
            }
        }
    

        if let filterDistance = Singleton.sharedInstance.filterDistance {
        
            if let filterValue = Float(filterDistance) {
                sliderValue.value = filterValue
            } else {
                sliderValue.value = 50.0
            }
            
        } else {
            sliderValue.value = 50.0
        }
        
        self.milesTextLabel.text = "\(Int(sliderValue.value))" + " " + "Miles"
        
        self.collectionView_Main.reloadData()

    }
    
    
    // MARK: - IBActions.
    
    @IBAction func applyFilterAction(_ sender: Any) {
        
        print(array_SelectedFilters)
        
        if array_SelectedFilters.count > 0 {
        
            if Reachability.isConnectedToNetwork() == true {
                self.applicationFiltersSelectedCategories(selectedCategories: array_SelectedFilters, radius: selectedRadiusValue)
            } else {
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }
            
        } else {
        
            self.showAlert("Please select at least one category")
        }
        
    }
    
    
    @IBAction func radiusSliderAction(_ sender: UISlider) {
        selectedRadiusValue = Int(sender.value)
        self.milesTextLabel.text = "\(Int(sender.value))" + " " + "Miles"
    }
    
    @IBAction func crossAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Did Receive Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createEvent" {
          
            let destination = segue.destination as! CreateEventViewController
            destination.categoryEventID = sender as! Int
            
            if groupEventID == 0 {
                destination.groupID = nil
            } else {
                destination.groupID = groupEventID
            }
            
        }
        
    }
 

}

extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.array_CategoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: FilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        
        // Configure the cell
        cell.layoutIfNeeded()
        cell.viewBackground.layer.cornerRadius = (cell.viewBackground.frame.size.width)/2
        cell.viewCheckBox.layer.cornerRadius = (cell.viewCheckBox.frame.size.width)/2

        
        // Get Model Data.
        let categoryInfoMapperObj: AFilterCategoriesInfoModel = self.array_CategoryList[indexPath.row]
        cell.viewBackground.backgroundColor = UIColor(hex: categoryInfoMapperObj.color_code ?? "")
        cell.labelText.text = categoryInfoMapperObj.event_name ?? ""
        
        
        // Check Data contain or not.
        if array_SelectedFilters.contains(where: { $0.id == categoryInfoMapperObj.id }) {
            cell.viewCheckBox.isHidden = false
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            
            if cell.isSelected {
                print("svasv")
            } else {
                print("dnnngd")
            }
            
        } else {
            cell.viewCheckBox.isHidden = true
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        if filterType {
            
            // Update Info
            self.updateTableViewCellCheck(collectionView: collectionView, indexPath: indexPath)
            
        } else {
            
            let categoryInfoMapperObj: AFilterCategoriesInfoModel = self.array_CategoryList[indexPath.row]

            self.performSegue(withIdentifier: "createEvent", sender: categoryInfoMapperObj.id ?? 0)

        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding : CGFloat = 10.0
        let collectionViewSize = collectionView_Main.frame.size.width - padding
        return CGSize(width: collectionViewSize/3.5, height: collectionViewSize/3.5)
    }
    
    
    // MARK: - Update Table View Cell Check.
    internal func updateTableViewCellCheck(collectionView: UICollectionView, indexPath: IndexPath) {
    
        // viewCheckBox
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell
        
        if cell != nil {
        
            let categoryInfoMapperObj: AFilterCategoriesInfoModel = self.array_CategoryList[indexPath.row]
            
            // Check Data contain or not.
            if array_SelectedFilters.contains(where: { $0.id == categoryInfoMapperObj.id }) {
                
                _ = array_SelectedFilters.index(where: { $0.id ==  categoryInfoMapperObj.id }).map({ (Index) in
                    array_SelectedFilters.remove(at: Index)
                })
                
                cell?.viewCheckBox.isHidden = true
                
            } else {
                
                array_SelectedFilters.append(categoryInfoMapperObj)
                cell?.viewCheckBox.isHidden = false
                
            }
            
        } else {
        
            cell?.viewCheckBox.isHidden = false
            
        }
        
    }
    
}
