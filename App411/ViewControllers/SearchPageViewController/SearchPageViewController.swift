//
//  SearchPageViewController.swift
//  App411
//
//  Created by osvinuser on 10/25/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class SearchPageViewController: UIViewController, ShowAlert {
    
    // Variables.
    @IBOutlet var tableView_Main: UITableView!
    @IBOutlet var collectionView_Main: UICollectionView!
    
    var featuredEventArray: [Dictionary<String, AnyObject>] = []
    var suggestionListArray = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView_Main.register(UINib(nibName: "SourcesCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SourcesCollectionViewCell")

        self.placesWebService(searchType: "food")
        
        let latitude = UserDefaults.standard.value(forKey: "usercurrentlatitude") as? Float ?? 0.0
        let longitude = UserDefaults.standard.value(forKey: "usercurrentlongitude") as? Float ?? 0.0
        
        let userLocation = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        self.fetchUserLocationName(userCurrentLocation: userLocation)
    }
    
   
    
    func fetchUserLocationName(userCurrentLocation:CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(userCurrentLocation, completionHandler: { (placemarks, error) in
            // always good to check if no error
            // also we have to unwrap the placemark because it's optional
            // I have done all in a single if but you check them separately
            guard error == nil, let placemark = placemarks, !placemark.isEmpty else {
                
                return
            }
            // a new function where you start to parse placemarks to get the information you need
            self.parsePlacemarks(placemark: placemark[0])
            
        })
        
    }
    
    
    func parsePlacemarks(placemark:CLPlacemark?) {
//    // here we check if location manager is not nil using a _ wild card
            if let placemark = placemark {
            // wow now you can get the city name. remember that apple refers to city name as locality not city
                if let city = placemark.locality, !city.isEmpty {
                // here you have the city name
                // assign city name to our iVar
                  // print("manu", city, placemark.name, placemark.subLocality, placemark.thoroughfare, placemark.subThoroughfare, placemark.subAdministrativeArea)
                }
                // the same story optionalllls also they are not empty
                if let country = placemark.country, !country.isEmpty {

                    print(country)
                    self.navigationItem.title = "\(placemark.name ?? "")" + ", " + "\(placemark.locality ?? "")"
               }

            } else {
                
                print("not found data")

        }

    }
    
    
    
    func placesWebService(searchType: String) {
        
        let getLocation = UserDefaults.standard.bool(forKey: "isuserlocationget")
        
        // Save Data in local.
        let latitude = UserDefaults.standard.value(forKey: "usercurrentlatitude") as? Float ?? 0.0
        let longitude = UserDefaults.standard.value(forKey: "usercurrentlongitude") as? Float ?? 0.0
        print("Latitude: - \(latitude) Logitude:- \(longitude)")

        
        
        
        if !getLocation {
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=1000&type=\(searchType)&key=AIzaSyCaSjiwkdmPQrKdhRCSWWJXFAq9gbFPuik"
        
        print("get wallet balance url string is \(urlString)")
        
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                if (error != nil) {
                    
                    print(error?.localizedDescription ?? "error details not found")
                    print(error ?? "error not found")
                    
                } else {
                    
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode  {
                        
                        if response.statusCode == 201 || response.statusCode == 200 {
                            
                            // Check Data
                            if let data = data {
                                
                                // Json Response
                                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>  {
                                    
                                    self.suggestionListArray.removeAll()
                                    
                                    
                                    if let results = jsonResponse?["results"] as? [Dictionary<String, AnyObject>]  {
                                        print(results)
                                        
                                        self.suggestionListArray = results
                                        
                                        
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.tableView_Main.reloadData()
                                    }
                                    
                                } else {
                                    
                                }
                                
                            } else {
                                
                            }
                            
                        } else {
                            
                        }
                        
                    } else {
                        
                    }
                    
                }
                
            })
            
        })
        
        dataTask.resume()
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension SearchPageViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return suggestionListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchPageSuggestionCell = tableView.dequeueReusableCell(withIdentifier: "SearchPageSuggestionCell") as! SearchPageSuggestionCell
        
        cell.selectionStyle = .none
        
        let dict_Obj = self.suggestionListArray[indexPath.row]
        
        if let photoRefArray = dict_Obj["photos"] as? [Dictionary<String, AnyObject>] {
            
            let photoRef : String = photoRefArray[0]["photo_reference"] as! String
            
            let imageUrl = SharedInstance.googlePicKey + photoRef
            cell.avatarImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "ic_no_image"))

        }
       
        
        cell.titleLabel?.text = dict_Obj["name"] as? String
        
        cell.descriptionLabel?.text = dict_Obj["vicinity"] as? String
        
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
}



extension SearchPageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SearchPageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SourcesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourcesCollectionViewCell", for: indexPath) as! SourcesCollectionViewCell
        
        // Get Model Data.
        
        cell.backgroundColor = UIColor.red
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        let dict = self.arraySourcesList[indexPath.item]
        //        let nameChannelText = dict["name"] as? String ?? ""
        
        // Get Model Data.
        //        let size: CGSize = nameChannelText.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        
        return CGSize(width: 60, height: collectionView.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
}

