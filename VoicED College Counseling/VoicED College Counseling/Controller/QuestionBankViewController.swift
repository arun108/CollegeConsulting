//
//  QuestionBankViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 3/3/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit
import Firebase
import CoreXLSX
import ProgressHUD
import SVProgressHUD

class QuestionBankViewController: UIViewController {
    
    // Creating UIDocumentInteractionController instance.
    let documentInteractionController = UIDocumentInteractionController()
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var chapterPicked: UILabel!
    
    @IBOutlet weak var fileLocation: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    var retrievedChapter: String = "No chapter"
    var retrievedTeacherCodeFromChapter: String = ""
    let questionArray: [Quiz] = [Quiz]()
    var answer : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting UIDocumentInteractionController delegate.
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        documentInteractionController.delegate = self
        chapterPicked.text = retrievedChapter
    }
    
    //TODO: DFunction to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if fileLocation.isFirstResponder {fileLocation.becomeFirstResponder()}
        else {fileLocation.resignFirstResponder()}
        return true
    }
    
    //MARK: - Buttons
    //TODO: Upload button to get document from a URL location and save locally to a temp location
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        
        // Passing the remote URL of the file, to be stored and then opted with mutliple actions for the user to perform
        if let locationOfFile = fileLocation.text {
            storeAndShare(withURLString: locationOfFile)
        }
    }
    
    //TODO: Logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch { notifyUser("Logout Error", err: "There was a problem signing out. Try again.") }
    }
}

extension QuestionBankViewController {
    //TODO: This function will set all the required properties, and then provide a preview for the document
    func parsedData(url: URL) {
        
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "private.data, private.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
        
        let filePath1 = String(describing: documentInteractionController.url)
        let filePath2 = String(filePath1.dropFirst(16))
        let s = String(filePath2.dropLast(1))
        
        guard let file = XLSXFile(filepath: s) else {return}
        
        //TODO: Get today's date in String format
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm a"
        let createdDate = df.string(from: Date())
        do {
            let sharedStrings = try file.parseSharedStrings()
            let parser = try file.parseWorksheetPaths()
            for path in parser {
               let ws = try file.parseWorksheet(at: path)
                for row in ws.data?.rows ?? [] {
                    let columnCStrings = row.cells
                        .compactMap{ $0.value }
                        .compactMap { Int($0) }
                        .compactMap {sharedStrings.items[$0].text }
                    if String(describing: columnCStrings[6]) == "a" {answer = 1}
                    else if String(describing: columnCStrings[6]) == "b" {answer = 2}
                    else if String(describing: columnCStrings[6]) == "c" {answer = 3}
                    else if String(describing: columnCStrings[6]) == "d" {answer = 4}
                    
                    //TODO: Dictionary definition for data entry in to Firebase database
                    let questionDictionary: [String: Any] = ["Chapter":chapterPicked.text ?? "Chapter 1", "Description": columnCStrings[0], "Question": columnCStrings[1], "Option1": columnCStrings[2], "Option2": columnCStrings[3], "Option3": columnCStrings[4], "Option4": columnCStrings[5], "CorrectAnswer": answer, "DateCreated": createdDate]
                    //TODO: Insert data in to Firebase database and provide confirmation
                    db.collection(Constants.FStore.questionCollection).addDocument(data: questionDictionary) { error in
                        if let e = error {
                            let alert = UIAlertController(title: "Error Storing Data. Please try again.", message: String(describing: e), preferredStyle: .alert)
                            let restartAction = UIAlertAction(title: "Okay", style: .default, handler: { (UIAlertAction) in  })
                            alert.addAction(restartAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
               }
            }
         } catch {
            ProgressHUD.showError(error.localizedDescription)
         }
        notifyUser("Upload attempt completed", err: "Validate completeness by going through the quiz section.")
    }
    
    //TODO: Common function to display alerts on the screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: This function will store document to a temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(withURLString: String) {
        
        guard let url = URL(string: withURLString) else { return }
        SVProgressHUD.show()
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(response?.suggestedFilename ?? "Questions.xlsx")
                do {
                    try data.write(to: tmpURL)
                } catch {
                    ProgressHUD.showError(error as? String)
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.parsedData(url: tmpURL)
                }
        }.resume()
    }
}

extension QuestionBankViewController: UIDocumentInteractionControllerDelegate {
    //TODO: If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}

