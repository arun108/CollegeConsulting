//
//  ChaptersTableViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import SwipeCellKit
import RealmSwift
import ChameleonFramework

class ChaptersTableViewController: SwipeTableViewController {
    
    var chapterArray: [Chapters] = [Chapters]()
    var chapter: String = "No Chapters Added"
    var retrievedModuleForChapter: String = ""
    var timer = Timer()
    var score: String = ""
    var chapterFromQuestions : String = ""
    var cellLabelText : String = ""
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    var chapterList: Results<ChapterRealmData>?

    @IBOutlet weak var addChapterButton: UIBarButtonItem!
    @IBOutlet weak var chapterSearchBar: UISearchBar!
    @IBOutlet var chapterTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        addChapterButton.isEnabled = true
        
        tableView.rowHeight = 80.0
        
        cleanupRealm()
        retrieveChapter()
        
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        hideFeatures(emailAddress: Auth.auth().currentUser?.email ?? email)
        chapterTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        timer.invalidate()
        chapterTableView.reloadData()
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
        return chapterList?.count ?? 0
    }
    
    //TODO: Show chapters and score for the chapter quiz that was just taken
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.chapterCell, for: indexPath)
        
        if !score.isEmpty {cellLabelText = chapterFromQuestions == chapterList![indexPath.row].chapterName ? "\(chapterList![indexPath.row].chapterName) - \(score)" : chapterList![indexPath.row].chapterName}
        else {cellLabelText = (chapterList?[indexPath.row].chapterName)!}
        
        cell.textLabel?.text = cellLabelText
        cell.textLabel?.numberOfLines = 0
        
        if let cellColor = UIColor.flatGreenDark().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(chapterList?.count ?? 1)) {
        cell.backgroundColor = cellColor
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Upon selection the cell flashes grey and goes back to white
        tableView.deselectRow(at: indexPath, animated: true)
        
        //To pass data to questionTableViewController when a row is select
        chapter = chapterList?[indexPath.row].chapterName ?? "No Chapters"
        
        performSegue(withIdentifier: Constants.chapterToQuestionsSegue, sender: self)
    }
    
    //TODO: Prepare segues - one to go to questionTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.chapterToQuestionsSegue {
            let questionsVC = segue.destination as! QuestionViewController
            questionsVC.parentViewcontroller = self
            questionsVC.retrievedChapter = chapter
            questionsVC.retrievedModuleForChapter = retrievedModuleForChapter
        }
    }
    
    //TODO: Display or hide add chapter button
    func hideFeatures(emailAddress: String) {
        
        let checkEmailAddress = emailAddress
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        
        docRef.getDocument { (querySnapshot, error) in
            if let document = querySnapshot, document.exists {
                let teacherStatus = document.data()!["TeacherMemberID"] as! Bool
                if teacherStatus {self.addChapterButton.isEnabled = true}
                else {self.addChapterButton.isEnabled = false}
            } else {self.addChapterButton.isEnabled = false}
        }
    }
    
    //TODO: Common function for sending alert to screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: connect to Firebase, retrieve chapter data and store in Realm
    func retrieveChapter() {
        
        db.collection(Constants.FStore.chapterCollection).whereField("moduleForChapter", isEqualTo: retrievedModuleForChapter).getDocuments() { (querySnapshot, error) in
            
            if error != nil {
                self.notifyUser("No Chapter Exists", err: error as? String) //"If you are admin, add new chapter by pressing the + button above"
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let newChapter = ChapterRealmData()
                        if let chapterName = data[Constants.FStore.chapterName] as? String,
                            let moduleName = data[Constants.FStore.moduleForChapter] as? String {
                            newChapter.moduleForChapter = moduleName
                            newChapter.chapterName = chapterName
                            self.saveChapterInRealm(chapter: newChapter)
                            self.retrieveRealmChapter()
                        }
                    }
                }
            }
        }
    }
    
    //TODO: Function to write to Realm
    func saveChapterInRealm(chapter: ChapterRealmData) {
        
        do {
            try realm.write {
                realm.add(chapter)
            }
        } catch {notifyUser("Add Error", err: "Error Saving Module Locally. Please try again.")}
    }
    
    //TODO: Function to retrieve data from Realm - called from retrieve free/ paid modules
    func retrieveRealmChapter() {
        
        chapterList = realm.objects(ChapterRealmData.self)
        DispatchQueue.main.async {self.chapterTableView.reloadData()}
    }


    //TODO: Function to clean up Realm database
    func cleanupRealm() {
        
        chapterList = realm.objects(ChapterRealmData.self) //****Realm
        if chapterList?.count != 0 {
            do {
                try realm.write {
                    realm.delete(chapterList!)
                }
            } catch {notifyUser("CleanUp Error", err: "Error finishing local cleanup: \(error)")}
        }
    }
    
    //TODO: Delete data from Swipe - called from SwipeTableViewController
    override func updateModel(at indexPath: IndexPath) {
        
        let chapterForDeletion = self.chapterList![indexPath.row].chapterName
        
            db.collection(Constants.FStore.questionCollection).whereField("Chapter", isEqualTo: chapterForDeletion).addSnapshotListener { (querySnapshot, error) in
                if let e = error {self.notifyUser("Cannot Delete Chapter", err: e as? String)}
                else {
                    let snapshotDocuments = querySnapshot?.documents
                    let questionCount = snapshotDocuments?.count ?? 0
                    if questionCount > 0 {
                        self.db.collection(Constants.FStore.questionCollection).document(Constants.FStore.chapterForQuestions).delete() { err in
                        if let err = err {self.notifyUser("Cannot Delete Chapter", err: err as? String)}
                        else {ProgressHUD.showSuccess("Questions Deleted Successfully!")}
                        }
                         self.db.collection(Constants.FStore.chapterCollection).document(self.chapterList![indexPath.row].chapterName).delete() { err in
                        if let err = err {self.notifyUser("Cannot Delete Chapter", err: err as? String)}
                        else {ProgressHUD.showSuccess("Chapter Deleted Successfully!")}
                        }
                    } else {
                        self.db.collection(Constants.FStore.chapterCollection).document(self.chapterList![indexPath.row].chapterName).delete() { err in
                            if let err = err {self.notifyUser("Cannot Delete Chapter", err: err as? String)}
                            else {ProgressHUD.showSuccess("Chapter Deleted Successfully!")}
                        }
                    }
                }
            }
    }
    
    
    @IBAction func addChapterPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        textField.text = ""
        
        let alert = UIAlertController(title: "Add New Chapter", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Chapter", style: .default) { (action) in
            
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            if trimmedString != "" {
                let chapterName = trimmedString!
                self.db.collection(Constants.FStore.chapterCollection).document(chapterName).setData([
                    Constants.FStore.moduleForChapter: self.retrievedModuleForChapter,
                    Constants.FStore.chapterName: chapterName,
                    Constants.FStore.dateCreated: Date().timeIntervalSince1970
                    ]) { (error) in
                        
                        if let e = error {self.notifyUser("Error saving data to Firestore", err: e as? String)}
                        else {
                            ProgressHUD.showSuccess("Chapter Added Successfully!")
                            DispatchQueue.main.async {
                                textField.text = ""
                            }
                        }
                    }
            } else {self.notifyUser("Error Adding Chapter", err: "Chapter name cannot be blank or only whitespaces")}
            self.retrieveChapter()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Chapter"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Searchbar Method following instructions in Github
extension ChaptersTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // input code for fetching data from Realm database based on search condition
        if let searchName = searchBar.text {
            self.chapterList = self.chapterList?.filter("chapterName CONTAINS[cd] %@", searchName).sorted(byKeyPath: Constants.FStore.dateCreated, ascending: true)
            self.tableView.reloadData()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            cleanupRealm()
            retrieveChapter()
            searchBar.resignFirstResponder()
        }
    }
}
