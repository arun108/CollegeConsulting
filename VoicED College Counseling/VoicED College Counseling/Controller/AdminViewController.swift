//
//  AdminViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import SVProgressHUD

class AdminViewController: UIViewController, UITextFieldDelegate {

    let db = Firestore.firestore()
    var activeTextField = UITextField()
    
    @IBOutlet weak var teacherCode: UITextField!
    @IBOutlet weak var supportPhone: UITextField!
    @IBOutlet weak var supportEmail: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        
        teacherCode.delegate = self
        supportPhone.delegate = self
        supportEmail.delegate = self
        submitButton.layer.cornerRadius = submitButton.frame.size.height / 5
        
    }
    
    //TODO: Clear fields based on user selection of field. Only one entry allowed at a time. One button handles all requests.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        
        switch self.activeTextField.tag {
            case 0: do {
                self.teacherCode.text = ""
                self.supportEmail.text = ""
            }
            case 1: do {
                self.supportPhone.text = ""
                self.supportEmail.text = ""
            }
            case 2: do {
                self.supportPhone.text = ""
                self.teacherCode.text = ""
            }
            default: do {
                self.supportPhone.text = ""
                self.teacherCode.text = ""
                self.supportEmail.text = ""
            }
        }
    }
    
    //TODO: Called from submitButtonPressed. Based on field input by user process the data.
    func processUserInput() {
        if self.activeTextField.tag == 0 {
            SVProgressHUD.show()
            //TODO: Send user data to Firebase
            teacherCode.isEnabled = false
            supportPhone.isEnabled = true
            supportEmail.isEnabled = false
            
            //TODO: Define Firebase database connections and capture childByAutoID and its key
            if let supportPhone = self.supportPhone.text {
                db.collection(Constants.FStore.phoneCollection).document(Constants.FStore.phoneNumber).setData(["PhoneNumber": supportPhone]) { (error) in
                    if let e = error {
                        self.notifyUser("Error Saving Data", err: e as? String)
                        self.supportPhone.text = ""
                    } else {
                        ProgressHUD.showSuccess("Support Phone Updated Successfully!")
                        self.supportPhone.text = ""
                        self.supportPhone.isEnabled = true
                    }
                }
            }
            SVProgressHUD.dismiss()
        } else if self.activeTextField.tag == 1 {
            SVProgressHUD.show()
            //TODO: Send user data to Firebase
            teacherCode.isEnabled = true
            supportPhone.isEnabled = false
            supportEmail.isEnabled = false

            //TODO: Define Firebase database connections and capture childByAutoID and its key
            if let teacherCode = self.teacherCode.text {
                db.collection(Constants.FStore.teacherCodeCollection).document(Constants.FStore.teacherCode).setData(["TeacherCode": teacherCode]) { (error) in
                    if let e = error {
                        self.notifyUser("Error Saving Data", err: e as? String)
                        self.teacherCode.text = ""
                    } else {
                        ProgressHUD.showSuccess("Teacher Code Added Successfully!")
                        self.teacherCode.text = ""
                        self.teacherCode.isEnabled = true
                    }
                }
            }
            SVProgressHUD.dismiss()
        } else if self.activeTextField.tag == 2 {
            SVProgressHUD.show()
            //TODO: Send user data to Firebase
            teacherCode.isEnabled = false
            supportPhone.isEnabled = false
            supportEmail.isEnabled = true

            //TODO: Define Firebase database connections and capture childByAutoID and its key
            if let supportEmail = self.supportEmail.text {
                db.collection(Constants.FStore.emailCollection).document(Constants.FStore.emailAddress).setData(["EmailAddress": supportEmail]) { (error) in
                    if let e = error {
                        self.notifyUser("Error Saving Data", err: e as? String)
                        self.supportEmail.text = ""
                    } else {
                        ProgressHUD.showSuccess("Support Email Updated Successfully!")
                        self.supportEmail.text = ""
                        self.supportEmail.isEnabled = true
                        self.teacherCode.isEnabled = true
                        self.supportPhone.isEnabled = true
                    }
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //TODO: Keyboard control
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if teacherCode.isFirstResponder {teacherCode.becomeFirstResponder()}
        else {teacherCode.resignFirstResponder()}
        
        if supportPhone.isFirstResponder {supportPhone.becomeFirstResponder()}
        else {supportPhone.resignFirstResponder()}
        
        if supportEmail.isFirstResponder {
            processUserInput()
            supportEmail.resignFirstResponder()
        }
        else {supportEmail.resignFirstResponder()}
        
        return true
    }
    
    //TODO: Common function to send alerts to screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Buttons
    //TODO: Button to process user input. Calls function processUserInput
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        processUserInput()
        teacherCode.isEnabled = true
        supportPhone.isEnabled = true
        supportEmail.isEnabled = true
    }
    
}
