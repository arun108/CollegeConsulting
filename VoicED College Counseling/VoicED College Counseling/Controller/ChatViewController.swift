//
//  ChatViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 9/19/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    var sectionArray : [[Message]] = [[Message]]()
    var cellArray : [Message] = [Message]()
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var backgroundButton: UIBarButtonItem!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var fullName: String = ""
    var messageComing: Bool = false
    var chatEmailAddress : String = ""
    var dateOfMessage : String = ""
    var preferredLanguage : String = NSLocale.current.identifier
    var messageDated : String = ""
    var imageName : String = ""
    var retrievedAvatarName : String = ""
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.purple
        messageTableView.dataSource = self
        messageTableView.delegate = self
        messageTableView.register(CustomMessageCell.self, forCellReuseIdentifier: Constants.chatCellIdentifier)
        
        imageName = defaults.string(forKey: "ChatBackgroundImage") ?? "chatBackground2"
        
        messageTextField.delegate = self as? UITextViewDelegate
        
        getFullName(emailAddress: chatEmailAddress)
        initialRetrieve()
        
        messageTableView.separatorStyle = .none
        messageTableView.backgroundColor = UIColor.clear
        sendButton.layer.cornerRadius = sendButton.frame.size.height / 5
        messageTextField.layer.cornerRadius = messageTextField.frame.size.height / 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: imageName)?.draw(in: self.view.bounds, blendMode: .normal, alpha: 0.7)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
    }
    
    //TODO: Get full name based on email address
    func getFullName(emailAddress: String) {
        
        let checkEmailAddress = emailAddress
        
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        
        docRef.getDocument { (querySnapshot, error) in
        
            if let document = querySnapshot, document.exists {
                let retrievedFirstName = document.data()!["UserFirstName"] as? String
                let retrievedLastName = document.data()!["UserLastName"] as? String
                self.retrievedAvatarName = document.data()!["AvatarName"] as? String ?? "imageProfile"
                self.defaults.set(self.retrievedAvatarName, forKey: Constants.avatarImage)
                if let firstName = retrievedFirstName, let lastName = retrievedLastName {
                    self.fullName = "\(firstName) \(lastName)"
                    self.defaults.set(self.fullName, forKey: Constants.fullName)
                }
            } else {
                self.fullName = "VoicED User"
                self.retrievedAvatarName = "imageProfile"
                self.defaults.set(self.fullName, forKey: Constants.fullName)
                self.defaults.set(self.retrievedAvatarName, forKey: Constants.avatarImage)
            }
        }
    }
    
    //TODO: Function to send message to Firestore, screen and remote notification when sendButton is pressed
    func sendMessage() {
        
        let messageBody = messageTextField?.text.trimmingCharacters(in: .whitespaces)
        if messageBody != ""  {
            retrievedAvatarName = defaults.string(forKey: Constants.avatarImage) ?? "imageProfile"
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZ"
            df.timeZone = TimeZone(secondsFromGMT: 0)
            let createdDate = df.string(from: Date())
            
            db.collection(Constants.FStore.collectionName).addDocument(data: [
                Constants.FStore.senderField: chatEmailAddress,
                Constants.FStore.senderName: self.fullName,
                Constants.FStore.bodyField: messageBody!,
                Constants.FStore.avatarName: self.retrievedAvatarName,
                Constants.FStore.dateField: createdDate
            ]) { (error) in
                if let e = error {self.notifyUser("Error Saving Data", err: "\(e)")}
                else {
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                        let sender = PushNotificationSender()
                        self.db.collection(Constants.FStore.notificationCollection).getDocuments() { (querySnapshot, error) in
                            if let e = error {self.notifyUser("Notification Error", err: "Error notifying message to other users. Contact admin for support, \(e)")}
                            else {
                               let userName = self.defaults.string(forKey: Constants.fullName)
                               //Send notification to all tokens in users_table collection in Firestore
                               if let snapshotDocuments = querySnapshot?.documents {
                                    for doc in snapshotDocuments {
                                        let data = doc.data()
                                        if let fcmTokenNumber = data[Constants.FStore.fcmToken] as? String {
                                            var countOfNotification = self.defaults.integer(forKey: "NotificationCount")
                                            countOfNotification += 1
                                            sender.sendPushNotification(to: fcmTokenNumber, count: countOfNotification, title: userName ?? "VoicED Group Chat", body: "New message from \(userName ?? "VoicED User")")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //TODO: keyboard control
    func textFieldDidEndEditing(_ textField: UITextField) {
        if messageTextField.isFirstResponder {messageTextField.resignFirstResponder()}
    }
    
    //TODO: Retrieve message at the begining and after sending message
    func initialRetrieve() {
        var previousDate : String = ""
        var localArray : [Message] = [Message]()

       db.collection(Constants.FStore.collectionName).order(by: Constants.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            
        //Empty array to accommodate for data fetched by addSnapshotListener and avoid duplicates
        self.sectionArray = [[]]
        localArray = []
        
            if let e = error {self.notifyUser("Error Retrieving Data", err: "\(e)")}
            else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        
                        let data = doc.data()
                        
                        if let messageSender = data[Constants.FStore.senderField] as? String, let messageBody = data[Constants.FStore.bodyField] as? String, let senderName = data[Constants.FStore.senderName] as? String, let messageAvatar = data[Constants.FStore.avatarName] as? String, let messageDate = data[Constants.FStore.dateField] as? String {
                            
                            let md = DateFormatter()
                            md.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZ"
                            md.timeZone = TimeZone(secondsFromGMT: 0)
                            
                            let md1 = DateFormatter()
                            md1.locale = Locale(identifier: self.preferredLanguage)
                            md1.setLocalizedDateFormatFromTemplate("MMMMd")
                            
                            if let msgdt = md.date(from: messageDate) { self.messageDated = md1.string(from: msgdt)}
                            else { self.messageDated = md1.string(from: Date())}
                            
                            let newMessage = Message(receiver: messageSender, receiverName: senderName, receiverMessage: messageBody, avatarName: messageAvatar, dateCreated: self.messageDated)
                            if previousDate == newMessage.dateCreated {}
                            else {
                                if previousDate != "" {self.sectionArray.append(localArray)}
                                localArray = []
                                previousDate = newMessage.dateCreated
                            }
                            localArray.append(newMessage)
                        }
                    }
                    self.sectionArray.append(localArray)
                }
            }
            self.messageTableView.reloadData()
            if localArray.count > 0 && self.sectionArray.count > 0 {
                let indexPath = IndexPath(row: localArray.count - 1, section: self.sectionArray.count - 1)
                self.messageTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toChangBackgroundSegue {
            let backgroundVC = segue.destination as! BackgroundCollectionViewController
            backgroundVC.parentViewcontroller = self
        }
    }
    
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: Call sendMessage. To send message to Firestore and to the screen
    @IBAction func sendPressed(_ sender: UIButton) {
        sendMessage()
    }
    
    
    @IBAction func backgroundButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.toChangBackgroundSegue, sender: self)
    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - TableView delegate
    //TODO: Number of sections
     func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
     //TODO: data for header per section
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         var label = UILabel()
         
         let firstMessageInSection = sectionArray[section].first
         dateOfMessage = firstMessageInSection?.dateCreated ?? "Start of Conversation"
         label = DateHeaderLabel()
         label.text = dateOfMessage
         
         label.translatesAutoresizingMaskIntoConstraints = false
         
         let containerView = UIView()
         containerView.addSubview(label)
         
         label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
         label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
         
         return containerView
     }
     
    //TODO: Called from viewForHeaderSection to set header label properties
    class DateHeaderLabel: UILabel {

        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .black
            textColor = .white
            textAlignment = .center
            translatesAutoresizingMaskIntoConstraints = false
            font = UIFont.boldSystemFont(ofSize: 14)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        //TODO: Intrinsic header sizing
        override var intrinsicContentSize: CGSize {
            let originalContentSize = super.intrinsicContentSize
            let height = originalContentSize.height + 12
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalContentSize.width + 20, height: height)
        }
    }
    
    //TODO: Section header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //TODO: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray[section].count
    }
    
    //TODO: Display cell info
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: Constants.chatCellIdentifier, for: indexPath) as! CustomMessageCell
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let sectionMessages = sectionArray[indexPath.section][indexPath.row]
        cell.message.text = sectionMessages.receiverMessage
        cell.name.text = sectionMessages.receiverName
        cell.email.text = sectionMessages.receiver
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: sectionMessages.avatarName)?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        cell.avatar.image = image
        cell.avatar.layer.cornerRadius = cell.avatar.frame.size.height / 2
        cell.avatar.clipsToBounds = true
        
        cell.isIncoming = cell.email.text == chatEmailAddress ? false : true
        
        return cell
    }
}
