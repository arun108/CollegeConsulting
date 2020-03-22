//
//  ConsultationViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 1/2/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import MessageUI
import SafariServices

class ConsultationViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var extraCurricular: UITextView!
    @IBOutlet weak var collegeMajor: UITextField!
    @IBOutlet weak var wgpa: UITextField!
    @IBOutlet weak var ugpa: UITextField!
    @IBOutlet weak var schoolRank: UISwitch!
    @IBOutlet weak var rank: UITextField!
    @IBOutlet weak var satScore: UITextField!
    @IBOutlet weak var actScore: UITextField!
    @IBOutlet weak var subjectTests: UITextView!
    @IBOutlet weak var targetedCollegeCount: UITextField!
    @IBOutlet weak var stateBound: UISwitch!
    @IBOutlet weak var talentOrPassion: UITextView!
    @IBOutlet weak var questions: UITextView!
    @IBOutlet weak var phoneOption: UISwitch!
    @IBOutlet weak var zoomOption: UISwitch!
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var consultationButton: UIButton!
    @IBOutlet weak var consultationView: UIView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var extraCurricularLabel: UILabel!
    @IBOutlet weak var collegeMajorLabel: UILabel!
    @IBOutlet weak var GPALabel: UILabel!
    @IBOutlet weak var doesSchoolRankLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var satActScoreLabel: UILabel!
    @IBOutlet weak var subjectTestLabel: UILabel!
    @IBOutlet weak var collegeTargetingLabel: UILabel!
    @IBOutlet weak var stateBoundLabel: UILabel!
    @IBOutlet weak var specificTalentLabel: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var preferredContactMethod: UILabel!
    @IBOutlet weak var phoneOptionLabel: UILabel!
    @IBOutlet weak var zoomOptionLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    let db = Firestore.firestore()
    var consultList: Results<Consultation>?
    
    var localEmailAddressLabel : String = ""
    var localEmailAddress : String = ""
    var localPhoneNumberLabel : String = ""
    var localPhoneNumber : String = ""
    var localExtraCurricularLabel : String = ""
    var localExtracurricular : String = ""
    var localCollegeMajorLabel : String = ""
    var localCollegeMajor : String = ""
    var localGPALabel : String = ""
    var localUgpa : String = ""
    var localWgpa : String = ""
    var localDoesSchoolRankLabel : String = ""
    var localSchoolRank : String = ""
    var localRankLabel : String = ""
    var localRank : String = ""
    var localSatActLabel : String = ""
    var localSatScore : String = ""
    var localActScore : String = ""
    var localSubjectTestLabel : String = ""
    var localSubjectTests : String = ""
    var localCollegeTargetingLabel : String = ""
    var localTargetCollegeCount : String = ""
    var localStateBoundLabel : String = ""
    var localStateBound : String = ""
    var localSpecificTalentLabel : String = ""
    var localTalentOrPassion : String = ""
    var localQuestionsLabel : String = ""
    var localQuestions : String = ""
    var localpreferredContactMethod : String = ""
    var localPhoneOption : String = ""
    var localZoomOption : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.systemPink
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        emailAddress.delegate = self
        phoneNumber.delegate = self
        extraCurricular.delegate = self as? UITextViewDelegate
        collegeMajor.delegate = self
        wgpa.delegate = self
        ugpa.delegate = self
        rank.delegate = self
        satScore.delegate = self
        actScore.delegate = self
        subjectTests.delegate = self as? UITextViewDelegate
        targetedCollegeCount.delegate = self
        talentOrPassion.delegate = self as? UITextViewDelegate
        questions.delegate = self as? UITextViewDelegate
        
        extraCurricular.layer.cornerRadius = extraCurricular.frame.size.height / 5
        subjectTests.layer.cornerRadius = subjectTests.frame.size.height / 5
        talentOrPassion.layer.cornerRadius = talentOrPassion.frame.size.height / 5
        questions.layer.cornerRadius = questions.frame.size.height / 5
        paymentButton.layer.cornerRadius = paymentButton.frame.size.height / 5
        consultationButton.layer.cornerRadius = consultationButton.frame.size.height / 5
        
        //Hide or display buttons based on user type
        let email = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
        emailAddress.text = Auth.auth().currentUser?.email ?? email
        
        consultList = realm.objects(Consultation.self)
        readConsultEntry()
    }
    
    //TODO: Function to save entry to Realm to avoid loosing data in case of interruption to the user entry process
    func textFieldDidEndEditing(_ textField: UITextField) {
        
            if isValidEmail(emailAddress.text ?? " ") {
                saveEntry()
                emailAddress.resignFirstResponder()
            } else {notifyUser("Invalid Email Format", err: "Please enter valid email address")
                emailAddress.becomeFirstResponder()
            }
    }
    
    //TODO: Keyboard control
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if emailAddress.isFirstResponder {
            if isValidEmail(emailAddress.text ?? " ") {
                emailAddress.resignFirstResponder()
            } else {notifyUser("Invalid Email Format", err: "Please enter valid email address")
                emailAddress.becomeFirstResponder()
            }
        }
        
        if phoneNumber.isFirstResponder {phoneNumber.becomeFirstResponder()}
        else {phoneNumber.resignFirstResponder()}
        
        if extraCurricular.isFirstResponder {extraCurricular.becomeFirstResponder()}
        else {extraCurricular.resignFirstResponder()}
        
        if collegeMajor.isFirstResponder {collegeMajor.becomeFirstResponder()}
        else {collegeMajor.resignFirstResponder()}
        
        if wgpa.isFirstResponder {wgpa.becomeFirstResponder()}
        else {wgpa.resignFirstResponder()}
        
        if ugpa.isFirstResponder {ugpa.becomeFirstResponder()}
        else {ugpa.resignFirstResponder()}
        
        if rank.isFirstResponder {rank.becomeFirstResponder()}
        else {rank.resignFirstResponder()}
        
        if satScore.isFirstResponder {satScore.becomeFirstResponder()}
        else {satScore.resignFirstResponder()}
        
        if actScore.isFirstResponder {actScore.becomeFirstResponder()}
        else {actScore.resignFirstResponder()}
        
        if subjectTests.isFirstResponder {subjectTests.becomeFirstResponder()}
        else {subjectTests.resignFirstResponder()}
        
        if targetedCollegeCount.isFirstResponder {targetedCollegeCount.becomeFirstResponder()}
        else {targetedCollegeCount.resignFirstResponder()}
        
        if talentOrPassion.isFirstResponder {talentOrPassion.becomeFirstResponder()}
        else {talentOrPassion.resignFirstResponder()}
        
        if questions.isFirstResponder {questions.becomeFirstResponder()}
        else {questions.resignFirstResponder()}
        
        return true
    }
    
    //TODO: The function that actually saves entry to Realm to avoid loosing data in case of interruption to the user entry process
    func saveEntry() {
        let newConsultList = Consultation()
        
        if let emailAddressEntry = emailAddress.text {newConsultList.emailAddress = emailAddressEntry}
        if let phoneNumberEntry = phoneNumber.text {newConsultList.phoneNumber = phoneNumberEntry}
        if let extraCurricularEntry = extraCurricular.text {newConsultList.extraCurricular = extraCurricularEntry}
        if let collegeMajorEntry = collegeMajor.text {newConsultList.collegeMajor = collegeMajorEntry}
        if let wgpaEntry = wgpa.text {newConsultList.wgpa = wgpaEntry}
        if let ugpaEntry = ugpa.text {newConsultList.ugpa = ugpaEntry}
        newConsultList.schoolRank = schoolRank.isOn ? "Yes" : "No"
        if let rankEntry = rank.text {newConsultList.rank = rankEntry}
        if let satScoreEntry = satScore.text {newConsultList.satScore = satScoreEntry}
        if let actScoreEntry = actScore.text {newConsultList.actScore = actScoreEntry}
        if let subjectTestsEntry = subjectTests.text {newConsultList.subjectTests = subjectTestsEntry}
        if let targetedCollegeCountEntry = targetedCollegeCount.text {newConsultList.targetedCollegeCount = targetedCollegeCountEntry}
        newConsultList.stateBound = stateBound.isOn ? "Yes" : "No"
        if let talentOrPassionEntry = talentOrPassion.text {newConsultList.talentOrPassion = talentOrPassionEntry}
        if let targetedQuestionsEntry = questions.text {newConsultList.questions = targetedQuestionsEntry}
        newConsultList.phoneOption = phoneOption.isOn ? "Yes" : "No"
        newConsultList.zoomOption = zoomOption.isOn ? "Yes" : "No"
        
        if let consultationList = consultList?.first {
            try! realm.write {
                consultationList.emailAddress = newConsultList.emailAddress
                consultationList.phoneNumber = newConsultList.phoneNumber
                consultationList.extraCurricular = newConsultList.extraCurricular
                consultationList.collegeMajor = newConsultList.collegeMajor
                consultationList.wgpa = newConsultList.wgpa
                consultationList.ugpa = newConsultList.ugpa
                consultationList.schoolRank = newConsultList.schoolRank
                consultationList.rank = newConsultList.rank
                consultationList.satScore = newConsultList.satScore
                consultationList.actScore = newConsultList.actScore
                consultationList.subjectTests = newConsultList.subjectTests
                consultationList.targetedCollegeCount = newConsultList.targetedCollegeCount
                consultationList.stateBound = newConsultList.stateBound
                consultationList.talentOrPassion = newConsultList.talentOrPassion
                consultationList.questions = newConsultList.questions
                consultationList.phoneOption = newConsultList.phoneOption
                consultationList.zoomOption = newConsultList.zoomOption
            }
        }
        
    }
    
    //TODO: Fetching data from Realm in case of a need to retrieve
    func readConsultEntry() {
        
        emailAddress.text = consultList?.first?.emailAddress
        phoneNumber.text = consultList?.first?.phoneNumber
        extraCurricular.text = consultList?.first?.extraCurricular
        collegeMajor.text = consultList?.first?.collegeMajor
        wgpa.text = consultList?.first?.wgpa
        ugpa.text = consultList?.first?.wgpa
        schoolRank.isOn = consultList?.first?.schoolRank == "Yes" ? true : false
        rank.text = consultList?.first?.rank
        satScore.text = consultList?.first?.satScore
        actScore.text = consultList?.first?.actScore
        subjectTests.text = consultList?.first?.subjectTests
        targetedCollegeCount.text = consultList?.first?.targetedCollegeCount
        stateBound.isOn = consultList?.first?.stateBound == "Yes" ? true : false
        talentOrPassion.text = consultList?.first?.talentOrPassion
        questions.text = consultList?.first?.questions
        phoneOption.isOn = consultList?.first?.phoneOption == "Yes" ? true : false
        zoomOption.isOn = consultList?.first?.zoomOption == "Yes" ? true : false
    }
    
    //TODO: Get name from email and trigger email message
    func getName(emailAddress: String) {
        
        var fullName: String = ""
        let checkEmailAddress = emailAddress
        let docRef = db.collection(Constants.FStore.userCollection).document(checkEmailAddress)
        
        docRef.getDocument { (querySnapshot, error) in
        
            if let document = querySnapshot, document.exists {
                let retrievedFirstName = document.data()!["UserFirstName"] as? String
                let retrievedLastName = document.data()!["UserLastName"] as? String
                
                if let firstName = retrievedFirstName, let lastName = retrievedLastName {
                    fullName = "\(firstName) \(lastName)"
                    self.defaults.set(fullName, forKey: Constants.fullName)
                }
            }
            self.composeEmail()
        }
    }
    
    //TODO: Check for valid email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: Write up the email
    func configureMailComposeViewController() -> MFMailComposeViewController {
        
        let emailController = MFMailComposeViewController()
        let userEmail = Auth.auth().currentUser?.email ?? Constants.defaultEmailAddress
        if let senderName = defaults.string(forKey: Constants.fullName) {
            let consultRequestFrom = senderName
            let subjectLine: String = "[VoicED]: Consultation request from \(String(describing: consultRequestFrom))"
            emailController.setSubject(subjectLine)
        } else {
            let subjectLine: String = "[VoicED]: Consultation request from \(emailAddress.text!)"
            emailController.setSubject(subjectLine)
        }
        emailController.setToRecipients([userEmail])
        emailController.mailComposeDelegate = self
        
        let emailConsultList = realm.objects(Consultation.self)
        
        if let presentEmailAddressLabel =  emailLabel.text {localEmailAddressLabel = presentEmailAddressLabel}
        if let presentEmailAddress = emailConsultList.first?.emailAddress { localEmailAddress = presentEmailAddress}
        if let presentPhoneNumberLabel =  phoneNumberLabel.text {localPhoneNumberLabel = presentPhoneNumberLabel}
        if let presentPhoneNumber = emailConsultList.first?.phoneNumber { localPhoneNumber = presentPhoneNumber}
        if let presentextraCurricularLabel = extraCurricularLabel.text { localExtraCurricularLabel = presentextraCurricularLabel}
        if let presentExtracurricular = emailConsultList.first?.extraCurricular { localExtracurricular = presentExtracurricular}
        if let presentCollegeMajorLabel = collegeMajorLabel.text { localCollegeMajorLabel = presentCollegeMajorLabel}
        if let presentCollegeMajor = emailConsultList.first?.collegeMajor { localCollegeMajor = presentCollegeMajor}
        if let presentGPALabel = GPALabel.text { localGPALabel = presentGPALabel}
        if let presentUgpa = emailConsultList.first?.ugpa { localUgpa = presentUgpa}
        if let presentWgpa = emailConsultList.first?.wgpa { localWgpa = presentWgpa}
        if let presentDoesSchoolRankLabel = doesSchoolRankLabel.text { localDoesSchoolRankLabel = presentDoesSchoolRankLabel}
        if let presentSchoolRank = emailConsultList.first?.schoolRank { localSchoolRank = presentSchoolRank}
        if let presentRankLabel = rankLabel.text { localRankLabel = presentRankLabel}
        if let presentRank = emailConsultList.first?.rank { localRank = presentRank}
        if let presentSatActLabel = satActScoreLabel.text { localSatActLabel = presentSatActLabel}
        if let presentSatScore = emailConsultList.first?.satScore { localSatScore = presentSatScore}
        if let presentActScore = emailConsultList.first?.actScore { localActScore = presentActScore}
        if let presentSubjectTestLabel = subjectTestLabel.text { localSubjectTestLabel = presentSubjectTestLabel}
        if let presentSubjectTests = emailConsultList.first?.subjectTests { localSubjectTests = presentSubjectTests}
        if let presentCollegeTargetingLabel = collegeTargetingLabel.text { localCollegeTargetingLabel = presentCollegeTargetingLabel}
        if let presentTargetCollegeCount = emailConsultList.first?.targetedCollegeCount { localTargetCollegeCount = presentTargetCollegeCount}
        if let presentStateBoundLabel = stateBoundLabel.text { localStateBoundLabel = presentStateBoundLabel}
        if let presentStateBound = emailConsultList.first?.stateBound { localStateBound = presentStateBound}
        if let presentSpecificTalentLabel = specificTalentLabel.text { localSpecificTalentLabel = presentSpecificTalentLabel}
        if let presentTalentOrPassion = emailConsultList.first?.talentOrPassion { localTalentOrPassion = presentTalentOrPassion}
        if let presentQuestionsLabel = questionsLabel.text {localQuestionsLabel = presentQuestionsLabel}
        if let presentQuestions = emailConsultList.first?.questions { localQuestions = presentQuestions}
        if let presentPreferredContactLabel = preferredContactMethod.text {localpreferredContactMethod = presentPreferredContactLabel}
        if let presentPhoneOption = emailConsultList.first?.phoneOption { localPhoneOption = presentPhoneOption}
        if let presentZoomOption = emailConsultList.first?.zoomOption { localZoomOption = presentZoomOption}
        
        let subjectBody = "Hello VoicED,\n\n         Request for consultation:\n\n \(localEmailAddressLabel): \(localEmailAddress)\n\n\(localPhoneNumberLabel): \(localPhoneNumber)\n\n\(localExtraCurricularLabel):\n\(localExtracurricular)\n\n\(localCollegeMajorLabel): \(localCollegeMajor)\n\n\(localGPALabel):     UGPA: \(localUgpa), WGPA: \(localWgpa)\n\n\(localDoesSchoolRankLabel): \(localRank)\n\(localRankLabel): \(localRank)\n\n\(localSatActLabel): SAT Score: \(localSatScore), ACT Score: \(localActScore)\n\n\(localSubjectTestLabel):\n\(localSubjectTests)\n\n\(localCollegeTargetingLabel): \(localTargetCollegeCount)\n\n\(localStateBoundLabel): \(localStateBound)\n\n\(localSpecificTalentLabel):\n \(localTalentOrPassion)\n\n\(localQuestionsLabel): \n\(localQuestions)\n\n\(localpreferredContactMethod):\n\nPhone Option: \(localPhoneOption)\n\nZoom Option: \(localZoomOption)\n"
        
        emailController.setMessageBody(subjectBody, isHTML: false)
        
        return emailController
    }
    
    //TODO: Email controller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //TODO: Trigger email compose
    func composeEmail() {
        let emailViewController = configureMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(emailViewController, animated: true, completion: nil)
        } else {
            ProgressHUD.showError("Your device is not configured to send emails")
        }
    }
    
    //TODO: Load webpage to collect payment
    func collectPayment() {
        //Load URL
        let url = Constants.consultPaymentForm
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            
            vc.delegate = self
            
            present(vc, animated: true)
        }
    }
    
    //MARK: - Buttons
    //TODO: Trigger send email
    @IBAction func consultationButtonPressed(_ sender: UIButton) {
        
        if isValidEmail(emailAddress.text ?? " ") {
            saveEntry()
            let userEmail = emailAddress.text!
            getName(emailAddress: userEmail)
        } else {notifyUser("Invalid Email Format", err: "Please enter valid email address")
            emailAddress.becomeFirstResponder()
        }
    }
    
    //TODO: If School ranks students then save data to Realm
    @IBAction func schoolRankSelected(_ sender: UISwitch) {
        let newConsultList = Consultation()
        newConsultList.schoolRank = schoolRank.isOn ? "Yes" : "No"
        if let consultationList = consultList?.first {
            try! realm.write {
                consultationList.schoolRank = newConsultList.schoolRank
            }
        }
    }
    
    //TODO: If student is state bound then save data to Realm
    @IBAction func stateBoundSelected(_ sender: UISwitch) {
        let newConsultList = Consultation()
        newConsultList.stateBound = stateBound.isOn ? "Yes" : "No"
        if let consultationList = consultList?.first {
            try! realm.write {
                consultationList.stateBound = newConsultList.stateBound
            }
        }
    }
    
    //TODO: If Phone option is selected then Zoom option is not preferred
    @IBAction func phoneOptionSelected(_ sender: UISwitch) {
        if phoneOption.isOn {
            zoomOption.isOn = false
        }
        let newConsultList = Consultation()
        newConsultList.phoneOption = phoneOption.isOn ? "Yes" : "No"
        newConsultList.zoomOption = zoomOption.isOn ? "Yes" : "No"
        if let consultationList = consultList?.first {
            try! realm.write {
                consultationList.phoneOption = newConsultList.phoneOption
                consultationList.zoomOption = newConsultList.zoomOption
            }
        }
    }
    
    //TODO: If Zoom option is selected then Phone option is not preferred
    @IBAction func zoomOptionSelected(_ sender: UISwitch) {
        if zoomOption.isOn {
            phoneOption.isOn = false
        }
        let newConsultList = Consultation()
        newConsultList.phoneOption = phoneOption.isOn ? "Yes" : "No"
        newConsultList.zoomOption = zoomOption.isOn ? "Yes" : "No"
        if let consultationList = consultList?.first {
            try! realm.write {
                consultationList.phoneOption = newConsultList.phoneOption
                consultationList.zoomOption = newConsultList.zoomOption
            }
        }
    }
    
    //TODO: If paying then open ClickFunnel page to collect payment and enable Submit button
    @IBAction func payButtonPressed(_ sender: UIButton) {
        if isValidEmail(emailAddress.text ?? " ") {
            saveEntry()
            paymentButton.backgroundColor = UIColor(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 0.25)
            paymentButton.titleLabel?.textColor = UIColor(white: 0.25, alpha: 0.25)
            paymentButton.isEnabled = false
            consultationButton.isHidden = false
            notificationLabel.isHidden = false
            //Open webpage
            collectPayment()
        } else {notifyUser("Invalid Email Format", err: "Please enter valid email address")
            emailAddress.becomeFirstResponder()
        }
    }
    
    //TODO: Logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            //cleanupRealmBeforeLogout()
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            ProgressHUD.showError("Error, there was a problem signing out.")
        }
    }
    
}
