//
//  ScholarshipsViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 1/2/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import SafariServices
import Firebase
import ProgressHUD

class ScholarshipsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    var deviceType = UIDevice.current.name
    var deviceName: String = ""
    var fontSize: CGFloat = 0.0
    var spaceBetween: CGFloat = 0.0
    var fontName: String = "HelveticaNeue-Bold"
    
    @IBOutlet weak var scholarshipText: UITextView!
    
    @IBOutlet weak var scholarshipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        defineFontSize()
        fieldPosition()
        loadWebpage()
    }
    
    //TODO: Custom function to truncate string
    func trunc(length: Int, word: String) -> String {
        return (word.count > length) ? String(word.prefix(length)) : word
    }
    
    //TODO: layout the fields programatically
    func defineFontSize() {
        
        //Call custom function to truncate the device name this program is running on to requested length
        deviceName = trunc(length: 4, word: deviceType)
        
        if deviceName == "iPad" {
            spaceBetween = 20.0
            fontSize = 20.0
        } else {
            deviceName = trunc(length: 8, word: deviceType)
            if deviceName == "iPhone 8" {
                spaceBetween = 0.0
                fontSize = 14.0
            } else {
                spaceBetween = 10.0
                fontSize = 14.0
            }
        }
    }
    
    //TODO: Text positioning
    func fieldPosition() {
        scholarshipText.textAlignment = .left
        scholarshipText.font = UIFont.systemFont(ofSize: fontSize)
        scholarshipButton.layer.cornerRadius = scholarshipButton.frame.size.height / 5
    }
    
    //TODO: Load VoicED webpage on Scholarships in safari
    func loadWebpage() {
        
        //Load URL
        let url = Constants.scholarshipArticle
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to launch VoicED webpage on Scholarships in safari
    @IBAction func scholarshipButtonPressed(_ sender: UIButton) {
        loadWebpage()
    }
    
    //TODO: Logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            }
            catch {
                ProgressHUD.showError("Error, there was a problem signing out.")
            }
        }
}
    

