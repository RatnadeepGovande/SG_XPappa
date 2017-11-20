//
//  ExploreViewController.swift
//  App411
//
//  Created by osvinuser on 7/25/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
//import GoogleMaps
import Foundation
import MobileCoreServices
import MediaPlayer
import AVKit
import ObjectMapper

//class ClusterMarkerItem: NSObject, GMUClusterItem {
//    var position: CLLocationCoordinate2D
//    var name: String!
//    
//    init(position: CLLocationCoordinate2D, name: String) {
//        self.position = position
//        self.name = name
//    }
//}
//
//
//let kClusterItemCount = 10000
//let kCameraLatitude = -33.8
//let kCameraLongitude = 151.2


class ExploreViewController: UIViewController, MKMapViewDelegate, CameraCustomControllerDelegate, ShowAlert  /*, GMUClusterManagerDelegate, GMUClusterRendererDelegate ,GMSMapViewDelegate*/ {

    // Variables.
//    @IBOutlet var mapView: GMSMapView!
//
//    private var clusterManager: GMUClusterManager!

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var causesButton: UIButton!

    var heatmap = DTMHeatmap()
    var diffHeatmap = DTMDiffHeatmap()
    
    var array_StoryInfo = [AStoryInfoModel]()
    var array_eventList = [ExploreEventModel]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: kCameraLatitude, longitude: kCameraLongitude, zoom: 0)
        // MapView.camera = camera
        
        // config cluster.
        // self.configClusterIconGenerator()
        // let southWest = CLLocationCoordinate2D(latitude: 30.7333, longitude: 76.7794)
        // let northEast = CLLocationCoordinate2D(latitude: 30.7333, longitude: 76.7794)
        // let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        //        
        // Image from http://www.lib.utexas.edu/maps/historical/newark_nj_1922.jpg
        // let icon = UIImage(named: "ic_blue.png")
        //        
        // let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
        // overlay.bearing = 10
        // overlay.map = mapView
        
        
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else { return }
        
        guard let latitude = userInfoModel.latitute else { return }
        
        guard let longitude = userInfoModel.longitute else { return }
        
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(1.0, 1.0)
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        mapView?.region = MKCoordinateRegionMake(center, span)
        
        
        //diffHeatmap = DTMDiffHeatmap()
        //diffHeatmap.setBeforeData(self.parseLatLonFile("first_week"), afterData: self.parseLatLonFile("third_week"))
        
        
        self.getStoreExplore()
        
        
        
        // [self.diffHeatmap setBeforeData:[self parseLatLonFile:@"first_week"] afterData:[self parseLatLonFile:@"third_week"]];
        // let overlayCircle1 = GMSCircle(position: southWest, radius: 12)
        // overlayCircle1.fillColor = UIColor(red: 183/255, green: 213/255, blue: 238/255, alpha: 0).withAlphaComponent(0.8)
        // overlayCircle1.strokeColor = UIColor(red: 226/255, green: 232/255, blue: 248/255, alpha: 0)
        // overlayCircle1.strokeWidth = 8
        // overlayCircle1.map = mapView
        
        
        // [UIColor.redColor.CGColor, UIColor.orangeColor().CGColor, UIColor.blueColor().CGColor, UIColor.magentaColor().CGColor, UIColor.yellowColor().CGColor]
        
        // let hydeParkLocation = CLLocationCoordinate2D(latitude: -33.87344, longitude: 151.21135)
        // let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 16)
        // let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        // mapView.animate(to: camera)
        //        
        // let hydePark = "tpwmEkd|y[QVe@Pk@BsHe@mGc@iNaAKMaBIYIq@qAMo@Eo@@[Fe@DoALu@HUb@c@XUZS^ELGxOhAd@@ZB`@J^BhFRlBN\\BZ@`AFrATAJAR?rAE\\C~BIpD"
        // let archibaldFountain = "tlvmEqq|y[NNCXSJQOB[TI"
        //  let reflectionPool = "bewmEwk|y[Dm@zAPEj@{AO"
        //        
        // let polygon = GMSPolygon()
        // polygon.path = GMSPath(fromEncodedPath: hydePark)
        // polygon.holes = [GMSPath(fromEncodedPath: archibaldFountain)!, GMSPath(fromEncodedPath: reflectionPool)!]
        // polygon.fillColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        // polygon.strokeColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        // polygon.strokeWidth = 2
        // polygon.map = mapView
        // view = mapView
        
        // let overlayCircle2 = GMSCircle(position: southWest, radius: 11)
        // overlayCircle2.fillColor = UIColor(red: 0, green: 255/255, blue: 255/255, alpha: 0.4)
        // overlayCircle2.strokeColor = UIColor.clear
        // overlayCircle2.map = mapView
        //        
        // let overlayCircle3 = GMSCircle(position: southWest, radius: 10.5)
        // overlayCircle3.fillColor = UIColor(red: 0, green: 255/255, blue: 255/255, alpha: 0.4)
        // overlayCircle3.strokeColor = UIColor.clear
        // overlayCircle3.map = mapView
        //        
        // let overlayCircle4 = GMSCircle(position: southWest, radius: 10)
        // overlayCircle4.fillColor = UIColor(red: 255/255, green: 255/255, blue: 0, alpha: 0.4)
        // overlayCircle4.strokeColor = UIColor.clear
        // overlayCircle4.map = mapView
        //        
        // let overlayCircle5 = GMSCircle(position: southWest, radius: 9)
        // overlayCircle5.fillColor = UIColor(red: 255/255, green: 98/255, blue: 40/255, alpha: 0.4)
        // overlayCircle5.strokeColor = UIColor.clear
        // //overlayCircle5.
        // overlayCircle5.map = mapView


