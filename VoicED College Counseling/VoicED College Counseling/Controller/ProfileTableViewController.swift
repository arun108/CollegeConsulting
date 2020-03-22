//
//  ProfileTableViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/26/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import SwipeCellKit
import RealmSwift
import PDFKit
import StoreKit
import SVProgressHUD
import ChameleonFramework

class ProfileTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    var profileArray: [Profiles] = [Profiles]()
    var profile: String = "No Profiles Added"
    var info : String = "No Additional Info"
    var webpageURL: String = ""
    var cellLabelText : String = ""
    var cellAdditionalInfo : String = ""
    var pdfDocument : String = ""
    var productID : String = ""
    var fromResource : Bool = false
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    var profileList: Results<ProfileRealmData>?

    @IBOutlet weak var addProfileButton: UIBarButtonItem!
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 120.0
        
        cleanupRealm()
        retrieveProfile()
        
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        hideFeatures(emailAddress: Auth.auth().currentUser?.email ?? email)
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ProfileTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        defaults.set(true, forKey: Constants.backFromProfileTableView)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //TODO: Function that performs the purchase transaction
    func buyProfile(rowProfile : String) {
        productID = rowProfile
        SVProgressHUD.show()
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {notifyUser("Unable to Purchase", err: "Check your Settings if it allows purchases")}
        SVProgressHUD.dismiss()
    }
    
    //TODO: Handle purchase, fail and restore
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                markPaidProfiles()
                cleanupRealm()
                retrieveProfile()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    notifyUser("Transaction Error", err: "Transaction failed due to: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                profileTableView.reloadData()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    //TODO: Function to mark the paid profiles. Set user purchase as true for the product ID if purchase was made
    func markPaidProfiles() {
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        let emailAddress = Auth.auth().currentUser?.email ?? email
       
        //Dictionary definition for data entry in to FireStore database
        let purchaseDict: [String: Any] = [Constants.FStore.purchaser: emailAddress,
                                           Constants.FStore.purchasedProfile: profile,
                                           Constants.FStore.productID: productID,
                                           Constants.FStore.purchased : true,
                                           Constants.FStore.dateCreated: Date().timeIntervalSince1970]
        db.collection(Constants.FStore.profilePurchaseCollection).addDocument(data: purchaseDict) { error in
            if let e = error { self.notifyUser("Error Purchasing. Please try again.", err: String(describing: e)) }
            else { ProgressHUD.showSuccess("Purchase Successful!") }
        }
    }
    
    //TODO: Check if purchase was done.
    func isPurchased(profileProductID : String) -> Bool {
        var purchaseStatus : Bool = false
        let purchasedProductID = profileProductID
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        let emailAddress = Auth.auth().currentUser?.email ?? email
        let docRef = db.collection(Constants.FStore.profilePurchaseCollection).whereField("Purchaser", isEqualTo: emailAddress).whereField("ProductID", isEqualTo: purchasedProductID)
        
        docRef.getDocuments() { (querySnapshot, error) in
        
            if let err = error {
                self.notifyUser("Error Retrieving Purchase Data", err: String(describing: err))
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let purchased = data["Purchased"] as? Bool {
                        purchaseStatus = purchased
                        self.defaults.set(purchaseStatus, forKey: purchasedProductID)
                    }
                }
            }
        }
        return defaults.bool(forKey: purchasedProductID)
    }
    
    //TODO: Display or hide add Profile button
    func hideFeatures(emailAddress: String) {
        
        let checkEmailAddress = emailAddress
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        docRef.getDocument { (querySnapshot, error) in
            if let document = querySnapshot, document.exists {
                let teacherStatus = document.data()!["TeacherMemberID"] as! Bool
                if teacherStatus {self.addProfileButton.isEnabled = true}
                else {self.addProfileButton.isEnabled = false}
            } else { self.addProfileButton.isEnabled = false}
        }
    }
    
    //TODO: Common function for sending alert to screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: connect to Firebase, retrieve Profile data and store in Realm
    func retrieveProfile() {
        
        db.collection(Constants.FStore.profileCollection).getDocuments() { (querySnapshot, error) in
            
            if error != nil {
                self.notifyUser("No Profile Exists", err: error as? String) //"If you are admin, add new Profile by pressing the + button above"
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let newProfile = ProfileRealmData()
                        if let profileName = data[Constants.FStore.profileName] as? String, let profileProduct = data[Constants.FStore.productID] as? String, let additionalInfo = data[Constants.FStore.additionalInfo] as? String, let webLink = data[Constants.FStore.webLink] as? String {
                            
                            newProfile.profileName = profileName
                            newProfile.productID = profileProduct
                            newProfile.additionalInfo = additionalInfo
                            newProfile.webLink = webLink
                            self.saveProfileInRealm(profile: newProfile)
                            self.retrieveRealmProfile()
                        }
                    }
                }
            }
        }
    }
    
    //TODO: Function to write to Realm
    func saveProfileInRealm(profile: ProfileRealmData) {
        do {
            try realm.write {
                realm.add(profile)
            }
        } catch {notifyUser("Add Error", err: "Error Saving Module Locally. Please try again.")}
    }
    
    //TODO: Function to retrieve data from Realm - called from retrieve free/ paid modules
    func retrieveRealmProfile() {
        
        profileList = realm.objects(ProfileRealmData.self)
        DispatchQueue.main.async {self.profileTableView.reloadData()}
    }

    //TODO: Function to clean up Realm database
    func cleanupRealm() {
        
        profileList = realm.objects(ProfileRealmData.self) //****Realm
        if profileList?.count != 0 {
            do {
                try realm.write {
                    realm.delete(profileList!)
                }
            } catch {notifyUser("CleanUp Error", err: "Error finishing local cleanup: \(error)")}
        }
    }
    
    // MARK: - Table view data source
    //TODO: Number of sections in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //TODO: Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return profileList?.count ?? 0
    }
    
    //TODO: Show Profiles
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.profileCell, for: indexPath)
        
        cellLabelText = (profileList?[indexPath.row].profileName) ?? "No Profiles"
        cellAdditionalInfo = (profileList?[indexPath.row].additionalInfo) ?? "No Additional Info"
        
        cell.textLabel?.numberOfLines = 0
        
        let assocProductID = (profileList?[indexPath.row].productID) ?? "No Product ID"
        if isPurchased(profileProductID : assocProductID) {
            cell.textLabel?.text = cellLabelText + ". " + cellAdditionalInfo
            if let cellColor = UIColor.flatBlueDark().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(profileList?.count ?? 1)) {
                cell.backgroundColor = cellColor
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
            }
        } else {
            cell.textLabel?.text = cellLabelText + ". " + cellAdditionalInfo + ". Reveal Extracurricular, GPA, Essays and Stats- $4.99"
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.textLabel?.textColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Upon selection the cell flashes grey and goes back to white
        tableView.deselectRow(at: indexPath, animated: true)
        
        //To pass data to ProfileDocViewController when a row is selected or capture data before purchase
        profile = profileList?[indexPath.row].profileName ?? "No Profiles"
        productID = profileList?[indexPath.row].productID ?? "No ProductID"
        info = profileList?[indexPath.row].additionalInfo ?? "No Additional Info"
        webpageURL = profileList?[indexPath.row].webLink ?? Constants.voicedAcademy
        pdfDocument = URL(fileURLWithPath: webpageURL).lastPathComponent
        
        if isPurchased(profileProductID :productID) {performSegue(withIdentifier: Constants.toProfileSegue, sender: self)}
        else {
            buyProfile(rowProfile : productID)
            
            DispatchQueue.main.async {
                SKPaymentQueue.default().restoreCompletedTransactions()
                self.profileTableView.reloadData()
            }
        }
    }
    
    //TODO: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toProfileSegue {
            let profileDocVC = segue.destination as! ProfileDocViewController
            profileDocVC.fileName = pdfDocument
            profileDocVC.fileLocation = webpageURL
        }
    }
    
    //MARK: - Buttons
    //TODO: Add new profile to Firestore and to the screen
    @IBAction func addProfilePressed(_ sender: UIBarButtonItem) {
        
        var textField1 = UITextField()
        var textField2 = UITextField()
        var textField3 = UITextField()
        
        textField1.text = ""
        textField2.text = ""
        textField3.text = ""
        
        let alert = UIAlertController(title: "Add New Profile", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Profile", style: .default) { (action) in
            
            let trimmedString = textField1.text?.trimmingCharacters(in: .whitespaces)
            let trimmedProductID = "com.voiced.CollegeConsulting." + (trimmedString?.removingWhitespaces() ?? "Profiles")
            let trimmedInfo = textField2.text?.trimmingCharacters(in: .whitespaces)
            let trimmedURL = textField3.text?.trimmingCharacters(in: .whitespaces)
            if trimmedString != "", trimmedProductID != "com.voiced.CollegeConsulting.Profiles", trimmedInfo != "", trimmedURL != "" {
                let profileName = trimmedString!
                let profileProduct = trimmedProductID
                let additionalInfo = trimmedInfo!
                let webLink = trimmedURL!
                self.db.collection(Constants.FStore.profileCollection).document(profileName).setData([
                    Constants.FStore.profileName: profileName,
                    Constants.FStore.productID: profileProduct,
                    Constants.FStore.additionalInfo: additionalInfo,
                    Constants.FStore.webLink: webLink,
                    Constants.FStore.dateCreated: Date().timeIntervalSince1970
                    ]) { (error) in
                        
                        if let e = error {self.notifyUser("Error saving data to Database", err: e as? String)}
                        else {
                            ProgressHUD.showSuccess("Profile Added Successfully!")
                            DispatchQueue.main.async {
                                textField1.text = ""
                                textField2.text = ""
                                textField3.text = ""
                            }
                        }
                    }
            } else {self.notifyUser("Error Adding Profile", err: "Profile name cannot be blank or only whitespaces")}
            self.cleanupRealm()
            self.retrieveProfile()
        }
        alert.addTextField{ (alertTextField1) in
            alertTextField1.placeholder = "Create New Profile"
            textField1 = alertTextField1
        }
        alert.addTextField{ (alertTextField2) in
            alertTextField2.placeholder = "Additional Info like GPA"
            textField2 = alertTextField2
        }
        alert.addTextField{ (alertTextField3) in
            alertTextField3.placeholder = "URL for Profile Document"
            textField3 = alertTextField3
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func restoreButtonPressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
