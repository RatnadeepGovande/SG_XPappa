//
//  PlacesShowByMapViewController.swift
//  ListDemo
//
//  Created by osvinuser on 10/3/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import GoogleMaps

class PlacesShowByMapViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!

    let gmsMarkerInfoWindow = PlacesMarkerInfoWindow()

    fileprivate var array_GMSMarker = [GMSMarker]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setMapViewLayout()
    }

    
    // MARK: - set Map View Layout
    
    internal func setMapViewLayout() {
        
        // User Current Location.
        let userCurrentLocation: CLLocationCoordinate2D = Singleton.sharedInstance.userCurrentLocation
        print(userCurrentLocation)
        
        // Set Map View Position.
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude, zoom: 15.0)
        
        mapView.isMyLocationEnabled = true
        
        mapView.camera = camera
        
        mapView.delegate = self
        
        
        self.reloadEventList()
        
    }
    
    // MARK: - realod
    
    internal func reloadEventList() {
        
        if Singleton.sharedInstance.array_PlacesList.count > 0 {
            
            for dict in Singleton.sharedInstance.array_PlacesList {
                
                if let gmsMarker: GMSMarker = self.addEventMarkers(dict: dict) {
                    self.array_GMSMarker.append(gmsMarker)
                }
                
            }
            
        }
        
    }
    
    // MARK:- Add Event Marker
    func addEventMarkers(dict: Dictionary<String, AnyObject>) -> GMSMarker?  {
        
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
        
        marker.userData = dict
        marker.map = mapView
        
        return marker
        
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

extension PlacesShowByMapViewController : GMSMapViewDelegate {
    
    
    //MARK:- Google Map View Delegates.
    
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
        
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
    }
    
    private func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        print(marker.userData ?? "Data!!!!!...")
        
        if let dict = marker.userData as? Dictionary<String, AnyObject>  {
        
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
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        gmsMarkerInfoWindow.removeFromSuperview()
        
        if let dict = marker.userData as? Dictionary<String, AnyObject> {
            
            if let image = dict["icon"] as? String {
                gmsMarkerInfoWindow.imageView_EventImage.sd_setImage(with: URL(string: image), placeholderImage: nil)
            }
            
            if let name = dict["name"] as? String {
                gmsMarkerInfoWindow.label_EventName.text = name
            }
            
            if let address = dict["vicinity"] as? String {
                gmsMarkerInfoWindow.label_EventTime.text = address
            }
            
            gmsMarkerInfoWindow.frame = CGRect(x: 0, y: 0, width: 250, height: 240)
            
            gmsMarkerInfoWindow.center = mapView.projection.point(for: marker.position)
            gmsMarkerInfoWindow.center.y = gmsMarkerInfoWindow.center.y - sizeForOffset(view: gmsMarkerInfoWindow)
            self.mapView.addSubview(gmsMarkerInfoWindow)
            
        }
    
        return false
        
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