//     let overlay = GMSGroundOverlay(position: southWest, icon: icon, zoomLevel: 16)
//     overlay.map = mapView
//        overlay.opacity
//     overlay.isTappable = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
    }

    
    func parseLatLonFile(_ fileName: String) -> [AnyHashable: Any] {
        
        var ret = [AnyHashable: Any]()
        let path: String? = Bundle.main.path(forResource: fileName, ofType: "txt")
        let content = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let lines: [Any]? = content?.components(separatedBy: "\n")
        
        for line: String in lines as! [String] {
            
            let parts: [Any] = line.components(separatedBy: ",")
            let latStr: String = parts[0] as! String
            let lonStr: String = parts[1] as! String
            let latitude: CLLocationDegrees =  Double(latStr)!
            let longitude: CLLocationDegrees = Double(lonStr)!
            
            // For this example, each location is weighted equally
            let weight: Double = 1
            let location = CLLocation(latitude: latitude, longitude: longitude)
            var point: MKMapPoint = MKMapPointForCoordinate(location.coordinate)
            let type = NSValue(mkCoordinate: location.coordinate).objCType
            let pointValue = NSValue(&point, withObjCType: type)

            ret[pointValue] = (weight)
        }
        
        return ret
    
    }
    
    
    internal func updatePointsOnMap() -> [AnyHashable: Any] {
    
        var ret = [AnyHashable: Any]()
        
        for storyObj in self.array_StoryInfo {
        
            let latitude: CLLocationDegrees =  Double(storyObj.latitute ?? "0")!
            let longitude: CLLocationDegrees = Double(storyObj.longitute ?? "0")!
            
//            let latitude: CLLocationDegrees =  storyObj.latitute ?? 0.0
//            let longitude: CLLocationDegrees = storyObj.longitute ?? 0.0
            
            // For this example, each location is weighted equally
            let weight: Double = 1
            let location = CLLocation(latitude: latitude, longitude: longitude)
            var point: MKMapPoint = MKMapPointForCoordinate(location.coordinate)
            let type = NSValue(mkCoordinate: location.coordinate).objCType
            let pointValue = NSValue(&point, withObjCType: type)
            
            ret[pointValue] = (weight)
        
        }
        
        return ret

        
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return DTMHeatmapRenderer(overlay: overlay)
    }
    
    
     // Show Annotations on Map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is ExploreEventModel) {
            return nil
        }
        let reuseId = "eventList"
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        let eventAnnotation = annotation as! ExploreEventModel
        
        annotationView?.image = Singleton.sharedInstance.getImageNameByCategoryId(Id: eventAnnotation.event_category_id!)
        
        return annotationView
        
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //select particular Anotation on map
        
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        // 2
        let eventAnnotation = view.annotation as! ExploreEventModel
        
        let gmsMarkerInfoWindow = ExploreMarkerInfoWindow()
        gmsMarkerInfoWindow.frame = CGRect(x: 0, y: 0, width: 250, height: 240)
        gmsMarkerInfoWindow.delegate = self
        gmsMarkerInfoWindow.donateButton.setTitle(eventAnnotation.event_category_id == 10 ? "Donate" : "I'm Going", for: .normal)
        
        gmsMarkerInfoWindow.eventInfoModel = eventAnnotation

        gmsMarkerInfoWindow.label_EventName.text = eventAnnotation.title
        gmsMarkerInfoWindow.label_EventTime.text = eventAnnotation.start_event_date
        gmsMarkerInfoWindow.button_favourite.isSelected = eventAnnotation.event_favorite ?? false
        
        if eventAnnotation.event_category_id != 10 {
            
            gmsMarkerInfoWindow.donateButton.setTitle(eventAnnotation.event_join ?? false == true ? "Going" : "I'm Going", for: .normal)
            
            if eventAnnotation.event_join ?? false == true {
                
                gmsMarkerInfoWindow.donateButton.backgroundColor = UIColor.red
                gmsMarkerInfoWindow.donateButton.setTitleColor(UIColor.white, for: UIControlState.normal)
                
            } else {
                
                gmsMarkerInfoWindow.donateButton.backgroundColor = UIColor.white
                gmsMarkerInfoWindow.donateButton.setTitleColor(UIColor.red, for: UIControlState.normal)
                
            }
        }

        // Check Video.
        if eventAnnotation.event_video_flag == "1" {
            
            
            var videoImage: UIImage = UIImage(named: "ic_no_image")!
            
            if let videoString = eventAnnotation.event_image {
                
                URL(fileURLWithPath: videoString).createImageThumbnailFrom(returnCompletion: { (imageFromVideo) in
                    
                    DispatchQueue.main.async {
                        
                        if let imageThum =  imageFromVideo {
                            videoImage = imageThum
                        }
                    }
                    
                })
            }
            
            gmsMarkerInfoWindow.imageView_EventImage.image = videoImage
            
        } else {
            
            gmsMarkerInfoWindow.imageView_EventImage.sd_setImage(with: URL(string: eventAnnotation.event_image ?? ""), placeholderImage: UIImage(named: "ic_no_image"))
        }
        
        // 3
        gmsMarkerInfoWindow.center = CGPoint(x: view.bounds.size.width / 2, y: -gmsMarkerInfoWindow.bounds.size.height*0.52)
        view.addSubview(gmsMarkerInfoWindow)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        //deSelect particular Anotation on map
        
        if view.isKind(of: AnnotationView.self) {
            
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    

    
    
//    // MARK: - config cluster icon generator.
//    
//    internal func configClusterIconGenerator() {
//    
//        // Set up the cluster manager with default icon generator and renderer.
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
//        
//        // Generate and add random items to the cluster manager.
//        generateClusterItems()
//        
//        // Call cluster() after items have been added to perform the clustering and rendering on map.
//        clusterManager.cluster()
//        
//        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
//        clusterManager.setDelegate(self, mapDelegate: self)
//    
//    }
//
//    
//    
//    // MARK: - GMUClusterManagerDelegate
//    
//    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
//        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
//                                                 zoom: mapView.camera.zoom + 1)
//        let update = GMSCameraUpdate.setCamera(newCamera)
//        mapView.moveCamera(update)
//        return false
//    }
    
    
    // MARK: - 
    
    
    
    
//    // MARK: - GMUClusterRendererDelegate
//    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
//        
//        print(renderer)
//        
//        return nil
//    }
//    
//    
//    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
//        
//        
//        
//    }
//
//    
//    func renderer(_ renderer: GMUClusterRenderer, didRenderMarker marker: GMSMarker) {
//        
//        
//        
//    }
    
    
    
    
//    //MARK:- Add Event Marker
//    func addEventMarkers(eventInfoObj: ACreateEventInfoModel) -> GMSMarker  {
//        
//        let latiutde = eventInfoObj.latitute!
//        let longitude = eventInfoObj.longitude!
//        
//        // GMSMarker
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: Double(latiutde)!, longitude: Double(longitude)!)
//        marker.appearAnimation = .pop
//        marker.icon = Singleton.sharedInstance.getImageNameByCategoryId(Id: eventInfoObj.event_category_id!)
//        //print(eventInfoObj.event_category_id!)
//        
//        marker.userData = eventInfoObj
//        marker.map = mapView
//        
//        return marker
//        
//    }
    
    
    
    
//    
//    // MARK: - GMUMapViewDelegate
//    
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        
//        if let poiItem = marker.userData as? ClusterMarkerItem {
//            NSLog("Did tap marker for cluster item \(poiItem.name)")
//        } else {
//            NSLog("Did tap a normal marker")
//        }
//        
//        return false
//    
//    }
//    
//    
//    // MARK: - Private
//    
//    /// Randomly generates cluster items within some extent of the camera and adds them to the
//    /// cluster manager.
//    private func generateClusterItems() {
//        let extent = 0.2
//        for index in 1...kClusterItemCount {
//            let lat = kCameraLatitude + extent * randomScale()
//            let lng = kCameraLongitude + extent * randomScale()
//            let name = "Item \(index)"
//            let item = ClusterMarkerItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
//            clusterManager.add(item)
//        }
//    }
//    
//    
//    /// Returns a random value between -1.0 and 1.0.
//    private func randomScale() -> Double {
//        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
//    }
    
    
    @IBAction func createCauseAction(_ sender: UIButton) {

        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            DispatchQueue.main.async(execute: {
                
                self.mapView.addAnnotations(self.array_eventList)
            })
            
        } else {
            
            DispatchQueue.main.async(execute: {
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
            })
        }
    }
    

    // MARK: - camera Button Action.

    @IBAction func cameraButtonAction(_ sender: Any) {
        
        // Create the AlertController and add Its action like button in Actionsheet       
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            
            print("Take Photo")
            
            let customCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraCustomController") as! CameraCustomController
            
            customCamera.delegate = self
            
            self.present(customCamera, animated: true, completion: nil)
            
        }
        
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Photos Library", style: .default)
        { _ in
            print("Choose Photo")
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: [kUTTypeImage as String, kUTTypeMovie as String])
        }
        
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                print("Image Selected")
                
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    self.openShowImageAndVideo(isShowImage: true, image: image, videoURL: nil)
                }

            }
            
            if mediaType == "public.movie" {
                print("Video Selected")
                
                if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                    self.openShowImageAndVideo(isShowImage: false, image: nil, videoURL: videoURL)
                }
                
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: - Camera Delegate Method
    func fetchImageAndVideoURL(url: Any?, type: Int, error: Error!) {
        
        if (error != nil) {
            print(error.localizedDescription)
            return
        }
    
        print(type)
        print(url ?? "Not Found")

        // If type 0 Image and type 1 Video
        
        if type == 0 {
        
            if let image = url as? UIImage {
            
                self.openShowImageAndVideo(isShowImage: true, image: image, videoURL: nil)
            
            }
            
        } else {
        
            if let videoURL = url as? URL {
                
                self.openShowImageAndVideo(isShowImage: false, image: nil, videoURL: videoURL)
            
            }
            
        }
        
    }
    
    
    // MARK: - Open show image and video button.
    
    internal func openShowImageAndVideo(isShowImage: Bool, image: UIImage?, videoURL: URL?) {
        
        
        let viewUploadStore: UploadStoreView = UploadStoreView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenSize.SCREEN_WIDTH, height: Constants.ScreenSize.SCREEN_HEIGHT))
        
        // Create Model Obj.
        let storeInfoObj: StoreInfoMode = StoreInfoMode(isShowImage: isShowImage, image: image, videoURL: videoURL)
        
        viewUploadStore.storeInfoObj = storeInfoObj
        
        viewUploadStore.delegate = self
        
        appDelegateShared.window?.addSubview(viewUploadStore)

    }
    
    
    
    
    // MARK: - Did Receive Memory Warning.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    // MARK: -  Get Store Of Explore Feature.
    
    internal func getStoreExplore() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            self.getStoresDataList()
            
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueEventDetails" {
            
            let eventDetailsObj = segue.destination as! EventDetailViewController
            eventDetailsObj.eventModelData = sender as! ACreateEventInfoModel
            
        } else if segue.identifier == "segueCauseDetails"  {
            
            let eventDetailsObj = segue.destination as! CauseDetailViewController
            eventDetailsObj.eventModelData = sender as! ACreateEventInfoModel
            
        } else {
            
            let destinationVC = segue.destination as! DonateViewController
            destinationVC.eventModelData = sender as! ACreateEventInfoModel
            destinationVC.isFromExplore = true
        }
    }
    
}

