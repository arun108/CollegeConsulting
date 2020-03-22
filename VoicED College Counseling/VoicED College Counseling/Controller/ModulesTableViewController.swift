//
//  ModulesTableViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import SwipeCellKit
import StoreKit
import RealmSwift
import ChameleonFramework

class ModulesTableViewController: SwipeTableViewController, SKPaymentTransactionObserver {
    
    var moduleArray: [String] = [String]()
    var module: String = "No Modules Added"
    var passedEmailAddress : String = ""
    var productID : String = ""
    var paidModuleArray: [String] = [String]()
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    var moduleList: Results<ModuleRealmData>?
    
    @IBOutlet var moduleTableView: UITableView!
    @IBOutlet weak var moduleSearchBar: UISearchBar!
    @IBOutlet weak var addModule: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        
        productID = Constants.grammarID
        
        //Code for displaying data based on user status - user, paid user, teacher
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        hideFeatures(emailAddress: Auth.auth().currentUser?.email ?? email)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        
        SKPaymentQueue.default().add(self)
            
        if isPurchased() {showPaidQuiz()}
    }
    
    //TODO: Prepare segues - one to go to ChapterTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.moduleToChapterSegue {
            let chapterVC = segue.destination as! ChaptersTableViewController
            chapterVC.retrievedModuleForChapter = module
        }
    }
    
    //TODO: Function that performs the purchase transaction
    func buyQuiz() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
    }
        
    //TODO: Handle purchase, fail and restore
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                showPaidQuiz()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    notifyUser("Transaction Error", err: "Transaction failed due to: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                self.moduleTableView.reloadData()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    //TODO: Function to retrieve the paid modules. Set user default as true for the product ID if purchase was made
    func showPaidQuiz() {
        defaults.set(true, forKey: productID)
        retrievePaidModule()
    }
    
    //TODO: Check if purchase was done.
    func isPurchased() -> Bool {
        let purchaseStatus = defaults.bool(forKey: productID)
        if purchaseStatus {return true} else {return false}
    }
    
    //TODO: Display free and paid modules (based on use status - teacher/ user)
    func hideFeatures(emailAddress: String) {
        cleanupRealm()
        retrieveFreeModule()
        
        let checkEmailAddress = emailAddress
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        docRef.getDocument { (querySnapshot, error) in
        
            if let document = querySnapshot, document.exists {
                let teacherStatus = document.data()!["TeacherMemberID"] as! Bool
                if teacherStatus {
                    self.addModule.isEnabled = true
                    self.retrievePaidModule()
                    self.defaults.set(false, forKey: self.productID)
                } else {self.addModule.isEnabled = false}
            } else {self.addModule.isEnabled = false}
        }
    }
    
    //TODO: connect to Firebase, retrieve free module data and store in Realm
    func retrieveFreeModule() {
        
        db.collection(Constants.FStore.modulesCollection).order(by: Constants.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
           if let e = error {self.notifyUser("Error retrieving data from firestore", err: e as? String)}
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let moduleName = data[Constants.FStore.moduleName] as? String {
                            let newModule = ModuleRealmData()
                            newModule.moduleName = moduleName
                            self.saveModuleInRealm(module: newModule)
                            self.retrieveRealmModule()
                        }
                    }
                }
            }
        }
    }
    
    //TODO: connect to Firebase, retrieve paid module data and store in Realm
    func retrievePaidModule() {
        
        db.collection(Constants.FStore.paidModulesCollection).order(by: Constants.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
           
            if let e = error {self.notifyUser("Error retrieving data from firestore", err: e as? String)}
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let newModule = ModuleRealmData()
                        if let moduleName = data[Constants.FStore.moduleName] as? String {
                            newModule.moduleName = moduleName
                            self.saveModuleInRealm(module: newModule)
                            self.retrieveRealmModule()
                        }
                    }
                }
            }
        }
    }
    
    //TODO: Function to write to Realm
    func saveModuleInRealm(module: ModuleRealmData) {
        
        do {
            try realm.write {
                realm.add(module)
            }
        } catch {notifyUser("Add Error", err: "Error Saving Module Locally. Please try again.")}
    }
    
    //TODO: Function to retrieve data from Realm - called from retrieve free/ paid modules
    func retrieveRealmModule() {
        
        moduleList = realm.objects(ModuleRealmData.self)
        DispatchQueue.main.async {self.moduleTableView.reloadData()}
    }
    
    //TODO: Function to clean up Realm database
    func cleanupRealm() {
        
        moduleList = realm.objects(ModuleRealmData.self) //****Realm
        if moduleList?.count != 0 {
            do {
                try realm.write {
                    realm.delete(moduleList!)
                }
            } catch {notifyUser("CleanUp Error", err: "Error finishing local cleanup: \(error)")}
        }
    }
    
    //TODO: Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        let modulesForDeletion = self.moduleList![indexPath.row].moduleName
        
            db.collection(Constants.FStore.chapterCollection).order(by: Constants.FStore.dateField).whereField("moduleForChapter", isEqualTo: modulesForDeletion).addSnapshotListener { (querySnapshot, error) in
                if let e = error {self.notifyUser("Cannot Delete Module", err: e as? String)} else {
                    let snapshotDocuments = querySnapshot?.documents
                    let chapterCount = snapshotDocuments?.count ?? 0
                    if chapterCount > 0 {
                        self.notifyUser("Cannot Delete Module", err: "Delete the related chapters first before deleting the module")
                    } else {
                        self.db.collection(Constants.FStore.modulesCollection).document(modulesForDeletion).delete() { err in
                            if let err = err {self.notifyUser("Cannot Delete Module", err: err as? String)}
                            else {ProgressHUD.showSuccess("Module Deleted Successfully!")}
                        }
                    }
                }
            }
    }
    
    //TODO: Common function for sending alert to screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
     
    // MARK: - Table view data source
    //TODO: Number of sections in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //TODO: Number of rows in section. If user alredy purchased quiz package then don't show purchase option
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPurchased() {return moduleList?.count ?? 0}
        else {return (moduleList?.count ?? 0) + 1}   //moduleArray.count + 1
    }
    
    //TODO: if paid user don't show "Get more quiz" else show
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.moduleCell, for: indexPath)
        
        if indexPath.row < moduleList?.count ?? 1 {
            cell.textLabel?.text = moduleList?[indexPath.row].moduleName
            cell.textLabel?.numberOfLines = 0
            
            if let cellColor = UIColor.flatGreenDark().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(moduleList?.count ?? 1)) {
            cell.backgroundColor = cellColor
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
            }
            cell.accessoryType = .none
        } else {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "Grammar & Tests Lifetime Supply- $1.99"
            cell.textLabel?.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Upon selection the cell flashes grey and goes back to white
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == moduleList?.count ?? 1 {
            buyQuiz()
        } else {
            module = moduleList?[indexPath.row].moduleName ?? "No Modules"    //To pass data to chapterTableViewController when a row is selected
            performSegue(withIdentifier: Constants.moduleToChapterSegue, sender: self)
        }
    }
       
    // MARK: - Buttons
    //TODO: Add Module button
    @IBAction func addModuleButtonPressed(_ sender: UIBarButtonItem) {
            
            var textField = UITextField()
            textField.text = ""
            
            let alert = UIAlertController(title: "Add New Module", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Add Module", style: .default) { (action) in
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            if  trimmedString != "" {
                    let moduleName = trimmedString
                    self.db.collection(Constants.FStore.paidModulesCollection).document(moduleName!).setData([
                        Constants.FStore.moduleName: moduleName ?? "Do not use",
                        Constants.FStore.dateCreated: Date().timeIntervalSince1970
                    ]) { (error) in
                        if let e = error {self.notifyUser("Error saving data to Firestore", err: e as? String)}
                        else {
                            ProgressHUD.showSuccess("Module Added Successfully!")
                            textField.text = ""
                        }
                    }
                } else {self.notifyUser("Error Adding Module", err: "Module name cannot be blank or only whitespaces")}
                let email = self.defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
                self.hideFeatures(emailAddress: Auth.auth().currentUser?.email ?? email)
            }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Module"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //TODO: Restore purchase button
    @IBAction func restoreButtonPressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

//MARK: - Searchbar Method following instructions in Github
extension ModulesTableViewController: UISearchBarDelegate {
    
    // TODO: code for fetching data from Realm database based on search condition
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchName = searchBar.text {
            self.moduleList = self.moduleList?.filter("moduleName CONTAINS[cd] %@", searchName).sorted(byKeyPath: Constants.FStore.dateCreated, ascending: true)
            DispatchQueue.main.async {self.moduleTableView.reloadData()}
        }
        searchBar.resignFirstResponder()
    }
    
    // TODO: code for canceling search based on user status - user, paid user, teacher
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
            hideFeatures(emailAddress: Auth.auth().currentUser?.email ?? email)
            if isPurchased() {showPaidQuiz()}
            searchBar.resignFirstResponder()
        }
    }
}
