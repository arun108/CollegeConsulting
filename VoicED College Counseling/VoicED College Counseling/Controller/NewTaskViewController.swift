//
//  NewTaskViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 3/10/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift

class NewTaskViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var taskList: Results<Tasks>?
    var selectedCategory: Planner?
    
    var retrievedCategory : String = ""
    
    weak var parentViewcontroller: TaskTableViewController?
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var newTask: UITextField!
    @IBOutlet weak var dueDate: UITextField!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var addTask: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        newTask.delegate = self
        dueDate.delegate = self
        
        category.text = retrievedCategory
        
        addTask.layer.cornerRadius = addTask.frame.size.height / 5
        addTask.backgroundColor = UIColor.flatLimeDark()
        
        newTaskView.layer.cornerRadius = newTaskView.frame.size.height / 10
        newTaskView.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        self.showAnimate()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    //TODO: Function to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if newTask.isFirstResponder { dueDate.becomeFirstResponder() }
        else if dueDate.isFirstResponder { addNewTask() }
        return true
    }
    
    //TODO: Add new task to todo list. Function shakes the screen is invalid entries are made
    func addNewTask() {
        if newTask.text != "" && dueDate.text != "" {
            let nameOfTask = newTask.text!.trimmingCharacters(in: .whitespaces)
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MM-dd-yyyy"
            let trimmedDueDate = String(dueDate.text!.prefix(10))
            if let trimmedDate = dateFormatterGet.date(from: trimmedDueDate) {
                //Shake the screen if fields are blank or if date entered is a past date or invalid
                if trimmedDate > Date() {
                    parentViewcontroller?.task = nameOfTask
                    parentViewcontroller?.taskDate = trimmedDate
                    defaults.set(true, forKey: Constants.backFromAddTask)
                    if self.appDelegate.eventStore == nil {
                        self.appDelegate.eventStore = EKEventStore()
                        self.appDelegate.eventStore?.requestAccess(
                        to: EKEntityType.reminder, completion: {(granted, error) in
                            if !granted { self.notifyUser("Reminder", err: "Reminder will not be set") }
                            else { }
                        })
                    }
                    if (self.appDelegate.eventStore != nil) {
                        self.createReminder(taskName: "Reminder: " + nameOfTask, dueDate: trimmedDate)
                    }
                    newTaskView.layoutIfNeeded() //avoid Snapshotting error
                    removeAnimate()
                } else {
                    dueDate.text = ""
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.07
                    animation.repeatCount = 4
                    animation.autoreverses = true
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: newTaskView.center.x - 10, y: newTaskView.center.y))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: newTaskView.center.x + 10, y: newTaskView.center.y))
                    newTaskView.layer.add(animation, forKey: "position")
                }
            } else {
                dueDate.text = ""
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: newTaskView.center.x - 10, y: newTaskView.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: newTaskView.center.x + 10, y: newTaskView.center.y))
                newTaskView.layer.add(animation, forKey: "position")
            }
        } else {
                    newTask.text = ""
                    dueDate.text = ""
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.07
                    animation.repeatCount = 4
                    animation.autoreverses = true
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: newTaskView.center.x - 10, y: newTaskView.center.y))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: newTaskView.center.x + 10, y: newTaskView.center.y))
                    newTaskView.layer.add(animation, forKey: "position")
            }
    }
    
    //TODO: Function to animate the display of information when user touches on the + button on Task screen
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    //TODO: Function to animate the disappearing of information when user touches on the Add To Todo List button
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (finished) in
            if finished {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTasks"), object: nil, userInfo: nil)
                }
            }
        }
    }

    //TODO: Create reminders for the due dates entered
    func createReminder(taskName: String, dueDate: Date) {

        let reminder = EKReminder(eventStore: appDelegate.eventStore!)
        reminder.title = taskName
        reminder.calendar = appDelegate.eventStore!.defaultCalendarForNewReminders()
        let date = dueDate
        let alarm = EKAlarm(absoluteDate: date)
        
        reminder.addAlarm(alarm)
        
        do {
            try appDelegate.eventStore?.save(reminder, commit: true)
        } catch let error { notifyUser("Reminder failed with error", err: "\(error.localizedDescription)") }
    }

    //TODO: Common function to send alerts to user screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Buttons
    //TODO: Add new task button
    @IBAction func addTaskButtonPressed(_ sender: UIButton) {
        addNewTask()
    }
}
