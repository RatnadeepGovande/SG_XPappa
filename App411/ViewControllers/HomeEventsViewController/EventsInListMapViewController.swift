//
//  EventsInListMapViewController.swift
//  App411
//
//  Created by osvinuser on 6/26/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import GoogleMaps

class EventsInListMapViewController: UIViewController, ShowAlert {
    
    @IBOutlet var mapView: GMSMapView!
    
    let gmsMarkerInfoWindow = GMSMarkerInforWindow()

    fileprivate var array_eventList = [ACreateEventInfoModel]()
    
    fileprivate var array_GMSMarker = [GMSMarker]()
    
    fileprivate var array_NearByLocationMarker = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEventList), name: NSNotification.Name(rawValue: "eventListReloadNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavoriteEvent(_:)), name: NSNotification.Name(rawValue: "updateSaveEvent"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMarkerOnMapView), name: NSNotification.Name(rawValue: "showNearByPlacesNotification"), object: nil)


        //eventListAPIReloadNotification
        // Set Map View Layout.
        self.setMapViewLayout()

    }

    // MARK: - set Map View Layout
    
    internal func setMapViewLayout() {
    
        // User Current Location.
        let userCurrentLocation: CLLocationCoordinate2D = Singleton.sharedInstance.userCurrentLocation
        print(userCurrentLocation)
        
        DispatchQueue.main.async(execute: {
            // Set Map View Position.
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude, zoom: 15.0)
            
            self.mapView.isMyLocationEnabled = true
            
            self.mapView.camera = camera
            
            self.mapView.delegate = self
        })
       
    }
    
    //MARK:- Show Marker on map View.
    func showMarkerOnMapView(notification: NSNotification) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PlacesListTypesViewController") as! PlacesListTypesViewController

        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    
    // MARK: - Add Near By Marker.
    func addNearByLocationMarker(dict: Dictionary<String, AnyObject>) -> GMSMarker? {
        
        guard let geometry = dict["geometry"] as? Dictionary<String, AnyObject>  else {
            return nil
        }
        
        guard let location = geometry["location"] as? Dictionary<String, AnyObject>  else {
            return nil
        }
        
        guard let latitude = location["lat"] as? Double else {
            return nil
        }
        
        guard let logitude = location["lng"] as? Double else {
            return nil
        }
        
        // GMSMarker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: logitude)
        marker.appearAnimation = .pop
        marker.title = dict["name"] as? String
        marker.userData = dict
        marker.map = mapView
     
        
        return marker
        
    }
    
    
    internal func updateFavoriteEvent(_ notification: NSNotification) {
        //["indexOfObject": indexOfPerson1 ?? 0, "event_favorite": isSavedEvent]
        if let indexOfObject = notification.userInfo?["indexOfObject"] as? Int {
         
            self.array_GMSMarker.remove(at: indexOfObject)
            
            let markerDict = self.array_eventList[indexOfObject]
            markerDict.event_favorite = notification.userInfo?["event_favorite"] as? Bool ?? false
            
            let gmsMarkerNew: GMSMarker = self.addEventMarkers(eventInfoObj: markerDict)
            self.array_GMSMarker.append(gmsMarkerNew)

        }
    }
    
    // MARK: - realod
    
    internal func reloadEventList() {
        
        self.mapView.clear()
        
        self.array_eventList = Singleton.sharedInstance.array_eventList
        
        if self.array_eventList.count > 0 {
            
            for dict in self.array_eventList {
                
                DispatchQueue.main.async(execute: {
                    
                    let gmsMarker: GMSMarker = self.addEventMarkers(eventInfoObj: dict)
                    
                    self.array_GMSMarker.append(gmsMarker)
                })
            
            }
            
        }
        
    }
    
    
    //MARK:- Add Event Marker
    func addEventMarkers(eventInfoObj: ACreateEventInfoModel) -> GMSMarker  {
        
        let latiutde = eventInfoObj.latitute!
        let longitude = eventInfoObj.longitude!
        
        // GMSMarker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(latiutde)!, longitude: Double(longitude)!)
        marker.appearAnimation = .pop
        marker.icon = Singleton.sharedInstance.getImageNameByCategoryId(Id: eventInfoObj.event_category_id!)
        //print(eventInfoObj.event_category_id!)

        marker.userData = eventInfoObj
        marker.map = mapView
        
        return marker

    }
    
    
    //MARK: - Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    internal func saveEventForUser(eventId:Int, isSavedEvent:Bool, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isSavedEvent == false ? 0 : 1)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.saveEvent, method: "POST", params: paramsStr) { (success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        completion(true)
                        
                    } else {
                        completion(false)
                        
                        print("Worng data found.")
                        
                    }
                    
                    self.showAlert(jsonResult["message"] as? String ?? "")
                }
            } else {
                completion(false)
                
                self.showAlert(errorMsg)
            }
        }
    }
    
    
    internal func joinEventForUser(eventId:Int, isEventJoin:Bool, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        //auth_token,event_id,status if status 1 means join and status 0 means disjoint
        let paramsStr = "auth_token=\(userInfoModel.authentication_token ?? "")&event_id=\(eventId)&status=\(isEventJoin == false ? 1 : 0)"
        print(paramsStr)
        
        WebServiceClass.sharedInstance.dataTask(urlName: Constants.APIs.baseURL + Constants.APIs.eventJoin, method: "POST", params: paramsStr) { (
            success, response, errorMsg) in
            
            if success == true {
                
                if let jsonResult = response as? Dictionary<String, AnyObject> {
                    
                    print(jsonResult)
                    
                    if let responeCode = jsonResult["responseCode"] as? Bool, responeCode {
                        print(responeCode)
                        
                        completion(true)
                        
                    } else {
                        completion(false)
                        
                        print("Worng data found.")
                    }
                    
                    self.showAlert(jsonResult["message"] as? String ?? "")
                    
                } else {
                    
                    completion(false)

                }
            } else {
                completion(false)
                
                self.showAlert(errorMsg)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueEventDetails" {
            let viewController = segue.destination as! EventDetailViewController
            viewController.eventModelData = sender as? ACreateEventInfoModel
        }
    }

}