extension ExploreViewController: UploadStoreViewDelegate {
    
    func uploadVideoAndImage(isShowImage: Bool, image: UIImage?, videoURL: URL?, view: UIView) {
    
        // Data....
        print(isShowImage)
        print(image ?? "No Image Found.")
        print(videoURL ?? "No Video Found.")
        
        // Data.
        let url =  Constants.APIs.baseURL + Constants.APIs.postOnTimeline
        let randomIDTimelinePost = "ExplorePostPublicID_".randomString(length: 60)
        
        if let userInfoModel = Methods.sharedInstance.getUserInfoData() {
            
            if let authToken = userInfoModel.authentication_token {
                
                
                if isShowImage == true {
                
                    if let image = image {
                        
                        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                            
                            let imageWidth = "\(image.size.width)"
                            let imageHeight = "\(image.size.height)"
                            
                            // Show Loaders.
                            Methods.sharedInstance.showLoader()
                            
                            // post text and image
                            self.uploadImageOnCloudinaryByData(APIUrl: url, authToken: authToken, publicID: randomIDTimelinePost, imageData: imageData, imageWidth: imageWidth, imageHeight: imageHeight, isVideo: "0", view: view)
                            
                        }
                        
                    }
                    
                } else {
                
                    if let fileURL = videoURL {
                        
                        // Show Loaders.
                        Methods.sharedInstance.showLoader()
                        
                        self.uploadVideoOnCloudinaryByURL(APIUrl: url, authToken: authToken, publicID: randomIDTimelinePost, fileURL: fileURL, isVideo: "1", view: view)
                        
                    }
                    
                }
                
            } else {
                
                print("user auth token not found")
                
            }
            
        } else {
            
            print("user data not found")
        
        }
    
    
    }
    
}

