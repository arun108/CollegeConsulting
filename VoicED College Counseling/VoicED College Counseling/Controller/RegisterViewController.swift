//
//  RegisterViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SVProgressHUD
import ProgressHUD
import UIImageViewAlignedSwift

class RegisterViewController: UIViewController, UITextFieldDelegate {

    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    var defaultEmailAddress : String = ""
    var activeTextField = UITextField()
    var avatarName : String = ""
    
    //IBOutlets defined
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var teacherCode: UITextField!
    @IBOutlet weak var saveEmailAddress: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var avatar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: Set yourself as the delegate of the text fields here:
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        
        firstName.delegate = self
        lastName.delegate = self
        emailAddress.delegate = self
        password.delegate = self
        teacherCode.delegate = self
        saveEmailAddress.isOn = false
        registerButton.layer.cornerRadius = registerButton.frame.size.height / 5
        avatar.layer.cornerRadius = avatar.frame.size.height / 2
        avatar.clipsToBounds = true
        
        firstName.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        lastName.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        emailAddress.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        password.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        teacherCode.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAvatarImage), name: NSNotification.Name(rawValue: Constants.updateAvatarImage), object: nil)
    }
    
    //TODO: Objc function called to update avatar image from avatarcollectionViewcontroller
    @objc func updateAvatarImage() {
            
            UIGraphicsBeginImageContext(self.view.frame.size)
            UIImage(named: avatarName)?.draw(in: self.view.bounds)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            avatar.setImage(image, for: .normal)
        
            defaults.set(avatarName, forKey: Constants.avatarImage)
        }
    
    //TODO: Keyboard and cursor control
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeTextField = textField
        
        switch self.activeTextField.tag {
            case 0: do {
                firstName.resignFirstResponder()
                lastName.becomeFirstResponder()
            }
            case 1: do {
                lastName.resignFirstResponder()
                emailAddress.becomeFirstResponder()
            }
            case 2: do {
                emailAddress.resignFirstResponder()
                password.becomeFirstResponder()
            }
            case 3: do {
                password.resignFirstResponder()
                teacherCode.becomeFirstResponder()
            }
            case 4: do {
                teacherCode.resignFirstResponder()
                performRegistration()
            }
            default: break
        }
        return true
    }
    
    //TODO: Called from registerButtonPressed. Perform user registration validation and call registerUser
    func performRegistration () {
        SVProgressHUD.show()
        
        if let localFirstName = firstName.text, let localLastName = lastName.text, let localEmail = emailAddress.text, let localPassword = password.text {
            
            //TODO: Set up a new user on our Firbase database
            Auth.auth().createUser(withEmail: localEmail, password: localPassword) { (user, error) in
                if let e = error {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Registration Error! Try again.", message: String(describing: e.localizedDescription), preferredStyle: .alert)
                    let restartAction = UIAlertAction(title: "Okay", style: .default, handler: { (UIAlertAction) in })
                    alert.addAction(restartAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.registerUser(FN: localFirstName, LN: localLastName, Email: localEmail, TC: self.teacherCode.text ?? "nil", AV: self.avatarName)
                    SVProgressHUD.dismiss()
                    self.resetUserInfo()
                    self.performSegue(withIdentifier: Constants.registerToLoginSegue, sender: self)
                }
            }
        } else {
            SVProgressHUD.dismiss()
            ProgressHUD.showError("Full name, email address and password are mandatory. Try again.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toAvatarsSegue {
            let avatarVC = segue.destination as! AvatarCollectionViewController
            avatarVC.parentViewcontroller = self
        }
    }
    
    //TODO: Called from registerUser - Make entry to collection in VoicED database in Firestore
    func addUserToFirestore(firestoreFN: String, firestoreLN: String, firestoreEmail: String, firestoreTC: String, firestoreAV: String) {
        
        //Send user data to Firebase
        firstName.isEnabled = false
        lastName.isEnabled = false
        emailAddress.isEnabled = false
        teacherCode.isEnabled = false
        avatar.isEnabled = false
        
        //Get today's date in String format
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm a"
        let userCreatedDate = df.string(from: Date())
        var teacherMemberStatus: Bool = false
        
        if firestoreTC == "nil" {
            teacherMemberStatus = false
        } else {
            teacherMemberStatus = true
        }
        
        //Dictionary definition for data entry in to FireStore database
        let userDictionary: [String: Any] = ["UserFirstName": firestoreFN, "UserLastName": firestoreLN, "UserEmailAddress": firestoreEmail, "TeacherMemberID": teacherMemberStatus, "AvatarName": firestoreAV, "DateCreated": userCreatedDate]
        
        //Insert data in to FireStore database and provide confirmation
        db.collection(Constants.FStore.userCollection).document(firestoreEmail).setData(userDictionary) { error in
            
            if let e = error {
                let alert = UIAlertController(title: "Error Storing Data. Please try again.", message: String(describing: e), preferredStyle: .alert)
                let restartAction = UIAlertAction(title: "Okay", style: .default, handler: { (UIAlertAction) in  })
                alert.addAction(restartAction)
                self.present(alert, animated: true, completion: nil)
                self.resetUserInfo()
            } else {
                SVProgressHUD.dismiss()
                ProgressHUD.showSuccess("Registration Successful!")
            }
        }
    }
    
    //TODO: Called from PerformRegistration. Check for teacher code and teacher status and call addUserToFirestore
    func registerUser(FN: String, LN: String, Email: String, TC: String, AV: String) {
        
        let registeredFN = FN
        let registeredLN = LN
        let registeredEmail = Email
        let registeredTC = TC
        var localTeacherCode: String = ""
        let registeredAV = AV
        let docRef = db.collection(Constants.FStore.teacherCodeCollection).document(Constants.FStore.teacherCode)
            
        docRef.getDocument { (querySnapshot, error) in
            
            if let passcode = querySnapshot, passcode.exists {
                let teacherCode = passcode.data()!["TeacherCode"] as! String
                
                if registeredTC == teacherCode { localTeacherCode = registeredTC }
                else { localTeacherCode = "nil" }
            }
            self.addUserToFirestore(firestoreFN: registeredFN, firestoreLN: registeredLN, firestoreEmail: registeredEmail, firestoreTC: localTeacherCode, firestoreAV: registeredAV)
        }
    }
    
    //TODO: Reset user info displayed on screen
    func resetUserInfo() {
        
        firstName.isEnabled = true
        lastName.isEnabled = true
        emailAddress.isEnabled = true
        password.isEnabled = true
        teacherCode.isEnabled = true
        avatar.isEnabled = true
        
        firstName.text = ""
        lastName.text = ""
        emailAddress.text = ""
        password.text = ""
        teacherCode.text = ""
    }
    
    //MARK: - Buttons
    //TODO: Register button pressed
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performRegistration()
    }
    
    //TODO: Save email to user defaults
    @IBAction func saveEmailEnabled(_ sender: Any) {
        
        if saveEmailAddress.isOn {
            defaultEmailAddress = emailAddress.text ?? "No Email"
            
            if defaultEmailAddress == "No Email" {
                let alert = UIAlertController(title: "No Email to Save", message: "Enter email address to save. Address will be saved on this device", preferredStyle: .alert)
                let restartAction = UIAlertAction(title: "Okay", style: .default, handler: { (UIAlertAction) in  })
                alert.addAction(restartAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                defaults.set(defaultEmailAddress, forKey: Constants.defaultEmailAddress)
                defaults.set(saveEmailAddress.isOn, forKey: Constants.saveRegistrationEmail)
            }
        }
    }
}
