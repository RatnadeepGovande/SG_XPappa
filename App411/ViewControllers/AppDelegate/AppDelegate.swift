//
//  AppDelegate.swift
//  App411
//
//  Created by osvinuser on 6/12/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import FacebookCore
import FacebookLogin
import UserNotifications
import GooglePlaces
import GooglePlacePicker
import Foundation
import CoreData
import LayerKit
import Atlas
import ActionCableClient
import Starscream
import ObjectMapper
import Branch


let appDelegateShared = UIApplication.shared.delegate as! AppDelegate
let googleAPIKey = "AIzaSyCaSjiwkdmPQrKdhRCSWWJXFAq9gbFPuik"


public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
        
    }
    
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, LYRClientDelegate {

    var window: UIWindow?

    var locationManager = CLLocationManager() /* Location Manager for get the current location for user */
    
    var userCurrentLocation: CLLocationCoordinate2D!
    
    var layerClient: LYRClient! /* LYRClient variables */

    
    var actionCableClient = ActionCableClient(url: URL(string: "wss://xyphr.herokuapp.com/cable")!)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        print(launchOptions ?? "dkbvif")
        UserDefaults.standard.set(1, forKey: "locationtokencount")
        
        self.setupLocationManagerServices()
        self.loginViewController()
        self.setNavigationAppearance()
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        GMSPlacesClient.provideAPIKey(googleAPIKey)
        GMSServices.provideAPIKey(googleAPIKey)
        
        self.registerForPushNotifications()
        
        actionCableClient.willConnect = {
            print("Will Connect")
        }
        
        actionCableClient.onConnected = {
            print("Connected to \(self.actionCableClient.url)")
//            if UserDefaults.standard.bool(forKey: "loginsession") == true {
//                //self.roomChannelRequest()
//            }
            
        }
        
        actionCableClient.onDisconnected = {(error: ConnectionError?) in
            print("Disconected with error: \(String(describing: error))")
        }
        
        actionCableClient.onRejected = {
            print("Connected to \(self.actionCableClient.url)")
        }
        
        actionCableClient.willReconnect = {
            print("Reconnecting to \(self.actionCableClient.url)")
            return true
        }
        
        
        actionCableClient.connect()
        
        
        
        if UserDefaults.standard.bool(forKey: "loginsession") == true {
            self.allocLayerClient()
        }

        let branch: Branch = Branch.getInstance()
        
        branch.setDebug()
        
        branch.initSession(launchOptions: launchOptions, isReferrable: true) { params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                print("params: %@", params as? [String: AnyObject] ?? {})
                
                self.moveToparticularController(dict: params as? [String: AnyObject] ?? [:])
            }
        }
        
        
        return true
    }
    
    
    internal func moveToparticularController(dict : [String: AnyObject]) {
        
        if UserDefaults.standard.bool(forKey: "loginsession") == true {
            
            if dict["Metadata_Key2"] != nil {
                
                print(Int(dict["Metadata_Key2"] as? String ?? "") ?? 0, Int(dict["Metadata_Key3"] as? String ?? "") ?? 0)

                let eventObject = ACreateEventInfoModel(id: Int(dict["Metadata_Key2"] as? String ?? "") ?? 0, user_id: Int(dict["Metadata_Key3"] as? String ?? "") ?? 0)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let mainViewController: MainTabbarViewController = storyboard.instantiateViewController(withIdentifier: "MainTabbarViewController") as! MainTabbarViewController
                
                self.window!.rootViewController = mainViewController
                mainViewController.selectedIndex = 1
                
                guard let nc = mainViewController.viewControllers![1] as? UINavigationController else {
                    
                    print("navigation controller not found")
                    return
                    
                }
                
                if Int(dict["Metadata_Key1"] as? String ?? "") == 10 {
                    
                    let causeController = storyboard.instantiateViewController(withIdentifier: "CauseDetailViewController") as! CauseDetailViewController
                    causeController.eventModelData = eventObject
                    nc.view.backgroundColor = UIColor.white
                    nc.pushViewController(causeController, animated: true)
                    
                } else {
                    
                    let causeController = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
                    causeController.eventModelData = eventObject
                    nc.view.backgroundColor = UIColor.white

                    nc.pushViewController(causeController, animated: true)
                }
            } else {
                
                print("data not found")
            }
        }
    }
    
    
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
            
        }
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        
        Branch.getInstance().continue(userActivity)

    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // pass the url to the handle deep link call
        Branch.getInstance().application(app,
                                         open: url,
                                         options:options
        )
        
        if url.scheme == "fb1101639219980634" {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
            SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
        
        
        return true
        
    }
    
    
    func roomChannelRequest() {
    
        //identify_token
        guard let userInfoModel = Methods.sharedInstance.getUserInfoData() else {
            return
        }
        
        let firstName: String = userInfoModel.fullname!
        let lastName: String = userInfoModel.fullname!
        let displayName: String = userInfoModel.fullname!
        var dispalyImageUrl: String = ""
        
        if let profileImageUrl = userInfoModel.image {
            dispalyImageUrl = profileImageUrl
        } else {
            dispalyImageUrl = "http://lorempixel.com/400/200/"
        }
        
        
        // More advanced usage
        let room_identifier = ["user_id" : "1", "first_name": firstName, "last_name": lastName, "display_name": displayName, "avatar_url": dispalyImageUrl]
        
        print(room_identifier)

        
        let roomChannel = actionCableClient.create("TokenChannel") //The channel name must match the class name on the server

        
        //let roomChannel = actionCableClient.create("TokenChannel", identifier: room_identifier, autoSubscribe: true, bufferActions: true)
        
        // Receive a message from the server. Typically a Dictionary.
        roomChannel.onReceive = { (JSON : Any?, error : Error?) in
            print("Received", JSON ?? "", error ?? "")
        }
        
        // A channel has successfully been subscribed to.
        roomChannel.onSubscribed = {
            print("Yay!")
            roomChannel.action("token", with: room_identifier)
        }
        
        // A channel was unsubscribed, either manually or from a client disconnect.
        roomChannel.onUnsubscribed = {
            print("Unsubscribed")
        }
        
        // The attempt at subscribing to a channel was rejected by the server.
        roomChannel.onRejected = {
            print("Rejected")
        }
        

        
    }
    
    // MARK: - Alloc Layer Chat.
    
    func allocLayerClient() {
    
        let appID = URL(string: layerAppID)

        if layerClient == nil {
            layerClient = LYRClient(appID: appID!, delegate: self, options: nil)
            layerClient.autodownloadMIMETypes = Set<String>([ATLMIMETypeTextPlain, ATLMIMETypeImagePNG, ATLMIMETypeLocation, ATLMIMETypeImageJPEGPreview, ATLMIMETypeVideoMP4, ATLMIMETypeVideoQuickTime])
        }
        
        LayerChatSingleton.sharedInstance.connectLayerClient(layerClient: layerClient)
        
        /*
        NSString *const ATLMIMETypeTextPlain = @"text/plain";
        NSString *const ATLMIMETypeTextHTML = @"text/HTML";
        NSString *const ATLMIMETypeImagePNG = @"image/png";
        NSString *const ATLMIMETypeImageGIF = @"image/gif";
        NSString *const ATLMIMETypeVideoQuickTime = @"video/quicktime";
        NSString *const ATLMIMETypeImageSize = @"application/json+imageSize";
        NSString *const ATLMIMETypeImageJPEG = @"image/jpeg";
        NSString *const ATLMIMETypeImageJPEGPreview = @"image/jpeg+preview";
        NSString *const ATLMIMETypeImageGIFPreview = @"image/gif+preview";
        NSString *const ATLMIMETypeLocation = @"location/coordinate";
        NSString *const ATLMIMETypeDate = @"text/date";
        NSString *const ATLMIMETypeVideoMP4 = @"video/mp4";
        */
    }
    
    
    // - MARK LYRClientDelegate Delegate Methods
    func layerClient(_ client: LYRClient, didReceiveAuthenticationChallengeWithNonce userID: String) {
        print("Layer Client did recieve authentication challenge with nonce: \(userID)")
    }
    
    func layerClient(_ client: LYRClient, didAuthenticateAsUserID userID: String) {
        print("Layer Client did recieve authentication nonce: \(userID)")
    }
    
    func layerClientDidDeauthenticate(_ client: LYRClient) {
        print("Layer Client did deauthenticate")
    }
    
    func layerClient(_ client: LYRClient, didFinish contentTransferType: LYRContentTransferType, of object: Any) {
        print("Layer Client did finish sychronization")
    }
    
    func layerClient(_ client: LYRClient, didFailOperationWithError error: Error) {
        print("Layer Client did fail synchronization with error: \(error)")
    }
    
    func layerClient(_ client: LYRClient, willAttemptToConnect attemptNumber: UInt, afterDelay delayInterval: TimeInterval, maximumNumberOfAttempts attemptLimit: UInt) {
        print("Layer Client will attempt to connect")
    }
    
    func layerClientDidConnect(_ client: LYRClient) {
        print("Layer Client did connect")
        
//        if UserDefaults.standard.bool(forKey: "loginsession") == true {
//            
//            if let deviceToken = UserDefaults.standard.data(forKey: "device_token_Data") {
//            
//                // Update remote notification.
//                self.updateRemoteNotificationOnLayerDeviceToken(deviceToken: deviceToken)
//            
//            }
//            
//        }
        
    }
    
    func layerClient(_ client: LYRClient, didLoseConnectionWithError error: Error) {
        print("Layer Client did lose connection with error: \(error)")
    }
    
    func layerClientDidDisconnect(_ client: LYRClient) {
        print("Layer Client did disconnect")
    }
    
    //MARK:- Register Push Notification.
    internal func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print(deviceToken)
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        
        
        //        let data = token.data(using: .utf8)
        
        UserDefaults.standard.set(token, forKey: "device_token")
        UserDefaults.standard.set(deviceToken, forKey: "device_token_Data")
        
        print("Device Token: \(token)")
        
        
        if UserDefaults.standard.bool(forKey: "loginsession") == true {
            
            // Send device token to Layer so Layer can send pushes to this device.
            // For more information about Push, check out:
            // https://developer.layer.com/docs/ios/guides#push-notification
            assert(self.layerClient != nil, "The Layer client has not been initialized!")
            do {
                try self.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
                print("Application did register for remote notifications: \(deviceToken)")
            } catch let error as NSError {
                print("Failed updating device token with error: \(error)")
            }
            
        }
        
    }
    
    //Ios 10 delegates for Push Notifications
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        completionHandler([.sound, .alert, .badge])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
        let _ = response.notification.request.content.userInfo["aps"] as! [String : AnyObject]
        
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("APNs registration failed: \(error)")
        
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        
        if let aps_Dict = data["aps"]  as? Dictionary<String, AnyObject> {
            
            if (aps_Dict["category"] as? String ?? "") == "layer:///categories/default" {
                
                // Notification From layer Chat.
                // application.applicationIconBadgeNumber = aps_Dict["badge"] as? Int ?? 0
                
                if self.window!.rootViewController is MainTabbarViewController {
                    let tababarController = self.window!.rootViewController as! MainTabbarViewController
                    tababarController.selectedIndex = 3
                }
                
                //                DispatchQueue.main.async {
                //                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventListAPIReloadNotification"), object: self, userInfo: ["tabBarIndex": 3])
                //                }
                
                
            } else {
                
                // Notification From Server.
                
            }
            
        } else {
            
            // Aps Not found.
            
        }
        
    }
    

    
