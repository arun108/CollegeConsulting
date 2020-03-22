//
//  RouletteViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 9/23/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import RealmSwift
import Security

postfix operator °

protocol IntegerInitializable: ExpressibleByIntegerLiteral {
    init (_: Int)
}

extension Int: IntegerInitializable {
    postfix public static func °(lhs: Int) -> CGFloat {
        return CGFloat(lhs) * .pi / 180
    }
}

extension CGFloat: IntegerInitializable {
    postfix public static func °(lhs: CGFloat) -> CGFloat {
        return lhs * .pi / 180
    }
}

class RouletteViewController: UIViewController {

    @IBOutlet weak var roulette: UIView!
    @IBOutlet weak var roulettePlanner: UIView!
    @IBOutlet weak var rouletteEssay: UIView!
    @IBOutlet weak var rouletteScholarship: UIView!
    @IBOutlet weak var rouletteColleges: UIView!
    @IBOutlet weak var rouletteNaviance: UIView!
    @IBOutlet weak var roulettePayments: UIView!
    @IBOutlet weak var rouletteClasses: UIView!
    
    @IBOutlet weak var groupChatButton: UIButton!
    @IBOutlet weak var plannerButton: UIButton!
    @IBOutlet weak var essayButton: UIButton!
    @IBOutlet weak var scholarshipButton: UIButton!
    @IBOutlet weak var collegeListButton: UIButton!
    @IBOutlet weak var navianceButton: UIButton!
    @IBOutlet weak var paymentsButton: UIButton!
    @IBOutlet weak var classesButton: UIButton!
    
    @IBOutlet weak var contentSummary: UILabel!
    @IBOutlet weak var rouletteContent: UIPickerView!
    
    var rouletteContentDict: Dictionary<String,String> = Dictionary<String,String>()
    var rouletteArray: [UIView] = [UIView]()
    var capturedEmailAddress : String = ""
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    let user = Auth.auth().currentUser
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        rouletteContent.delegate = self
        rouletteContent.dataSource = self
        
        groupChatButton.layer.cornerRadius = groupChatButton.frame.size.height / 10
        plannerButton.layer.cornerRadius = plannerButton.frame.size.height / 10
        essayButton.layer.cornerRadius = essayButton.frame.size.height / 10
        scholarshipButton.layer.cornerRadius = scholarshipButton.frame.size.height / 10
        collegeListButton.layer.cornerRadius = collegeListButton.frame.size.height / 10
        navianceButton.layer.cornerRadius = navianceButton.frame.size.height / 10
        paymentsButton.layer.cornerRadius = paymentsButton.frame.size.height / 10
        classesButton.layer.cornerRadius = classesButton.frame.size.height / 10
        
        //Main menu items
        rouletteArray = [rouletteClasses, roulettePayments, rouletteNaviance, rouletteColleges, rouletteScholarship, rouletteEssay, roulettePlanner, roulette]
        
        //Description of the main menu items
        rouletteContentDict = Constants.rouletteContentDict
        