extension ExploreViewController : ExploreMarkerInfoWindowDelegate {
    
    
    func goingActionDelegate(_ sender: UIButton, eventInfoModel: ExploreEventModel) {
        
        if eventInfoModel.event_category_id == 10 {
            
            let eventObject = ACreateEventInfoModel(id: eventInfoModel.id ?? 0, user_id: eventInfoModel.user_id ?? 0)

            self.performSegue(withIdentifier: "causeDonate", sender: eventObject)
            
        } else {
            
            if Reachability.isConnectedToNetwork() == true {
                
                Methods.sharedInstance.showLoader()

                self.joinEventForUser(eventId: eventInfoModel.id ?? 0, isEventJoin: eventInfoModel.event_join!, completion: { (isJoin) in
                    
                    Methods.sharedInstance.hideLoader()

                    if isJoin {
                        
                        self.mapView.deselectAnnotation(nil, animated: false)
                        
                        let indexOfPerson1 = self.array_eventList.index(where: {$0 === eventInfoModel})
                        self.array_eventList[indexOfPerson1!].event_join = !eventInfoModel.event_join!
                        
                        DispatchQueue.main.async(execute: { 
                            self.mapView.removeAnnotations(self.mapView.annotations)
                            self.mapView.addAnnotations(self.array_eventList)
                        })
                    }
                    
                })
                
            } else {
                
                self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
            }
            
        }
    }
    
