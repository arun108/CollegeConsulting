//
//  PushNotificationManager.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/13/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    let defaults = UserDefaults.standard
    
    //TODO: Register for push notification - handling version of iOS
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 1
        updateFirestorePushTokenIfNeeded()
    }
    
    //TODO: Update Firestore with userID and associated device token
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            print("FCM Token: ", token)
            let usersRef = Firestore.firestore().collection(Constants.FStore.notificationCollection).document(userID)
            usersRef.setData(["fcmToken": token]) //, merge: false
            defaults.set(token, forKey: Constants.signedUpForNotify)
        }
    }
    
    //TODO: Function to update Firestore if registration token is received
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
}
