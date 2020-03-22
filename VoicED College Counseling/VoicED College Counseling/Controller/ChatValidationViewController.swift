//
//  ChatValidationViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/3/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import SVProgressHUD
import ProgressHUD
import Firebase
import LocalAuthentication

class ChatValidationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var validateButton: UIButton!
    
    var passwordExists = true
    let service = "VoicED App"
    var backToChatRegister : Bool = false
    var passedEmailAddress : String = ""
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.purple
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        validateButton.layer.cornerRadius = validateButton.frame.size.height / 5
        
        emailAddress.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        password.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        password.delegate = self
        emailAddress.delegate = self
        emailAddress.isEnabled = false
        emailAddress.text = passedEmailAddress
        
        if passedEmailAddress == "" {emailAddress.isEnabled = true}
        
    }
    
    //TODO: Skip chat validation if coming back from Group Chat
    override func viewWillAppear(_ animated: Bool) {
        backToChatRegister = defaults.bool(forKey: Constants.backToChatRegister)
        if backToChatRegister {
            backToChatRegister = false
            self.defaults.set(false, forKey: Constants.backToChatRegister)
            navigationController?.popViewController(animated: true)
        }
    }
    
    //TODO: Keyboard control
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailAddress.isFirstResponder {
            emailAddress.resignFirstResponder()
            password.becomeFirstResponder()
        }
        else if password.isFirstResponder {
            password.resignFirstResponder()
            userAuthentication()
        }
        return true
    }
    
    //TODO: Enable password retrieval from Keychain
    func textFieldDidBeginEditing(_ textField: UITextField) {
                
        if password.isFirstResponder {
            if passwordExists {
                let account = emailAddress.text ?? " "
                let alert = UIAlertController(title: "Password Management", message: "Would you like to access Keychain to manage your password?", preferredStyle: .alert)
                let loadAction = UIAlertAction(title: "Retrieve", style: .default, handler: { (UIAlertAction) in
                    if let str = KeychainService.loadPassword(service: self.service, account: account) {
                       self.password.text = str
                    }
                    else {
                        ProgressHUD.showError("Password does not exist")
                        self.passwordExists = false
                        self.password.becomeFirstResponder()
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
                    self.passwordExists = false
                    self.password.becomeFirstResponder()
                })
                alert.addAction(loadAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //TODO: User authentication against Firestore before permitting user to use Group Chat
    func userAuthentication() {
           
           if let localEmailAddress = emailAddress.text, let localPassword = password.text {
               
               SVProgressHUD.show()
               Auth.auth().signIn(withEmail: localEmailAddress, password: localPassword) { (user, error) in
                   if error != nil {
                       SVProgressHUD.dismiss()
                       self.notifyUser("Login Error", err: "Either you are not registered or you have not provided your email and password")
                   } else {
                       SVProgressHUD.dismiss()
                       ProgressHUD.showSuccess("Login Successful!")
                       self.performSegue(withIdentifier: Constants.toChatWindowSegue, sender: self)
                   }
               }
           } else {notifyUser("Login Error", err: "Email address and password are mandatory. Try again.")}
    }
    
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //TODO: Prepare segues - one to go to Chatting ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toChatWindowSegue {
            let chatWindowVC = segue.destination as! ChatViewController
            if let emailToBePassed = emailAddress.text {
                chatWindowVC.chatEmailAddress = emailToBePassed
            }
        }
    }
    
    //MARK: - Buttons
    //TODO: Button to call user authentication
    @IBAction func validateButtonPressed(_ sender: UIButton) {
        self.defaults.set(true, forKey: Constants.backToChatRegister)
        let account = emailAddress.text ?? " "
        if let str = KeychainService.loadPassword(service: self.service, account: account) {
           password.text = str
           passwordExists = true
           userAuthentication()
        }
    }
}