    func previewActionDelegate(_ sender: UIButton, eventInfoModel: ExploreEventModel) {
        
        let eventObject = ACreateEventInfoModel(id: eventInfoModel.id ?? 0, user_id: eventInfoModel.user_id ?? 0)

        if eventInfoModel.event_category_id == 10 {
            
            self.performSegue(withIdentifier: "segueCauseDetails", sender: eventObject)
            
        } else {
            
            self.performSegue(withIdentifier: "segueEventDetails", sender: eventObject)
            
        }
        
        self.navigationController?.view.backgroundColor = UIColor.white
        
    }
    
    
    func favouriteActionDelegate(_ sender: UIButton, eventInfoModel: ExploreEventModel) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            Methods.sharedInstance.showLoader()
            
            self.saveEventForUser(eventId: eventInfoModel.id ?? 0, isSavedEvent: !eventInfoModel.event_favorite!, completion: { (isFavorite) in
                
                Methods.sharedInstance.hideLoader()
                
                if isFavorite {
                    
                    let indexOfPerson1 = self.array_eventList.index(where: {$0 === eventInfoModel})
                    self.array_eventList[indexOfPerson1!].event_favorite = !eventInfoModel.event_favorite!

                    sender.isSelected = !sender.isSelected
                    self.mapView.deselectAnnotation(nil, animated: false)

                    DispatchQueue.main.async(execute: {
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.mapView.addAnnotations(self.array_eventList)
                    })
                }
            })
        } else {
            
            self.showAlert(AKErrorHandler.CommonErrorMessages.NO_INTERNET_AVAILABLE)
        }
        
    }
}

