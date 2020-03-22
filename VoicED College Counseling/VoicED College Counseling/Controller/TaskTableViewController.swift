//
//  TaskTableViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import RealmSwift
import ProgressHUD
import EventKit
import ChameleonFramework

class TaskTableViewController: SwipeTableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var showAll : Bool = false
    var taskList: Results<Tasks>?
    var selectedCategory: Planner? {
        didSet{
            retrieveTasks()
        }
    }
    var task : String = ""
    var taskDate : Date?
    var categoryName : String = ""
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    @IBOutlet weak var showAllTasksButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.flatLimeDark()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        retrieveTasks()
        
        categoryName = selectedCategory!.plannerName
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTasks), name: NSNotification.Name(rawValue: "updateTasks"), object: nil)
        
    }
    
    @objc func updateTasks() {
        
        if defaults.bool(forKey: Constants.backFromAddTask) {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MM-dd-yyyy"
            let dateFormatCheck = dateFormatterGet.string(from: taskDate!)
            let dateGreaterThan = dateFormatterGet.date(from: dateFormatCheck)
            if let currentCategory = self.selectedCategory {
                let nameOfTask = task  + " - " + dateFormatCheck
                do {
                    try self.realm.write {
                        let createdTask = Tasks()
                        createdTask.taskName = nameOfTask
                        createdTask.dateCreated = dateGreaterThan
                        currentCategory.tasks.append(createdTask)
                    }
                } catch { self.notifyUser("Add Error", err: "Error Adding Data. Please try again.") }
            }
            retrieveTasks()
            defaults.set(false, forKey: Constants.backFromAddTask)
        }
    }
    
    //TODO: Function to format the word ALL to remove a strikethrough when user click on it and display tasks filtered by selected category
    func retrieveTasks() {
        taskList = selectedCategory?.tasks.sorted(byKeyPath: "taskName", ascending: true)
        tableView.reloadData()
        showAllTasksButton.title = "ALL"
        showAllTasksButton.setTitleTextAttributes([NSAttributedString.Key.strikethroughStyle : 0, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        showAll = true
    }
    
    //TODO: Function to format the word ALL to add the strikethrough when user click on it and display all Tasks irrespective of Category
    func retrieveAllTasks() {
        taskList = realm.objects(Tasks.self)
        tableView.reloadData()
        showAllTasksButton.title = "ALL"
        showAllTasksButton.setTitleTextAttributes([NSAttributedString.Key.strikethroughStyle : 1, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        showAll = false
    }
    
    //TODO: Prepare segues - one to go to TaskTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toAddTaskSegue {
            let newTaskVC = segue.destination as! NewTaskViewController
            newTaskVC.retrievedCategory = categoryName
            newTaskVC.parentViewcontroller = self
        }
    }
    
    //TODO: Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let taskForDeletion = taskList?[indexPath.row] {
            do {
                try self.realm.write {self.realm.delete(taskForDeletion)}
            } catch {notifyUser("Delete Error", err: "Error Deleting Data. Please try again.")}
        }
    }
    
    
    //TODO: Function to clean up Realm database
    func cleanupRealm() {
        taskList = self.realm.objects(Tasks.self) //****Realm
        if taskList?.count != 0 {
            do {
                try realm.write {
                    realm.delete(taskList!)
                }
            } catch {
                ProgressHUD.showError("Error clearing taskList in Realm database: \(error)")
            }
        }
    }
    
    //TODO: Common function to send alerts to user screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    //TODO: numberofSections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //TODO: numberofRowsinSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskList?.count ?? 1
    }
    
    //TODO: cell properties - check task (not) done
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let task = taskList?[indexPath.row] {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MM-dd-yyyy"
            let dateAsString = dateFormatterGet.string(from: task.dateCreated!)
            let todaysDate = dateFormatterGet.string(from: Date())
            let dateFormatCheck = dateFormatterGet.date(from: dateAsString)!
            let dateToday = dateFormatterGet.date(from: todaysDate)!
            
            cell.textLabel?.text = task.taskName
            cell.accessoryType = task.done ? .checkmark : .none
            
            if dateFormatCheck < dateToday {
                if let cellColor = UIColor.yellow.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(taskList!.count)) {
                    cell.backgroundColor = cellColor
                    cell.textLabel?.textColor = UIColor.red
                }
            } else {
                if let cellColor = UIColor.yellow.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(taskList!.count)) {
                    cell.backgroundColor = cellColor
                    cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
                }
            }
        } else { cell.textLabel?.text = "Press + above to add related tasks" }
        
       return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = taskList?[indexPath.row] {
            do {
                try realm.write {
                    task.done = !task.done
                }
            } catch { notifyUser("Update Error", err: "Error Updating Data as Done. Please try again.") }
        }
        tableView.reloadData()
        
        //TODO: on select the row flashes grey and goes back to white
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    //MARK: - Buttons
    //TODO: (Do not) Show all tasks based on ALL button pressed. Alternate strikethough of ALL word.
    @IBAction func showAllTasksButtonPressed(_ sender: UIBarButtonItem) {
        if showAll {retrieveAllTasks()} else {retrieveTasks()}
    }
    
    //TODO: Add task and save to Realm in the same function
    @IBAction func addTaskButtonPressed(_ sender: UIBarButtonItem) {
    }
}

//MARK: - Searchbar Methods
extension TaskTableViewController: UISearchBarDelegate {
    
    //TODO: Search for text in searchBar.text
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // input code for fetching data from Realm database based on search condition
        taskList = taskList?.filter("taskName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: Constants.FStore.dateCreated, ascending: true)
        tableView.reloadData()
    }
    
    //TODO: Display all tasks when search item is cleared
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            retrieveTasks()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - Strikthrough function to strikeout the text on ALL button
extension String {
    func strikeThrough() -> String {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString.string
    }
}
