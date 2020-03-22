//
//  PushNotificationSender.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/12/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import UserNotifications

class PushNotificationSender {
    
    func sendPushNotification(to token: String, count: Int, title: String, body: String) {
        let urlString = Constants.fcmURL
        let badgeCount = count
        let url = NSURL(string: urlString)!
        let userID = Auth.auth().currentUser?.email
        let paramString: [String : Any] = ["to" : token,
                                           "badge" : badgeCount,
                                           "sound" : "default",
                                           "alert" : ["title" : title, "body" : body],
                                           "data" : ["user" : userID]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.firestoreServerKey, forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict)")
                    }
                }
            } catch let err as NSError {ProgressHUD.showError(err.debugDescription)}
        }
        task.resume()
    }
}
