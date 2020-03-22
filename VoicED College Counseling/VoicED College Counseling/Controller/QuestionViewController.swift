//
//  QuestionViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 10/15/18.
//  Copyright © 2018 Arun Narayanan. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
import RealmSwift
import MessageUI
import Security

class QuestionViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var pickedAnswer : Int = 0
    var selectedAnswer : [Int] = [Int]()
    var totalCount : Int = 0
    var questionNumber : Int = 0
    var score : Int = 0
    var secondsRemaining : Int = 0
    var timer = Timer()
    var retrievedChapter : String = "No retrieved chapter"
    var chapter : String = "No chapter"
    var retrievedModuleForChapter : String = ""
    var retrievedTeacherCodeFromChapter : String = ""
    var questionsExist : Bool = false
    var scoreCard : String = ""
    var points : String = "0/0"
    var user : String = ""
    var testCount : Int = 0
    var numberOfStars : Int = 0
    
    weak var parentViewcontroller: ChaptersTableViewController?
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    var quizList: Results<QuizForRealm>?
    
    var allQuestions : [Quiz] = [Quiz]()
    
    var csvString : String = ""
    let fileName = "ScoreCard.txt"
    
    @IBOutlet weak var chapterReference: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var progressTime: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addQuestions: UIBarButtonItem!
    
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    
    @IBOutlet weak var badgeInfo: UIButton!
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up navigationcontroller color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        
        //Set size of description and questionlabels
        setupConstraints()
        
        //Hide or display buttons based on user type
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        user = Auth.auth().currentUser?.email ?? email
        hideButtons(emailAddress: user)
        
        self.messageLabel.alpha = 0
        self.badgeInfo.alpha = 0
        numberOfStars = defaults.integer(forKey: "BadgeCount")
        
        chapterReference.text = retrievedChapter
        retrieveQuestions()
        
        retrievedModuleForChapter = String(retrievedModuleForChapter.prefix(8))
        
        badgeLabel()
        moveStar()
    }
    
    //TODO: assign badge label based on number of badges obtained
    func badgeLabel() {
        switch numberOfStars {
        case 1:
            messageLabel.text = "Free Learner"
        case 2:
            messageLabel.text = "Practitioner"
        case 3:
            messageLabel.text = "Intermediate"
        case 4:
            messageLabel.text = "Advanced"
        case 5:
            messageLabel.text = "Expert"
        default:
            messageLabel.text = "Free Learner"
        }
    }
    
    //TODO: Move the star from left to right of the screen to indicate student level
    func moveStar() {
        UIView.animate(withDuration: 0.125,
                       delay: TimeInterval(CGFloat(0.0)),
                       options: .curveLinear,
                       animations: {
                        var rouletteFrame = self.starView.frame
                        rouletteFrame.origin.x -= rouletteFrame.size.width
                        self.starView.frame = rouletteFrame
                        },
                       completion: { finished in
                        
                        UIView.animate(withDuration: 2,
                                       delay: TimeInterval(CGFloat(0.0)),
                           options: .curveLinear,
                           animations: {
                            var rouletteFrame = self.starView.frame
                            rouletteFrame.origin.x -= (self.view.frame.width - 60)
                            self.starView.frame = rouletteFrame
                            },
                           completion: { finished in
                            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                                self.messageLabel.alpha = 1
                                self.badgeInfo.alpha = 1
                                }) { (Bool) -> Void in
                            }
            })
        })
    }
    
    func getBadgeLevel() {
        
        var chapterCount : Int = 0
        var badgeCount : Int = 0
        var module1Count : Int = 0
        var module2Count : Int = 0
        var module3Count : Int = 0
        var previousChapter : String = ""
        var previousModule : String = ""
        
        let badgeRef = db.collection(Constants.FStore.badgeCollection)
        badgeRef
            .whereField("EmailAddress", isEqualTo: user)
            .whereField(Constants.FStore.moduleName, isEqualTo: retrievedModuleForChapter)
            .order(by: Constants.FStore.moduleName)
            .getDocuments() { (querySnapshot, error) in
                if let e = error {self.notifyUser("Database Access Error", err: "Error retrieving previous badge info, \(e)")}
                else {
                   if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let module = data[Constants.FStore.moduleName] as? String, let chapter = data[Constants.FStore.chapterName] as? String {
                                if module == "Assessme" {
                                    if previousModule == module {}
                                    else {chapterCount = 0}
                                    if previousChapter == chapter {}
                                    else { //increase chapter count only if chapter is different
                                        chapterCount += 1
                                        if chapterCount >= 3 {//A badge only if chapter count with 80% score is 3 or more. 80% score is decided during data population
                                            badgeCount += 1
                                            module1Count = 3
                                        }
                                        previousChapter = chapter
                                        previousModule = module
                                    }
                                } else if module == "Module 1" && module1Count == 3 {
                                    if previousModule == module {}
                                    else {chapterCount = 0}
                                    if previousChapter == chapter {}
                                    else { //increase chapter count only if chapter is different
                                        chapterCount += 1
                                        if chapterCount >= 3 {//A badge only if chapter count with 80% score is 3 or more. 80% score is decided during data population
                                            badgeCount += 1
                                            module2Count = 3
                                        }
                                        previousChapter = chapter
                                        previousModule = module
                                    }
                                } else if module == "Module 2" && module2Count == 3 {
                                    if previousModule == module {}
                                    else {chapterCount = 0}
                                    if previousChapter == chapter {}
                                    else { //increase chapter count only if chapter is different
                                        chapterCount += 1
                                        if chapterCount >= 3 {//A badge only if chapter count with 80% score is 3 or more. 80% score is decided during data population
                                            badgeCount += 1
                                            module3Count = 3
                                        }
                                        previousChapter = chapter
                                        previousModule = module
                                     }
                               } else if module == "Module 3" && module3Count == 3 {
                                    if previousModule == module {}
                                    else {chapterCount = 0}
                                    if previousChapter == chapter {}
                                    else { //increase chapter count only if chapter is different
                                        chapterCount += 1
                                        if chapterCount >= 3 {//A badge only if chapter count with 80% score is 3 or more. 80% score is decided during data population
                                            badgeCount += 1
                                        }
                                        previousChapter = chapter
                                        previousModule = module
                                    }
                               }
                            }
                        }
                    self.defaults.set(badgeCount, forKey: "BadgeCount")
                    }
                }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //handling reset timer if user exits from quiz half-way through
        timer.invalidate()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        parentViewcontroller?.score = points
        timer.invalidate()
    }
    
    //MARK: - Functions
    //TODO: Autolayout - set size of description and questionlabels
    func setupConstraints() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: chapterReference.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        descriptionLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40).isActive = true
        questionLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        questionLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        questionLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        questionLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
    }
    
    //TODO: connect to Firebase and retrieve question data based on chapter selected by user
    func retrieveQuestions() {
            
        db.collection(Constants.FStore.questionCollection).whereField("Chapter", isEqualTo: retrievedChapter).addSnapshotListener { (querySnapshot, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Could not fetch data", message: "Questions for this chapter could not be fetched. Press okay to add data", preferredStyle: .alert)
                    let restartAction = UIAlertAction(title: "Okay", style: .default, handler: { (UIAlertAction) in
                        self.performSegue(withIdentifier: Constants.questionToQBSegue, sender: self) })
                    alert.addAction(restartAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    if let snapshotDocuments = querySnapshot?.documents {
                        
                        //Empty array to accommodate for data fetched by addSnapshotListener and avoid duplicates
                        self.allQuestions = []
                        
                        //Using i variable to display initial data when user enters quiz screen.
                        var i = 0
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            
                            if let chapterName = data[Constants.FStore.chapterForQuestions] as? String {
                                let newQuestions = Quiz(chapterText: chapterName, descriptionText: data["Description"] as? String  ?? "No description", questionText: data["Question"] as? String ?? "No question", correctAnswer: data["CorrectAnswer"] as? Int ?? 0, button1Label: data["Option1"] as? String ?? " ", button2Label: data["Option2"] as? String ?? " ", button3Label: data["Option3"] as? String ?? " ", button4Label: data["Option4"] as? String ?? " ")
                                self.allQuestions.append(newQuestions)
                                
                                if i == 0 {
                                    self.questionLabel.text = self.allQuestions[0].question
                                    self.descriptionLabel.text = self.allQuestions[0].description
                                    self.Button1.setTitle(self.allQuestions[0].button1, for: .normal)
                                    self.Button2.setTitle(self.allQuestions[0].button2, for: .normal)
                                    self.Button3.setTitle(self.allQuestions[0].button3, for: .normal)
                                    self.Button4.setTitle(self.allQuestions[0].button4, for: .normal)
                                    
                                    self.Button1.isEnabled = self.allQuestions[0].button1.trimmingCharacters(in: .whitespaces) == "" ? false : true
                                    self.Button2.isEnabled = self.allQuestions[0].button2.trimmingCharacters(in: .whitespaces) == "" ? false : true
                                    self.Button3.isEnabled = self.allQuestions[0].button3.trimmingCharacters(in: .whitespaces) == "" ? false : true
                                    self.Button4.isEnabled = self.allQuestions[0].button4.trimmingCharacters(in: .whitespaces) == "" ? false : true
                                }
                                if self.allQuestions.count > 0 {self.questionsExist = true}
                           }
                            i += 1
                        }
                    }
                }
            self.totalCount = self.allQuestions.count
            self.updateUI()
            self.beginQuiz()
            }
        }
    
    //TODO: Begin quiz - ask users what they want to do. Call appropriate function per user's choice - Start, Later, Admin
    func beginQuiz() {
        
        if questionsExist {
            let alert = UIAlertController(title: "Ready?", message: "You have \(Constants.quizSecondsRemaining) seconds to answer each question. You can email the results at the end of the quiz", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Start", style: .default, handler: { (UIAlertAction) in  self.startAlert() })
            let stopAction = UIAlertAction(title: "Later", style: .default, handler: { (UIAlertAction) in self.stopAlert(score: "No Score") })
            alert.addAction(restartAction)
            alert.addAction(stopAction)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Questions Exist", message: "If you are an admin, press + above to add questions", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: { (UIAlertAction) in  self.admin() })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }

    }
    
    //TODO: If user is teacher display + button to add questions
    func hideButtons(emailAddress: String) {
        
        let checkEmailAddress = emailAddress
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        
        docRef.getDocument { (querySnapshot, error) in
        
            if let document = querySnapshot, document.exists {
                let teacherStatus = document.data()!["TeacherMemberID"] as! Bool
                if teacherStatus {self.addQuestions.isEnabled = true}
                else {self.addQuestions.isEnabled = false}
            } else {self.addQuestions.isEnabled = true}
        }
    }
    
    //TODO: If user selects email at the end of quiz then gather score and results and send email to user
    func email() {
        
        writeToRealm()
        createCSV()
        composeEmail()
        cleanFileFromCache()
        cleanupRealm()
        stopAlert(score: scoreCard)
    }
    
    //TODO: TO send email to user, write quiz results to realm
    func writeToRealm() {
        
        for i in 0..<questionNumber {
            try! realm.write {
                let questionList = QuizForRealm()
                questionList.chapter = allQuestions[i].chapter
                questionList.quizDescription = allQuestions[i].description
                questionList.question = allQuestions[i].question
                questionList.button1 = allQuestions[i].button1
                questionList.button2 = allQuestions[i].button2
                questionList.button3 = allQuestions[i].button3
                questionList.button4 = allQuestions[i].button4
                questionList.answer = allQuestions[i].answer
                questionList.chosenAnswer = selectedAnswer[i]
                realm.add(questionList)
            }
        }
    }
    
    //TODO: If user selects Later then set score = 0 and disable all the answer buttons
    func stopAlert(score: String) {
        
        self.points = score
        self.timer.invalidate()
        self.parentViewcontroller?.score = self.points
        self.parentViewcontroller?.chapterFromQuestions = self.retrievedChapter
        self.Button1.isEnabled = false
        self.Button2.isEnabled = false
        self.Button3.isEnabled = false
        self.Button4.isEnabled = false
    }
    
    //TODO: Start quiz - start timer if user selected to Start the quiz.
    func startAlert() {
        
        secondsRemaining = 4
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateAlert), userInfo: nil, repeats: true)
    }
    
    //TODO: If user selects Admin then cancel timer and do nothing.
    func admin() {
        timer.invalidate()
    }
    
    //TODO: Update alert called from startAlert
    @objc func updateAlert() {
        if secondsRemaining > 1 {
            secondsRemaining -= 1
            ProgressHUD.showSuccess("\(secondsRemaining)")
        } else {
            timer.invalidate()
            checkTime()
            progressBar.progress = 0
        }
    }

    //TODO: Give users certain seconds as defined in Constants.swift to answer each question and show timer
    func checkTime() {
        
        secondsRemaining = Constants.quizSecondsRemaining
        progressTime.text = "\(secondsRemaining)"
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //TODO: Update timer called from checkTime. Check answer, progress to next question, update screen.
    @objc func updateTimer() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            progressTime.text = "\(secondsRemaining)"
        } else {
            timer.invalidate()
            pickedAnswer = 5 // If no answer selected by user
            selectedAnswer.append(pickedAnswer)
            checkAnswer()
            questionNumber += 1
            nextQuestion()
            updateUI()
            secondsRemaining = Constants.quizSecondsRemaining
        }
    }
    
    //TODO: Prepare segues - one to go to questionTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.questionToQBSegue {
            let questionBankVC = segue.destination as! QuestionBankViewController
            questionBankVC.retrievedChapter = retrievedChapter
        }
    }
    
    // TODO: - Update the UI
    func updateUI() {
        scoreLabel.text = "Score: \(score) / \(totalCount)"
        progressLabel.text = "\(questionNumber+1) / \(totalCount)"
        progressBar.progress = (Float(questionNumber+1) / Float(totalCount))
    }
    
    // TODO: - Go to next question
    func nextQuestion() {
        if questionNumber < allQuestions.count {
            
            questionLabel.text = allQuestions[questionNumber].question
            descriptionLabel.text = allQuestions[questionNumber].description

            Button1.setTitle(allQuestions[questionNumber].button1, for: .normal)
            Button2.setTitle(allQuestions[questionNumber].button2, for: .normal)
            Button3.setTitle(allQuestions[questionNumber].button3, for: .normal)
            Button4.setTitle(allQuestions[questionNumber].button4, for: .normal)
            
            //Disable buttons if its' title is blank
            Button1.isEnabled = allQuestions[questionNumber].button1.trimmingCharacters(in: .whitespaces) == "" ? false : true
            Button2.isEnabled = allQuestions[questionNumber].button2.trimmingCharacters(in: .whitespaces) == "" ? false : true
            Button3.isEnabled = allQuestions[questionNumber].button3.trimmingCharacters(in: .whitespaces) == "" ? false : true
            Button4.isEnabled = allQuestions[questionNumber].button4.trimmingCharacters(in: .whitespaces) == "" ? false : true
            
            //Display updated score
            updateUI()
            checkTime()
        }
        else {
            timer.invalidate()
            scoreLabel.text = "Score: \(score) / \(allQuestions.count)"
            progressLabel.text = "\(questionNumber) / \(allQuestions.count)"
            progressBar.progress = (Float(questionNumber) / Float(allQuestions.count))
            
            scoreCard = scoreLabel.text!
            
            //At the end of the quiz users have three choices - Start over, end the quiz or email the results
            let alert = UIAlertController(title: "You Scored \(scoreCard)", message: "You have reached the end of this quiz. Do you wish to restart or finish?", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (UIAlertAction) in
                self.testCount += 1
                self.startOver() })
            let finishAction = UIAlertAction(title: "Finish", style: .default, handler: { (UIAlertAction) in
                
                if (CGFloat(self.score) / CGFloat(self.allQuestions.count)) >= CGFloat(0.8) {
                    self.enterBadgeLevel()
                }
                self.stopAlert(score: self.scoreCard)
            })
            let emailAction = UIAlertAction(title: "Email", style: .default, handler: { (UIAlertAction) in
                
                if (CGFloat(self.score) / CGFloat(self.allQuestions.count)) >= CGFloat(0.8) {
                    self.enterBadgeLevel()
                }
                self.email()
            })
            alert.addAction(restartAction)
            alert.addAction(finishAction)
            alert.addAction(emailAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    //TODO: Make two entries in Firstore. One to BadgeCollection where the number of times the test is taken is updated and the other one is to TestCollection where every completed test is entered as a new entry.
    func enterBadgeLevel() {
        
        //Get today's date in String format
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let testDate = df.string(from: Date())
        
        var count : Int = 0
        
        let testDictionary: [String: Any] = ["EmailAddress": user, "ModuleName": retrievedModuleForChapter, "ChapterName": retrievedChapter, "NumberOfAttempts": testCount, "DateCreated": testDate]
        
        //Insert data in to FireStore database and provide confirmation
        db.collection(Constants.FStore.testCollection).document(user).setData(testDictionary) { error in
            if let e = error {self.notifyUser("Error Saving Data", err: e as? String)}
        }
        
        let badgeRef = db.collection(Constants.FStore.badgeCollection)
        badgeRef
            .whereField("EmailAddress", isEqualTo: user)
            .whereField(Constants.FStore.moduleName, isEqualTo: retrievedModuleForChapter)
            .whereField(Constants.FStore.chapterName, isEqualTo: retrievedChapter)
            .getDocuments() { (querySnapshot, error) in
            if let e = error {self.notifyUser("Database Access Error", err: "Error retrieving previous attempts, \(e)")}
            else {
               if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let numberOfAttempts = doc.data()["NumberOfAttempts"] as? Int
                        count += numberOfAttempts ?? 0
                        self.defaults.set(count, forKey: "TemporaryCountLocation")
                    }
                }
            }
        }
        
        count = defaults.integer(forKey: "TemporaryCountLocation")
        testCount += count
        
        let badgeDictionary: [String: Any] = ["EmailAddress": user, "ModuleName": retrievedModuleForChapter, "ChapterName": retrievedChapter, "NumberOfAttempts": testCount]
        
        //Insert data in to FireStore database and provide confirmation
        db.collection(Constants.FStore.badgeCollection).document(user).setData(badgeDictionary, merge: true) { error in
            if let e = error {self.notifyUser("Error Saving Data", err: e as? String)}
        }
    }
    
    // TODO: - check if selected answer is correct
    func checkAnswer() {
        let correctAnswer = allQuestions[questionNumber].answer
        
        if correctAnswer == pickedAnswer {
            ProgressHUD.showSuccess("Correct")
            score += 1
        }
        else {ProgressHUD.showError("Wrong!")}
    }
    
    // TODO: - Start over with the assessment if user chooses to at the end. Reset score and question number
    func startOver() {
        questionNumber = 0
        score = 0
        nextQuestion()
        scoreLabel.text = "Score: \(score) / \(allQuestions.count)"
        progressLabel.text = "\(questionNumber+1) / \(allQuestions.count)"
        progressBar.frame.size.width = (CGFloat(view.frame.size.width) / CGFloat(allQuestions.count)) * CGFloat(questionNumber+1)
    }
    
    //TODO: Common function for sending alert to screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
     
    //TODO: - Create CSV and send email if user chooses to
    func createCSV() {
        
        csvString = "\("Chapter")\t\("Description")\t\("Question")\t\("Option 1")\t\("Option 2")\t\("Option 3")\t\("Option 4")\t\("Correct Answer")\t\("Your Answer")\n"
        
        let fileManager = FileManager.default
        quizList = realm.objects(QuizForRealm.self)
        if quizList != nil {
            for rec in 0..<quizList!.count {
                csvString = csvString.appending("\(String(describing: quizList![rec].chapter))\t\(String(describing: quizList![rec].quizDescription))\t\(String(describing: quizList![rec].question))\t\(String(describing: quizList![rec].button1))\t\(String(describing: quizList![rec].button2))\t\(String(describing: quizList![rec].button3))\t\(String(describing: quizList![rec].button4))\t\(String(describing: quizList![rec].answer))\t\(String(describing: quizList![rec].chosenAnswer))\n\n\n")
            }
        } else { ProgressHUD.showError("Nothing to Process") }
        
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent(self.fileName)
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            ProgressHUD.showError("Could not write to csv file. Please try again.")
        }
       csvString = ""
    }
    
    //TODO: Configure email - compose email text
    func configureMailComposeViewController() -> MFMailComposeViewController {
        
        let fileManager = FileManager.default
        let emailController = MFMailComposeViewController()
        let userEmail = Auth.auth().currentUser?.email ?? Constants.defaultEmailAddress
        
        emailController.setToRecipients([userEmail])
        emailController.mailComposeDelegate = self
        emailController.setSubject("[VoicED]: Your Scorecard from Quiz on Chapter \(retrievedChapter)")
        emailController.setMessageBody("Hello,\n\n         Attached is the scorecard from the quiz you took on chapter \(retrievedChapter). Please save the file to your computer and open using Microsoft Excel or Apple Numbers.\n\n You scored \(scoreCard) in this quiz.\n\nThank You,\nThe voicED Team\n", isHTML: false)
        
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent(self.fileName)
            let data = try Data(contentsOf: fileURL)
            emailController.addAttachmentData(data, mimeType: "text/csv", fileName: fileName)
            } catch _ {}
        return emailController
    }
    
    //TODO: Dismiss email composer
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //TODO: Compose email - call configure email composer and present it to user
    func composeEmail() {
        
        let emailViewController = configureMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(emailViewController, animated: true, completion: nil)
            } else {ProgressHUD.showError("Your device is not configured to send emails")}
    }
    
    //TODO: - Clean files in cache before new one is created
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
    
    //TODO: Clean up Realm after email is sent. Realm is populated with user answers if user chooses to receive email after quiz
    func cleanupRealm() {
        
        let cleanupQuestionsList = self.realm.objects(QuizForRealm.self) //****Realm
        if cleanupQuestionsList.count != 0 {
            do {
                try realm.write {
                    realm.delete(cleanupQuestionsList)
                }
            } catch {
                ProgressHUD.showError("Error clearing questions in Realm database: \(error)")
            }
        }
    }
    
    //MARK: - Buttons
    //TODO: User chooses an answer - check answer and progress to the next question.
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        //checking whether picked answer is the correct answer
        pickedAnswer = Int(sender.tag)
        selectedAnswer.append(pickedAnswer)
        checkAnswer()
        
        //incrementing the counter by 1 and assigning the next question from AssessmentQuestions to questionLabel
        questionNumber += 1
        
        //to prevent incrementing the counter above the number of questions in AssessmentQuestions
        nextQuestion()
        
    }
    
    //TODO: Info button to give more information on grammar badge
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        
    }
    
    //TODO: Go to questionbank screen is + button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.questionToQBSegue, sender: self)
    }
    
}