//    /* This function is using for update the token on layer */
//    func updateRemoteNotificationOnLayerDeviceToken(deviceToken: Data) {
//        
//        assert(self.layerClient != nil, "The Layer client has not been initialized!")
//        do {
//             try layerClient.updateRemoteNotificationDeviceToken(deviceToken)
////            if (success) {
//                print("Application did register for remote notifications: \(deviceToken)")
////            } else {
////                print("Failed updating device token with error")
////            }
//            
//        } catch let error as NSError {
//            print("Failed updating device token with error: \(error)")
//        }
//    }

    

    /* This function is using for Location Manager serverices and check the authorization status. */
    //MARK:- Location Manager Services
    func setupLocationManagerServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
        
            userCurrentLocation = manager.location!.coordinate
            print("com.new.App411-location-token-\(UserDefaults.standard.integer(forKey: "locationtokencount"))")

            
            if let userLatitude = UserDefaults.standard.value(forKey: "usercurrentlatitude") as? Float, let userLongitude = UserDefaults.standard.value(forKey: "usercurrentlongitude") as? Float {
                
                print(userLatitude, userLongitude)
                
                let userPastLocation = CLLocationCoordinate2DMake(CLLocationDegrees(userLatitude), CLLocationDegrees(userLongitude))
                
                if (userPastLocation.latitude == userCurrentLocation.latitude && userPastLocation.longitude == userCurrentLocation.longitude) {
                    
                    locationManager.stopUpdatingLocation()
                    return
                }

                
            }
            
            DispatchQueue.once(token: "com.new.App411-location-token-\(UserDefaults.standard.integer(forKey: "locationtokencount"))")  {
                // code to run once
                print("CLLocationCoordinate2D = \(userCurrentLocation)")
                
                // Save Data in local.
                UserDefaults.standard.set(userCurrentLocation.latitude, forKey: "usercurrentlatitude")
                UserDefaults.standard.set(userCurrentLocation.longitude, forKey: "usercurrentlongitude")
                
                UserDefaults.standard.set(true, forKey: "isuserlocationget")
                
                Singleton.sharedInstance.userCurrentLocation = userCurrentLocation
                
                
                locationManager.stopUpdatingLocation()
                
            }
            
        }
        
    }
  
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func showPopIfLocationServiceIsDisable() {
        
        let alert = UIAlertController(title: "Access to GPS is restricted", message: "GPS access is restricted. Show events by location, please enable GPS in the Settings > Privacy > Location Services.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            print("")
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        
        window?.rootViewController?.present(alert, animated: true)
        
    }
    
    
    
    
    
    // If user already login in app then don't need to call the signin & signup again. 
    // This app is creating a session.
    //MARK:- login view controller
    func loginViewController() {
        
        if UserDefaults.standard.bool(forKey: "loginsession") == true {
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let mainViewController: MainTabbarViewController = storyboard.instantiateViewController(withIdentifier: "MainTabbarViewController") as! MainTabbarViewController
            
            self.window?.rootViewController = mainViewController
            
            
            
            if let filterInfoList = UserDefaults.standard.value(forKey: "selectedFilter") as? [Dictionary<String, AnyObject>] {
                Singleton.sharedInstance.filterSelectedListInfo.removeAll()
                
                for filterInfoObj in filterInfoList {
                    
                    if let filterInfoMapperObj = Mapper<ASelectedFiltersInfoModel>().map(JSONObject: filterInfoObj) {
                        Singleton.sharedInstance.filterSelectedListInfo.append(filterInfoMapperObj)
                    }
                    
                }
                
            }
            
            if let distanceValue = UserDefaults.standard.value(forKey: "selectedDistance") {
                Singleton.sharedInstance.filterDistance = distanceValue as! String
            }
            
        }
        
    }
    
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()

        // Deauthenticate user after logout.
        LayerChatSingleton.sharedInstance.deauthenticateCurrentUser(layerClient: appDelegateShared.layerClient)
        
        Singleton.sharedInstance.clearTmpDirectory()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "App411")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    // Set Default Properties of navigation bar.
    //MARK:- Set Navigation
    func setNavigationAppearance() {
        
        UINavigationBar.appearance().tintColor = UIColor.darkGray
        
        UINavigationBar.appearance().isTranslucent = false
        
        UINavigationBar.appearance().clipsToBounds = false
                
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "SourceSansPro-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.black]
        
    }

}

