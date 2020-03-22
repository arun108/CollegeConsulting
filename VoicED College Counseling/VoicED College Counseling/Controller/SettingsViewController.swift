//
//  SettingsViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 1/2/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import MessageUI
import RealmSwift
import SVProgressHUD

class SettingsViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    var retrievedCategory : String = ""
    var retrievedTask : String = ""
    var retrievedStatus : String = ""
    var emailCategories : String = "All Categories"
    var nothingToExport : Bool = false
    var supportEmail : String = ""
    var avatarName : String = ""
    
    var planList: Results<Planner>?
    var finalExportList: Results<Planner>?
    var taskList: Results<Tasks>?
    var selectedCategory: Planner? {
        didSet{
            loadTask()
        }
    }
    var exportPlannerArray : [String] = ["All Categories"]
    var csvString = "\("Category"),\("Tasks"),\("Status"),\("Date Created")\n"
    var activeTextField = UITextField()
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    let db = Firestore.firestore()
    let fileName = "Planner.csv"
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var avatar: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newPassword.delegate = self
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        emailButton.layer.cornerRadius = emailButton.frame.size.height / 5
        feedbackButton.layer.cornerRadius = feedbackButton.frame.size.height / 5
        submitButton.layer.cornerRadius = submitButton.frame.size.height / 5
        
        setupAvatar()
        
        planList = realm.objects(Planner.self)
        
        if planList != nil {
            for rec in 0..<planList!.count {
                exportPlannerArray.append((planList![rec].plannerName))
            }
        } else {exportPlannerArray = ["No Categories"]}  //ProgressHUD.showError("Nothing to Export")}
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAvatarImage), name: NSNotification.Name(rawValue: Constants.updateAvatarImage), object: nil)
    }
    
    @objc func updateAvatarImage() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: avatarName)?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        avatar.setImage(image, for: .normal)
        
        SVProgressHUD.show()
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        let emailAddress = Auth.auth().currentUser?.email ?? email
        db.collection(Constants.FStore.userCollection).document(emailAddress).setData(["AvatarName": avatarName], merge: true)
        defaults.set(avatarName, forKey: Constants.avatarImage)
        SVProgressHUD.dismiss()
    }
    
    //TODO: Gather avatar information for this user
    func setupAvatar() {
        
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        let emailAddress = Auth.auth().currentUser?.email ?? email
        retrieveAvatarName(emailAddress: emailAddress)
        avatarName = defaults.string(forKey: Constants.avatarImage) ?? "imageProfile"
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: avatarName)?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        avatar.setImage(image, for: .normal)
        avatar.frame.size.width = 80
        avatar.layer.cornerRadius = avatar.frame.size.height / 2
        avatar.clipsToBounds = true
        
    }
    
    func retrieveAvatarName(emailAddress: String) {
        
        var retrievedAvatarName : String = ""
        let checkEmailAddress = emailAddress
        
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        docRef.getDocument { (querySnapshot, error) in
            if let document = querySnapshot, document.exists {
                retrievedAvatarName = document.data()!["AvatarName"] as? String ?? "imageProfile"
                self.defaults.set(retrievedAvatarName, forKey: Constants.avatarImage)
            } else {self.defaults.set("imageProfile", forKey: Constants.avatarImage)}
        }
    }
    
    //TODO: Keyboard control
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if newPassword.isFirstResponder {
            newPassword.resignFirstResponder()
            passwordUpdate()
        }
        return true
    }
    
    //TODO: Function to update password in Firestore
    func passwordUpdate() {
           
       //TODO: Update password
        SVProgressHUD.show()
        if let password = newPassword.text {
            // Prompt the user to re-provide their sign-in credentials
            Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                  if let error = error {
                      SVProgressHUD.dismiss()
                      self.notifyUser("Update Error", err: error as? String)
                  } else {
                      SVProgressHUD.dismiss()
                      ProgressHUD.showSuccess("Password Change Successful!")
                  }
            }
        } else {
            SVProgressHUD.dismiss()
           notifyUser("Update Error", err: "If you used biometric scan to login then you will have to logout and use email/ password to make updates")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.editProfileAvatarSegue {
            let updateAvatarVC = segue.destination as! SettingsCollectionViewController
            updateAvatarVC.parentViewcontroller = self
        }
    }
    
    //TODO: Create CSV with data to be emailed. Call taskListCreation function
    func createCSV() {
        
        let fileManager = FileManager.default
        if emailCategories == "No Categories" {emailButton.isEnabled = false}
        else {
            emailButton.isEnabled = true
            finalExportList = planList?.sorted(byKeyPath: "plannerName", ascending:  true)
            if finalExportList != nil {
                for rec in 0..<finalExportList!.count {
                    if emailCategories == "All Categories" {
                        selectedCategory = finalExportList![rec]
                        taskListCreation()
                    } else {
                        if finalExportList![rec].plannerName == emailCategories {
                            selectedCategory = finalExportList![rec]
                            taskListCreation()
                        } else {ProgressHUD.showError("End of List Reached")}
                    }
                }
            } else {
                ProgressHUD.showError("Nothing to Export")
                nothingToExport = true
            }
        }
        
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent(self.fileName)
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {ProgressHUD.showError("Could not write to csv file. Please try again.")}
        
       csvString = ""
    }
    
    //TODO: Load tasks list from Realm sorted by Task Name
    func loadTask() {
        taskList = selectedCategory?.tasks.sorted(byKeyPath: "taskName", ascending:  true)
    }
    
    //TODO: Write to CSV
    func taskListCreation() {
        loadTask()
        if taskList != nil {
            for rec in 0..<taskList!.count {
                
                if taskList![rec].done {retrievedStatus = "Done"} else {retrievedStatus = "Not Done"}
                let date = taskList![rec].dateCreated
                
                if let nameOfPlanner = selectedCategory?.plannerName, let retrievedTask = taskList?[rec].taskName, let dueDate = date {
                    if retrievedTask == "" {
                        nothingToExport = true
                        return
                    } else {csvString = csvString.appending("\(nameOfPlanner),\(retrievedTask),\(retrievedStatus),\(dueDate)\n")}
                }
            }
        } else {
            nothingToExport = true
            ProgressHUD.showError("Nothing to Export")}
    }
    
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: Compose the email
    func configureMailComposeViewController(message : String) -> MFMailComposeViewController {
        
        let typeOfMessage = message
        let fileManager = FileManager.default
        
        let emailController = MFMailComposeViewController()
        
        let docRef = db.collection(Constants.FStore.emailCollection).document(Constants.FStore.emailAddress)
        
        docRef.getDocument { (querySnapshot, error) in
        
            if let document = querySnapshot, document.exists {
                self.supportEmail = document.data()!["EmailAddress"] as! String
                self.defaults.set(self.supportEmail, forKey: Constants.supportEmail)
            }
        }
        
        if typeOfMessage == "Report" {
            let userEmail = Auth.auth().currentUser?.email ?? Constants.defaultEmailAddress
            emailController.setToRecipients([userEmail])
            emailController.mailComposeDelegate = self
            emailController.setSubject("[VoicED]: Status of Tasks")
            emailController.setMessageBody("Hello,\n\n         Attached is the status report for your college prep. It shows the tasks created in the app and the status of each.\n\n Thank You,\nThe voicED Team\n", isHTML: false)
        } else if typeOfMessage == "Feedback" {
            let userEmail = defaults.string(forKey: Constants.supportEmail) ?? "voiced.academy@gmail.com"
            emailController.setToRecipients([userEmail])
            emailController.mailComposeDelegate = self
            emailController.setSubject("[VoicED]: Feedback")
            emailController.setMessageBody("Hello,\n\n         Here is feedback for VoicED.\n\n App Related:\n\n1.\n\n Services Related:\n\n1.\n\n Others:\n\n1.\n\n", isHTML: false)
        }
        
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent(self.fileName)
            let data = try Data(contentsOf: fileURL)
            if typeOfMessage == "Report" {emailController.addAttachmentData(data, mimeType: "text/csv", fileName: fileName)}
            } catch _ {}
        
        return emailController
    }
    
    //TODO: Email controller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //TODO: Call function to compose email
    func composeEmail(task : String) {
        
        let natureOfEmail = task
        if natureOfEmail == "Report" {
            let emailViewController = configureMailComposeViewController(message : natureOfEmail)
            if MFMailComposeViewController.canSendMail() {
                self.present(emailViewController, animated: true, completion: nil)
            } else {
                ProgressHUD.showError("Your device is not configured to send emails")
            }
        } else if natureOfEmail == "Feedback" {
            let emailViewController = configureMailComposeViewController(message : natureOfEmail)
            if MFMailComposeViewController.canSendMail() {
                self.present(emailViewController, animated: true, completion: nil)
            } else {
                ProgressHUD.showError("Your device is not configured to send emails")
            }
        }
    }
    
    //TODO: - Clean files in cache. Called from CreateCSV before new file is created
    func cleanFileFromCache() {
        let fileManager = FileManager.default
        
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent(fileName)
            let filePath = fileURL.path
            let files = try fileManager.contentsOfDirectory(atPath: "\(filePath)")
            let filePathName = "\(filePath)/\(files)"
            try fileManager.removeItem(atPath: filePathName)
        } catch _ {}
    }
    
    //MARK: - Buttons
    //TODO: Submit button to update password
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if newPassword.text!.isEmpty {notifyUser("Password Update Error", err: "Password cannot be blank")}
        else {passwordUpdate()}
            newPassword.text = ""
            newPassword.isEnabled = true
    }
    
    //TODO: Button to send email with planner and status of tasks
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        
        createCSV()
        if nothingToExport || emailCategories == "No Categories" {
            notifyUser("Nothing to Export", err: "No list was generated to be emailed")
        } else {composeEmail(task : "Report")}
        cleanFileFromCache()
        
    }
    
    //TODO: Compose email to let users send feedback to VoicED
    @IBAction func feedbackButtonPressed(_ sender: UIButton) {
        
        composeEmail(task : "Feedback")
    }
    
    //TODO: Logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {ProgressHUD.showError("Error signing out.")}
    }
}

//MARK: - Pickerview to select list of categories from Planner
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exportPlannerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return exportPlannerArray[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        emailCategories = ""
        emailCategories = exportPlannerArray[row]
        categoryPicker.reloadAllComponents()
    }
}

