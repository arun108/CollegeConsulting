//
//  PaymentViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 1/2/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import SafariServices
import Firebase
import ProgressHUD

class ClassRegisterViewController: UIViewController, SFSafariViewControllerDelegate {

    
    @IBOutlet weak var collegeEssayPrep: UILabel!
    @IBOutlet weak var collegeEssaySummary: UITextView!
    @IBOutlet weak var collegeEssayButton: UIButton!
    @IBOutlet weak var collegeCounsel: UILabel!
    @IBOutlet weak var collegeCounselSummary: UITextView!
    @IBOutlet weak var collegeCounselButton: UIButton!
    @IBOutlet weak var grammarClass: UILabel!
    @IBOutlet weak var grammarClassSummary: UITextView!
    @IBOutlet weak var grammarClassButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var voicEDLogo: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    var labelArray: [UILabel] = [UILabel]()
    var textArray: [UITextView] = [UITextView]()
    var buttonArray: [UIButton] = [UIButton]()
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    
    var deviceType = UIDevice.current.name
    var deviceName: String = ""
    var fontSize: CGFloat = 0.0
    var spaceBetween: CGFloat = 0.0
    var fontName: String = "HelveticaNeue-Bold"
    var serviceType : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        fetchPhoneNumber()
        
        labelArray = [collegeEssayPrep, collegeCounsel, grammarClass]
        textArray = [collegeEssaySummary, collegeCounselSummary, grammarClassSummary]
        buttonArray = [collegeEssayButton, collegeCounselButton, grammarClassButton]
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
        
        collegeEssayButton.layer.cornerRadius = collegeEssayButton.frame.size.height / 5
        collegeCounselButton.layer.cornerRadius = collegeCounselButton.frame.size.height / 5
        grammarClassButton.layer.cornerRadius = grammarClassButton.frame.size.height / 5
        
        fieldLayout()
    }
    
    //TODO: Fetch support phone number from Firestore
    func fetchPhoneNumber() {
        
        let docRef = db.collection(Constants.FStore.phoneCollection).document(Constants.FStore.phoneNumber)
        
        docRef.getDocument { (querySnapshot, error) in
        
            if let document = querySnapshot, document.exists {
                let number = document.data()!["PhoneNumber"] as? String
                self.phoneNumberButton.setTitle(number, for: .normal)
                self.defaults.set(number, forKey: Constants.supportPhone)
            } else {
                self.phoneNumberButton.setTitle(Constants.phoneNumber, for: .normal)
                self.defaults.set(Constants.phoneNumber, forKey: Constants.supportPhone)
            }
        }
    }
    
    //TODO: Custom function to truncate string
    func trunc(length: Int, word: String) -> String {
        return (word.count > length) ? String(word.prefix(length)) : word
    }
    
    //TODO: Define fontSize based on device - ipad or iphone
    func defineFontSize() {
        //Call custom function to truncate the device name this program is running on to requested length
        deviceName = trunc(length: 4, word: deviceType)
        
        if deviceName == "iPad" {
            spaceBetween = 120.0
            fontSize = 20.0
        } else {
            deviceName = trunc(length: 8, word: deviceType)
            if deviceName == "iPhone 8" {
                spaceBetween = 0.0
                fontSize = 14.0
            } else {
                spaceBetween = 5.0
                fontSize = 14.0
            }
        }
    }
    
    //TODO: layout the fields programatically
    func fieldLayout() {
        
        defineFontSize()
        
        var positionY: CGFloat = 75
        
        for i in 0..<buttonArray.count {

            labelArray[i].frame = CGRect(x: 20, y: positionY, width: self.view.frame.width - 40, height: 40)
            labelArray[i].font = UIFont.init(name: fontName, size: fontSize)

            positionY = positionY + labelArray[i].frame.height + spaceBetween

            if i == 0 {serviceType = Constants.collegeEssayText}
            else if i == 1 {serviceType = Constants.collegeConsultingText}
            else if i == 2 {serviceType = Constants.grammarClassText}
            textArray[i].text = serviceType
            textArray[i].textAlignment = .left
            textArray[i].font = UIFont.systemFont(ofSize: fontSize)
            textArray[i].frame.origin.x = 20
            textArray[i].frame.origin.y = positionY
            let frameWidth = self.view.frame.width - 40
            let newFrameSize = textArray[i].sizeThatFits(CGSize(width: frameWidth, height: CGFloat.greatestFiniteMagnitude))
            textArray[i].frame.size = CGSize(width: max(newFrameSize.width, frameWidth), height: newFrameSize.height)

            positionY = positionY + textArray[i].frame.height + spaceBetween

            buttonArray[i].frame = CGRect(x: 20, y: positionY, width: self.view.frame.width - 40, height: 40)
            buttonArray[i].titleLabel?.font = UIFont.init(name: fontName, size: fontSize)
            buttonArray[i].layer.cornerRadius = buttonArray[i].frame.size.height / 5

            positionY = positionY + buttonArray[i].frame.height + spaceBetween
        }
    }
    
    //TODO: Button to open VoicED collegeEssay registration webpage in safari
    @IBAction func collegeEssayButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.collegeEssayArticle
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to open VoicED college consultation webpage in safari
    @IBAction func collegeCounselButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.collegeCounselArticle
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to open VoicED grammar class registration webpage in safari
    @IBAction func grammarClassButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.grammarClassArticle
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to open VoicED website in safari
    @IBAction func logoButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.voicedAcademy
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to open VoicED Facebook page
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.facebookLink
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to open VoicED Instagram page
    @IBAction func instagramButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.instagramLink
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to open VoicED Twitter page
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        //Load URL
        let url = Constants.twitterLink
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //TODO: Button to call VoicED support line
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        let phoneNumber = defaults.string(forKey: Constants.supportPhone) ?? Constants.phoneNumber
        let supportPhoneNumber = "tel://" + (phoneNumber)
        guard let number = URL(string: supportPhoneNumber) else { return }
        UIApplication.shared.open(number)
    }
    
    //TODO: Button to call VoicED support line
    @IBAction func phoneNumberButtonPressed(_ sender: UIButton) {
        let phoneNumber = defaults.string(forKey: Constants.supportPhone) ?? Constants.phoneNumber
        let supportPhoneNumber = "tel://" + (phoneNumber)
        guard let number = URL(string: supportPhoneNumber) else { return }
        UIApplication.shared.open(number)
    }
    
    //TODO: Logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
                //cleanupRealmBeforeLogout()
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            }
            catch {
                ProgressHUD.showError("Error, there was a problem signing out.")
            }
    }
}
    