extension EventsInListMapViewController : GMSMapViewDelegate {
    
    
        //MARK:- Google Map View Delegates.
    
        func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
            
        }
        
        func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
            
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            
        }
        
        func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
            
        }
        
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
            
            //self.performSegue(withIdentifier: "segueBusinessDetails", sender: self)
            
        }
        
        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            return UIView()
        }
    
        // reset custom infowindow whenever marker is tapped
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            
            gmsMarkerInfoWindow.removeFromSuperview()
            
            if let eventInfoObj: ACreateEventInfoModel = marker.userData as? ACreateEventInfoModel {
                
                gmsMarkerInfoWindow.label_EventName.text = eventInfoObj.title ?? ""
                
                gmsMarkerInfoWindow.label_EventTime.text = eventInfoObj.start_event_date ?? ""
                gmsMarkerInfoWindow.eventInfoModel = eventInfoObj
                gmsMarkerInfoWindow.delegate = self
                gmsMarkerInfoWindow.button_favourite.isSelected = eventInfoObj.event_favorite ?? false
                
                // Check Video.
                if eventInfoObj.event_video_flag == "1" {
                    
                    gmsMarkerInfoWindow.imageView_EventImage.sd_setImage(with: URL(string: eventInfoObj.event_Thumbnail ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

                    
                } else {
                    
                    gmsMarkerInfoWindow.imageView_EventImage.sd_setImage(with: URL(string: eventInfoObj.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))

                }

                gmsMarkerInfoWindow.frame = CGRect(x: 0, y: 0, width: 250, height: 240)
                
                gmsMarkerInfoWindow.center = mapView.projection.point(for: marker.position)
                gmsMarkerInfoWindow.center.y = gmsMarkerInfoWindow.center.y - sizeForOffset(view: gmsMarkerInfoWindow)
                self.mapView.addSubview(gmsMarkerInfoWindow)
                
                return false
                
            } else {
                
                return true
            }
            
        }
        
        // MARK: Needed to create the custom info window
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            gmsMarkerInfoWindow.removeFromSuperview()
        }
        
        // MARK: Needed to create the custom info window (this is optional)
        func sizeForOffset(view: UIView) -> CGFloat {
            return  180.0
        }
        
        // let the custom infowindow follows the camera
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            
            if (mapView.selectedMarker != nil) {
                
                let location = mapView.selectedMarker?.position
                
                gmsMarkerInfoWindow.center = mapView.projection.point(for: location!)
                gmsMarkerInfoWindow.center.y = gmsMarkerInfoWindow.center.y - sizeForOffset(view: gmsMarkerInfoWindow)
                
            }
        }
}

extension EventsInListMapViewController : GMSMarkerInforWindowDelegate {
    
    func goingActionDelegate(_ sender: UIButton, eventInfoModel: ACreateEventInfoModel) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            Methods.sharedInstance.showLoader()
            sender.isUserInteractionEnabled = false

            self.joinEventForUser(eventId: eventInfoModel.id ?? 0, isEventJoin: eventInfoModel.event_join!, completion: { (isJoin) in
                
                Methods.sharedInstance.hideLoader()
                sender.isUserInteractionEnabled = true

                if isJoin {
                    
                    let indexOfPerson1 = self.array_eventList.index(where: {$0.id == eventInfoModel.id})
                    self.array_eventList[indexOfPerson1!].event_join = !eventInfoModel.event_join!
                    
                    self.gmsMarkerInfoWindow.removeFromSuperview()
                    
                }
                
            })
            
        } else {
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
    }
    
    
    func previewActionDelegate(_ sender: UIButton, eventInfoModel: ACreateEventInfoModel) {
        
        self.navigationController?.view.backgroundColor = UIColor.white

        self.performSegue(withIdentifier: "segueEventDetails", sender: eventInfoModel)
    }
    
    func favouriteActionDelegate(_ sender: UIButton, eventInfoModel: ACreateEventInfoModel) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            sender.isUserInteractionEnabled = false
            
            Methods.sharedInstance.showLoader()

            self.saveEventForUser(eventId: eventInfoModel.id ?? 0, isSavedEvent: !eventInfoModel.event_favorite!, completion: { (isFavorite) in
                
                Methods.sharedInstance.hideLoader()
                sender.isUserInteractionEnabled = true

                if isFavorite {
                    
                    let indexOfPerson1 = self.array_eventList.index(where: {$0 === eventInfoModel})
                    self.array_eventList[indexOfPerson1!].event_favorite = !eventInfoModel.event_favorite!
                    
                    self.gmsMarkerInfoWindow.removeFromSuperview()

                }
            })
        } else {
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
    
    
}
