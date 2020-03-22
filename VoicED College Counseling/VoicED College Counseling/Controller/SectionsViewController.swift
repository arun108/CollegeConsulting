//
//  SectionsViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/18/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import PDFKit
import SVProgressHUD
import MessageUI
import Firebase

class SectionsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var fileName: String = ""
    var fileLocation: String = ""
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Passing the remote URL of the file, to be stored and then opted with mutliple actions for the user to perform
        if !fileLocation.isEmpty {
            storeAndShare(withURLString: fileLocation)
        } else { performSegue(withIdentifier: Constants.toStudentProfileSegue, sender: self) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults.bool(forKey: Constants.backFromProfileTableView) {
            defaults.set(false, forKey: Constants.backFromProfileTableView)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    //TODO: View PDF
    func viewPDF(filePath: URL) {
        
        let path = filePath.path
        let localFileLocation = filePath
        if !path.isEmpty {
            if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) {
                pdfView.displayMode = .singlePageContinuous
                pdfView.autoScales = true
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
            }
        }
        prepareForEmail(filePath: localFileLocation)
    }
    
    //TODO: This function will store document to a temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(withURLString: String) {
        
        guard let url = URL(string: withURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            SVProgressHUD.show()
            guard let data = data, error == nil else { return }
            
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(response? .suggestedFilename ?? self.fileName)
            
                do {
                    try data.write(to: tmpURL)
                } catch {
                    ProgressHUD.showError(error as? String)
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.viewPDF(filePath: tmpURL)
                }
        }.resume()
    }
    
    //TODO: Provide option for user to email the file to self
    func prepareForEmail(filePath: URL) {
        let localFilePath = filePath
        let alert = UIAlertController(title: "Email the document?", message: "Would you like this document emailed to you?", preferredStyle: .alert)
        let emailAction = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in self.sendEmail(filePath: localFilePath) })
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (UIAlertAction) in })
        alert.addAction(emailAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    //TODO: Draft email and present to user and then delete file from cache
    func sendEmail(filePath: URL) {
        let localFilePath = filePath
        composeEmail(filePath: localFilePath)
        cleanFileFromCache(filePath: localFilePath)
    }
    
    //TODO: Configure email - compose email text
    func configureMailComposeViewController(filePath: URL) -> MFMailComposeViewController {
        let localFilePath = filePath
        let emailController = MFMailComposeViewController()
        let userEmail = Auth.auth().currentUser?.email ?? Constants.defaultEmailAddress
        
        emailController.setToRecipients([userEmail])
        emailController.mailComposeDelegate = self
        emailController.setSubject("[VoicED]: The file \(fileName) you requested")
        emailController.setMessageBody("Hello,\n\n         Attached is the \(fileName) file you requested. We hope that you benefit from the content of this document.\n\nThank You,\nThe voicED Team\n", isHTML: false)
        
        do {
            let fileURL = localFilePath
            let data = try Data(contentsOf: fileURL)
            emailController.addAttachmentData(data, mimeType: "pdf", fileName: fileName)
        } catch _ {}
        return emailController
    }
    
    //TODO: Dismiss email composer
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //TODO: Compose email - call configure email composer and present it to user
    func composeEmail(filePath: URL) {
        let localFilePath = filePath
        let emailViewController = configureMailComposeViewController(filePath: localFilePath)
            if MFMailComposeViewController.canSendMail() {
                self.present(emailViewController, animated: true, completion: nil)
            } else {ProgressHUD.showError("Your device is not configured to send emails")}
    }
    
    //TODO: - Clean files in cache before new one is created
    func cleanFileFromCache(filePath: URL) {
        let localFilePath = filePath
        let fileManager = FileManager.default
        
        do {
            let fileURL = localFilePath
            let filePath = fileURL.path
            let files = try fileManager.contentsOfDirectory(atPath: "\(filePath)")
            let filePathName = "\(filePath)/\(files)"
            try fileManager.removeItem(atPath: filePathName)
        } catch _ {}
    }
}
