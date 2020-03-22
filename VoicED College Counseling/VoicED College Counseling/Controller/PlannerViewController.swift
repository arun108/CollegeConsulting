//
//  PlannerTableViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import RealmSwift
import ProgressHUD
import ChameleonFramework

class PlannerTableViewController: SwipeTableViewController {

    let defaults = UserDefaults.standard
    let realm = try! Realm()
    var categoryList: Results<Planner>?
    
    var notFirstTime: Bool = false
    
    @IBOutlet var plannerTableView: UITableView!
    
    @IBOutlet weak var addCategoryButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.flatLimeDark()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        retrievePlannerCategory()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
    }
    
    //TODO: Initial population of planner categories in Realm
    func firstTimePopulation() {
        let categoryArray = Constants.categoryArray
        for i in 0..<categoryArray.count {
            try! realm.write {
                        let initialCategoryList = Planner()
                        initialCategoryList.plannerName = categoryArray[i]
                        initialCategoryList.dateCreated = Date()
                        realm.add(initialCategoryList)
                    }
        }
        self.defaults.set(true, forKey: Constants.notFirstTime)
    }
    
    
    // MARK: - Table view data source
    //TODO: numberOfSections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //TODO: numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryList?.count ?? 1
    }
    
    //TODO: cell properties
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryList?[indexPath.row].plannerName ?? "Press + above to add category" //*****Realm
        
        if let cellColor = UIColor.yellow.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(categoryList!.count)) {
        cell.backgroundColor = cellColor
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        }
        return cell
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set(false, forKey: "BackFromAddTask")
        performSegue(withIdentifier: Constants.plannerToTaskSegue, sender: self)
    }
    
    //TODO: Prepare segues - one to go to TaskTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let taskVC = segue.destination as! TaskTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            taskVC.selectedCategory = categoryList?[indexPath.row]
        }
    }
    
    //TODO: Retrieve planner categories from array if using for the first time
    func retrievePlannerCategory() {
        
        if defaults.bool(forKey: Constants.notFirstTime) {} else {firstTimePopulation()}
        categoryList = realm.objects(Planner.self)
        tableView.reloadData()
    }
    
    //TODO: Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoriesForDeletion = self.categoryList?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoriesForDeletion)
                }
            } catch { notifyUser("Delete Error", err: "Error Deleting Category. Please try again.") }
        }
    }
    
    //TODO: Function to clean up Realm database
    func cleanupRealm() {
        
        categoryList = realm.objects(Planner.self) //****Realm
        if categoryList?.count != 0 {
            do {
                try realm.write {
                    realm.delete(categoryList!)
                }
            } catch {notifyUser("CleanUp Error", err: "Error clearing categoryList from Realm: \(error)")}
        }
    }
    
    //TODO: Function that actually writes Planner categories to Realm
    func savePlannerCategory(category: Planner) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {notifyUser("Add Error", err: "Error Saving Category. Please try again.")}
        tableView.reloadData()
    }
    
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Buttons
    //TODO: Add new category button
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO: Add user entered categories to Ream Database - Planner table
        var textField = UITextField()
        textField.text = ""
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespaces)
            if  trimmedString != "" {
                let newCategory = Planner()
                newCategory.plannerName = trimmedString!
                newCategory.dateCreated = Date()
                self.savePlannerCategory(category: newCategory)
            }
                self.tableView.reloadData()
            }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Searchbar Method
extension PlannerTableViewController: UISearchBarDelegate {
    
    //TODO: Display categories based on search text
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // input code for fetching data from Realm database based on search condition
        categoryList = categoryList?.filter("plannerName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: Constants.FStore.dateCreated, ascending: true)
        tableView.reloadData()
    }
    
    //TODO: Function to display categories when search text is cleared
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            retrievePlannerCategory()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
