//
//  LoginViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ProgressHUD
import LocalAuthentication


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginEmailAddress: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var administration: UIButton!
    @IBOutlet weak var loginScreenLogin: UIButton!
    @IBOutlet weak var biometricScan: UISwitch!
    @IBOutlet weak var saveEmailAddress: UISwitch!
    @IBOutlet weak var mainMenu: UIButton!
    @IBOutlet weak var resetPassword: UIButton!
    
    let defaults = UserDefaults.standard
    let defaultsStoredEmail: String = ""
    let db = Firestore.firestore()
    
    var passwordExists = true
    let service = "VoicED App"
    var notificationEmailAddress : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        
        loginEmailAddress.delegate = self
        loginPassword.delegate = self
        loginEmailAddress.isHidden = false
        loginScreenLogin.layer.cornerRadius = loginScreenLogin.frame.size.height / 5
        administration.layer.cornerRadius = administration.frame.size.height / 5
        mainMenu.layer.cornerRadius = mainMenu.frame.size.height / 5
        resetPassword.layer.cornerRadius = resetPassword.frame.size.height / 5
        
        loginEmailAddress.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        loginPassword.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
    }
    
    //TODO: ViewWillAppear - setup buttons based on user defaults settings
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            loginEmailAddress.text = ""
            loginPassword.text = ""
        
        if let email = defaults.string(forKey: Constants.defaultEmailAddress) {
            loginEmailAddress.text = email
            if self.isValidEmail(loginEmailAddress.text!) {
                saveEmailAddress.isOn = true
            } else {
                saveEmailAddress.isOn = false
                biometricScan.isOn = false
            }
        } else {
                saveEmailAddress.isOn = false
                biometricScan.isOn = false
        }
            
        if defaults.bool(forKey: Constants.saveRegistrationEmail) {saveEmailAddress.isOn = true}
        else {saveEmailAddress.isOn = false}
        
        if defaults.bool(forKey: Constants.biometricScan) {
            if let email = defaults.string(forKey: Constants.defaultEmailAddress) {
                if let str = KeychainService.loadPassword(service: self.service, account: email) {
                    loginPassword.text = str
                    loginEmailAddress.text = email
                    biometricScan.isOn = true
                    saveEmailAddress.isOn = true
                    checkBiometricScan()
                }
                else {
                    ProgressHUD.showError("Password does not exist")
                    self.passwordExists = false
                    self.loginPassword.becomeFirstResponder()
                }
            } else {
                biometricScan.isOn = false
                defaults.set(false, forKey: Constants.biometricScan)
            }
        } else {biometricScan.isOn = false}
    }
    
    //TODO: Check for valid email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //TODO: Function to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if loginEmailAddress.isFirstResponder {
            if isValidEmail(loginEmailAddress.text ?? " ") {
                loginEmailAddress.resignFirstResponder()
                loginPassword.becomeFirstResponder()
            } else {notifyUser("Invalid Email Format", err: "Please enter valid email address")
                loginEmailAddress.becomeFirstResponder()
            }
        }
        else if loginPassword.isFirstResponder {
            loginPassword.resignFirstResponder()
            userAuthentication()
        }
        return true
    }
    
    //TODO: Function to save entry to Realm to avoid loosing data in case of interruption to the user entry process
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isValidEmail(loginEmailAddress.text ?? " ") {
            loginEmailAddress.resignFirstResponder()
        } else {
            notifyUser("Invalid Email Format", err: "Please enter valid email address")
            loginEmailAddress.becomeFirstResponder()
        }
    }
    
    //TODO: Function to ask user if they want to retrieve password stored locally usinf keychain
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if loginPassword.isFirstResponder {
            if passwordExists {
                let account = loginEmailAddress.text!
                let alert = UIAlertController(title: "Password Management", message: "Would you like to access Keychain to manage your password?", preferredStyle: .alert)
                let loadAction = UIAlertAction(title: "Retrieve", style: .default, handler: { (UIAlertAction) in
                    if let str = KeychainService.loadPassword(service: self.service, account: account) {
                       self.loginPassword.text = str
                    }
                    else {
                        ProgressHUD.showError("Password does not exist")
                        self.passwordExists = false
                        self.loginPassword.becomeFirstResponder()
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
                    self.passwordExists = false
                    self.loginPassword.becomeFirstResponder()
                })
                alert.addAction(loadAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //TODO: Perform biometric scan
    func checkBiometricScan() {
        
        let context = LAContext()
        var error: NSError?
            
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Device can use biometric authentication
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access requires authentication", reply: {(success, error) in
                DispatchQueue.main.async {
                    if let err = error {
                        switch err._code {
                            case LAError.Code.systemCancel.rawValue: self.notifyUser("Session cancelled", err: err.localizedDescription)
                                self.biometricScan.isOn = false
                            case LAError.Code.userCancel.rawValue: self.notifyUser("Please try again", err: err.localizedDescription)
                                self.biometricScan.isOn = false
                            case LAError.Code.userFallback.rawValue: self.notifyUser("Authentication", err: "You chose password authentication. Enter password and press Sign In")
                        default:
                            self.notifyUser("Authentication failed", err: err.localizedDescription)
                            self.biometricScan.isOn = false
                        }
                    } else {
                        self.defaults.set(true, forKey: Constants.biometricScan)
                        self.notifyUser("Authentication Successful", err: "You now have access to the app features")
                        let biometricAccount = self.loginEmailAddress.text ?? " "
                        if let str = KeychainService.loadPassword(service: self.service, account: biometricAccount) {
                           self.loginPassword.text = str
                           self.passwordExists = true
                           self.userAuthentication()
                        }
                        self.mainMenu.isHidden = false
                        self.loginScreenLogin.isHidden = true
                        self.loginEmailAddress.isEnabled = false
                        self.loginPassword.isEnabled = false
                        self.biometricScan.isEnabled = true
                        self.saveEmailAddress.isEnabled = true
                    }
                }
            })
        } else {
            // Device cannot use biometric authentication
            biometricScan.isOn = false
            if let err = error {
                switch  err.code {
                case LAError.Code.biometryNotEnrolled.rawValue:
                    notifyUser("User is not enrolled", err: err.localizedDescription)
                    loginEmailAddress.text = ""
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser("A passcode has not been set", err: err.localizedDescription)
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser("Biometric authentication not available", err: err.localizedDescription)
                default:
                    notifyUser("Unknown error", err: err.localizedDescription)
                }
            }
        }
    }
    
    //TODO: Authenticate users against Firestore
    func userAuthentication() {
           
           //TODO: Log in the user
           if let localEmailAddress = loginEmailAddress.text, let localPassword = loginPassword.text {
               notificationEmailAddress = localEmailAddress
               SVProgressHUD.show()
               Auth.auth().signIn(withEmail: localEmailAddress, password: localPassword) { (user, error) in
                   if error != nil {
                    SVProgressHUD.dismiss()
                    self.notifyUser("Login Error", err: "Either you are not registered or the email and password provided is incorrect")
                   } else {
                       self.loginScreenLogin.isHidden = true
                       self.hideButtons(emailAddress: localEmailAddress)
                       SVProgressHUD.dismiss()
                       self.askToSavePassword()
                   }
               }
           } else {notifyUser("Login Error", err: "Email address and password are mandatory. Try again.")}
    }
    
    //TODO: Buttons display based on type of user - Teacher/ User
    func hideButtons(emailAddress: String) {
           
           let checkEmailAddress = emailAddress
           let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
           docRef.getDocument { (querySnapshot, error) in
           
               if let document = querySnapshot, document.exists {
                   let teacherStatus = document.data()!["TeacherMemberID"] as! Bool
                   if teacherStatus {
                       self.administration.isHidden = false
                       self.mainMenu.isHidden = false
                       self.resetPassword.isHidden = false
                   } else {
                       self.administration.isHidden = true
                       self.mainMenu.isHidden = false
                       self.resetPassword.isHidden = false
                   }
               } else {
                   self.administration.isHidden = true
                   self.loginScreenLogin.isHidden = true
                   self.mainMenu.isHidden = true
                   self.resetPassword.isHidden = true
                   self.notifyUser("Login Error", err: "Database out of sync. Please contact support.")
               }
           }
    }
    
    //TODO: Invoke keychain service to save, update, delete password
    func askToSavePassword() {
        
        let voicedAccount = loginEmailAddress.text ?? " "
        let alert = UIAlertController(title: "Password Management", message: "Would you like to access Keychain to manage your password?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            let savePassword = self.loginPassword.text ?? " "
            KeychainService.savePassword(service: self.service, account: voicedAccount, data: savePassword)
        })
        let updateAction = UIAlertAction(title: "Update", style: .default, handler: { (UIAlertAction) in
            let updatePassword = self.loginPassword.text ?? " "
            KeychainService.updatePassword(service: self.service, account: voicedAccount, data: updatePassword)
            ProgressHUD.showSuccess("Password Updated!")
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (UIAlertAction) in
            KeychainService.removePassword(service: self.service, account: voicedAccount)
            self.loginPassword.text = ""
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
        })
            
        alert.addAction(saveAction)
        alert.addAction(updateAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Buttons
    //TODO: Enabled/ disabled biometric scan switch
    @IBAction func biometricScanEnabled(_ sender: UISwitch) {
        if biometricScan.isOn {
            if loginEmailAddress.text!.isEmpty {
                notifyUser("No Email Address Found", err: "No associated email address found. Please login with your email address & password and save your email address on this device the first time")
                saveEmailAddress.isOn = false
                biometricScan.isOn = false
            } else {
                if self.isValidEmail(loginEmailAddress!.text!) {
                    biometricScan.isOn = true
                    saveEmailAddress.isOn = true
                    defaults.set(true, forKey: Constants.saveRegistrationEmail)
                    if let str = KeychainService.loadPassword(service: self.service, account: loginEmailAddress!.text!) {
                        loginPassword.text = str
                        checkBiometricScan()
                    }
                    else {
                        ProgressHUD.showError("Password does not exist")
                        self.passwordExists = false
                        self.loginPassword.becomeFirstResponder()
                    }
                } else {
                    notifyUser("Invalid Email Format", err: "The email address entered is of incorrect format. Please enter your correct email address and try again")
                    biometricScan.isOn = false
                }
            }
        } else {
            biometricScan.isOn = false
            self.defaults.set(false, forKey: Constants.biometricScan)
        }
    }
    
    //TODO: Enable/ disable switch to save email address
    @IBAction func saveEmailEnabled(_ sender: UISwitch) {
        
        if saveEmailAddress.isOn {
            
            if loginEmailAddress.text!.isEmpty {
                notifyUser("No Email Address Found", err: "No associated email address found. Please login with your email address & password and save your email address on this device the first time")
                saveEmailAddress.isOn = false
                biometricScan.isOn = false
            } else {
                if self.isValidEmail(loginEmailAddress.text!) {
                    defaults.set(loginEmailAddress.text, forKey: Constants.defaultEmailAddress)
                    defaults.set(true, forKey: Constants.saveRegistrationEmail)
                } else {
                    notifyUser("Invalid Email Format", err: "The email address entered is of incorrect format. Please enter your correct email address and try again")
                    biometricScan.isOn = false
                }
            }
        } else {
            defaults.set("", forKey: Constants.defaultEmailAddress)
            defaults.set(false, forKey: Constants.saveRegistrationEmail)
            defaults.set(false, forKey: Constants.biometricScan)
            biometricScan.isOn = false
        }
    }
    
    //TODO: Logout
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        userAuthentication()
    }
    
    //TODO: Button to take you to main menu
    @IBAction func mainMenuButtonPressed(_ sender: UIButton) {
        
        if self.defaults.bool(forKey: Constants.askedToNotify) {
            //Register for push notification. Calls PushNotificationManager
            let notifRef = Firestore.firestore().collection(Constants.FStore.notificationCollection).document(notificationEmailAddress)
            notifRef.getDocument { (querySnapshot, error) in
            
                if let document = querySnapshot, document.exists {
                    let fcmToken = document.data()!["fcmToken"] as! String
                    if fcmToken == self.defaults.string(forKey: Constants.signedUpForNotify) {}
                    else {
                        let pushManager = PushNotificationManager(userID: self.notificationEmailAddress)
                        pushManager.registerForPushNotifications()
                        self.defaults.set(true, forKey: Constants.askedToNotify)
                    }
                }
            }
        }
        else {
            let pushManager = PushNotificationManager(userID: self.notificationEmailAddress)
            pushManager.registerForPushNotifications()
            defaults.set(true, forKey: Constants.askedToNotify)
        }
        self.performSegue(withIdentifier: Constants.loginToMainSegue, sender: self)
    }
    
    //TODO: Button to take you to admin screen
    @IBAction func administrationButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.loginToAdminSegue, sender: self)
    }
    
    //TODO: Button to reset password. Email is sent with link to google cloud page to reset app login password in Firestore
    @IBAction func resetPasswordButtonPressed(_ sender: UIButton) {
        if let emailForReset = loginEmailAddress.text {
            if self.isValidEmail(emailForReset) {
                SVProgressHUD.show()
                Auth.auth().sendPasswordReset(withEmail: emailForReset) { error in
                  if error != nil {
                      SVProgressHUD.dismiss()
                      self.notifyUser("Password Reset Error", err: error as? String)
                  } else {
                      SVProgressHUD.dismiss()
                      self.notifyUser("Password Reset", err: "A link to reset your password has been sent to your email address")
                  }
                }
            } else {
                notifyUser("Invalid Email Format", err: "The email address entered is of incorrect format. Please enter your correct email address and try again")
            }
        } else {
            self.notifyUser("Password Reset", err: "Input the email address to send reset password link to")
        }
    }
}
