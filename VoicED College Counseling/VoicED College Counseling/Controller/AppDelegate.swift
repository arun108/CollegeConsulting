//
//  AppDelegate.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/15/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import IQKeyboardManagerSwift
import ProgressHUD
import UserNotifications
import FirebaseMessaging
import EventKit

@UIApplicationMain
class AppDelegate: UIViewController, UIApplicationDelegate, MessagingDelegate {
    //UIResponder was replaced by RouletteViewController

    var window: UIWindow?
    let defaults = UserDefaults.standard
    var countOfNotification : Int = 0
    var eventStore: EKEventStore?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Initialize and configure firebase database
        
        FirebaseApp.configure()
        
        _ = Firestore.firestore()
        
        do {
            _ = try Realm()
        } catch {
            ProgressHUD.showError("Error initializing new realm, \(error)")
        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // Check if launched from notification. Registration for push notification happens during user registration.
        let notificationOption = launchOptions?[.remoteNotification]
        
        if (notificationOption as? [String: AnyObject]) != nil {
          let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
          let initialViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as UIViewController
          self.window = UIWindow(frame: UIScreen.main.bounds)
          self.window?.rootViewController = initialViewController
          self.window?.makeKeyAndVisible()
            
          navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
          navigationItem.backBarButtonItem?.tintColor = UIColor.white
          navigationController?.navigationBar.barTintColor = UIColor.red
        }
        return true
    }
    
    //TODO: If app entered background while on main menu then update userdefaults as handling is needed when it comes to foreground
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let wd = UIApplication.shared.delegate?.window {
            var vc = wd!.rootViewController
            if (vc is UINavigationController) {
                vc = (vc as! UINavigationController).visibleViewController
            }
            if(vc is RouletteViewController){self.defaults.set(true, forKey: Constants.resignFromMainMenu)}
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let resignFromMainMenu = defaults.bool(forKey: Constants.resignFromMainMenu)
        if resignFromMainMenu {
            if let wd = UIApplication.shared.delegate?.window {
            var vc = wd!.rootViewController
                if(vc is UINavigationController){
                    vc = (vc as! UINavigationController).popViewController(animated: true)
                    self.defaults.set(false, forKey: Constants.resignFromMainMenu)
                }
            }
        }
        defaults.set(0, forKey: "NotificationCount")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //TODO: Logout before app will terminate
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch { ProgressHUD.showError("Error, there was a problem signing out.") }
    }
    
    //TODO: Get device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }
    
    //TODO: Handle error when registering for remote notification
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ProgressHUD.showError(("Failed to Register for Notifications: \(error)"))
    }
    
    //TODO: Handle receiving remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let state = UIApplication.shared.applicationState
        switch state {

        case .inactive:
            countOfNotification = defaults.integer(forKey: "NotificationCount")
            countOfNotification += 1
            print("Count Of Notification1: ",countOfNotification)
            defaults.set(countOfNotification, forKey: "NotificationCount")
            UIApplication.shared.applicationIconBadgeNumber = countOfNotification
        case .background:
            countOfNotification = defaults.integer(forKey: "NotificationCount")
            countOfNotification += 1
            print("Count Of Notification2: ",countOfNotification)
            defaults.set(countOfNotification, forKey: "NotificationCount")
            UIApplication.shared.applicationIconBadgeNumber = countOfNotification
        case .active:
            print("Active")
        default :
            countOfNotification = defaults.integer(forKey: "NotificationCount")
            countOfNotification += 1
            print("Count Of Notification3: ",countOfNotification)
            defaults.set(countOfNotification, forKey: "NotificationCount")
            UIApplication.shared.applicationIconBadgeNumber = countOfNotification
        }
    }
}