        rotateRouletteButton()
        
    }
    
    //TODO: Define navigationbar color and layout when returning back from menu items
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.red
    }
    
    //TODO: Function to perform main menu animation
    func rotateRouletteButton() {
        
        for i in 0..<rouletteArray.count {
            UIView.animate(withDuration: 0.5,
                           delay: TimeInterval(CGFloat(Double(i) * 0.125)),
                           options: .curveLinear,
                           animations: {
                            var rouletteFrame = self.rouletteArray[i].frame
                            rouletteFrame.origin.x -= rouletteFrame.size.width
                            self.rouletteArray[i].frame = rouletteFrame
                            },
                           completion: { finished in
                            UIView.animate(withDuration: 0.5,
                                delay: TimeInterval(CGFloat(Double(i) * 0.125)),
                               options: .curveLinear,
                               animations: {
                                var rouletteFrame = self.rouletteArray[i].frame
                                rouletteFrame.origin.x -= (self.view.frame.width/2)
                                self.rouletteArray[i].frame = rouletteFrame
                                },
                               completion: { finished in
                                self.rouletteArray[i].setAnchorPoint(CGPoint(x: 0.5, y:0.0))
                                self.rouletteArray[i].rotateWithAnimation(angle: (CGFloat(360) - (CGFloat(Double(i+1) * 0.125 * Double(360))))°, duration: CGFloat(2.0) + CGFloat(Double(i) * 0.125))
                })
            })
        }
    }
    
    //TODO: Button to call Chat segue which requires credentials check before proceeding
    @IBAction func groupChatButtonPressed(_ sender: UIButton) {
        
        capturedEmailAddress = Auth.auth().currentUser?.email ?? "abc@123.com"
        if capturedEmailAddress == "abc@123.com" || capturedEmailAddress == "" {
            capturedEmailAddress = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
            if capturedEmailAddress == "abc@123.com" {capturedEmailAddress = ""}
            self.defaults.set(false, forKey: Constants.backToChatRegister)
            self.performSegue(withIdentifier: Constants.groupChatRegisterSeque, sender: self)
        }
        else {
            self.defaults.set(true, forKey: Constants.backToChatRegister)
            self.performSegue(withIdentifier: Constants.groupChatSegue, sender: self)
        }
    }
    
    
    @IBAction func essayButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.toModuleSegue, sender: self)
    }
    
    
    @IBAction func scholarshipButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.scholarshipsSegue, sender: self)
    }
    
    
    @IBAction func collegeListButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.collegeListSegue, sender: self)
    }
    
    
    @IBAction func navianceButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.settingsSegue, sender: self)
    }
    
    
    @IBAction func paymentButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.paymentsSegue, sender: self)
    }
    
    
    @IBAction func plannerButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.toPlannerSegue, sender: self)
    }
    
    //TODO: Button to call Grammar segue which requires credentials check before proceeding
    @IBAction func classesButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: Constants.toModuleSegue, sender: self)
        
        capturedEmailAddress = Auth.auth().currentUser?.email ?? "abc@123.com"
        if capturedEmailAddress == "abc@123.com" || capturedEmailAddress == "" {
            capturedEmailAddress = defaults.string(forKey: Constants.defaultEmailAddress) ?? "abc@123.com"
            if capturedEmailAddress == "abc@123.com" {capturedEmailAddress = ""}
            self.defaults.set(false, forKey: Constants.backToQuizRegister)
            self.performSegue(withIdentifier: Constants.toGrammarWindowSegue, sender: self)
        }
        else {
            self.defaults.set(true, forKey: Constants.backToQuizRegister)
            self.performSegue(withIdentifier: Constants.toModuleSegue, sender: self)
        }
    }
    
    //TODO: Prepare segues - one to go to Chatting ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.groupChatRegisterSeque {
            let chatRegisterVC = segue.destination as! ChatValidationViewController
            chatRegisterVC.passedEmailAddress = capturedEmailAddress
        } else if segue.identifier == Constants.groupChatSegue {
            let chatVC = segue.destination as! ChatViewController
            chatVC.chatEmailAddress = capturedEmailAddress
        } else if segue.identifier == Constants.toChatWindowSegue {
            let chatWindowVC = segue.destination as! ChatViewController
            chatWindowVC.chatEmailAddress = capturedEmailAddress
        } else if segue.identifier == Constants.toGrammarWindowSegue {
            let grammarRegVC = segue.destination as! QuizValidationViewController
            grammarRegVC.passedEmailAddress = capturedEmailAddress
        } else if segue.identifier == Constants.fromRegToGrammarSegue {
            let grammarVC = segue.destination as! QuizValidationViewController
            grammarVC.passedEmailAddress = capturedEmailAddress
        }
    }
    
    //TODO: Logout
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch { ProgressHUD.showError("Error, there was a problem signing out.") }
    }
}

extension UIView {
    //TODO: Function to perform rotation of main menu items
    func rotateWithAnimation(angle: CGFloat, duration: CGFloat? = nil) {
        let pathAnimation = CABasicAnimation(keyPath: "transform.rotation")
        pathAnimation.duration = CFTimeInterval(duration ?? 1.0)
        pathAnimation.fromValue = 0
        pathAnimation.toValue = angle
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        self.transform = transform.rotated(by: angle)
        self.layer.add(pathAnimation, forKey: "transform.rotation")
    }
    
    //TODO: Function to change anchor point for main menu items
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}

//MARK: - Pickerview to display detailed description of main menu items
extension RouletteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rouletteContentDict.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(rouletteContentDict)[row].key
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        contentSummary.text = ""
        contentSummary.text = Array(rouletteContentDict)[row].value
        rouletteContent.reloadAllComponents()
    }
}
