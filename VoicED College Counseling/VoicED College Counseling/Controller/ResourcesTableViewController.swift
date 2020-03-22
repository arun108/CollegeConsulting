//
//  ResourcesTableViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/18/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit
import RealmSwift
import ProgressHUD
import SafariServices
import ChameleonFramework

class ResourcesTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    let defaults = UserDefaults.standard
    let realm = try! Realm()
    var resourcesList: Results<Resource>?
    var fileToOpen: String = ""
    
    var notFirstTimeResources: Bool = false
    
    @IBOutlet var resourceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.flatBlueDark()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        retrieveResources()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
    }
    
    //TODO: Populate Realm with Array information and display on screen
    func firstTimePopulation() {
        
        let resourcesArray = Constants.resourcesArray
        
        for i in 0..<resourcesArray.count {
            try! realm.write {
                        let initialResourceList = Resource()
                        initialResourceList.resourceName = resourcesArray[i]
                        initialResourceList.dateCreated = Date()
                        realm.add(initialResourceList)
                    }
        }
        self.defaults.set(true, forKey: Constants.notFirstTimeResources)
    }
    
    // MARK: - Tableview data source
    //TODO: numberOfSections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //TODO: numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resourcesList?.count ?? 1
    }
    
    //TODO: Cell properties
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resourcesCell, for: indexPath) 
        
        cell.textLabel?.text = resourcesList?[indexPath.row].resourceName ?? "No Resources" //*****Realm
        
        if let cellColor = UIColor.flatBlueDark().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(resourcesList!.count)) {
        cell.backgroundColor = cellColor
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        }
        return cell
    }
    
    //TODO: Retrieve resources list from Realm
    func retrieveResources() {
        
        if defaults.bool(forKey: Constants.notFirstTimeResources) {} else {firstTimePopulation()}
        resourcesList = realm.objects(Resource.self)
        tableView.reloadData()
    }
    
    //TODO: Commmon function to load webpage
    func loadWebpage(webpage: String) {
        
        //Load URL
        let url = webpage
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true)
        }
    }
     
    //TODO: Common function to display alerts on screen
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg, message: err, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO: Prepare segues - one to go to TaskTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if fileToOpen == "College-Planner.pdf" {
            let collegePlannerVC = segue.destination as! SectionsViewController
            collegePlannerVC.fileName = fileToOpen
            collegePlannerVC.fileLocation = Constants.collegePlannerResource
        } else if fileToOpen == "CollegeVisitWorksheet.pdf" {
            let collegeVisitVC = segue.destination as! SectionsViewController
            collegeVisitVC.fileName = fileToOpen
            collegeVisitVC.fileLocation = Constants.collegeVisitResource
        } else if fileToOpen == "raiseGPA.pdf" {
            let raiseGPAVC = segue.destination as! SectionsViewController
            raiseGPAVC.fileName = fileToOpen
            raiseGPAVC.fileLocation = Constants.howToRaiseGPAResource
        } else if fileToOpen == "Preparing-for-the-ACT.pdf" {
           let ACTResourceVC = segue.destination as! SectionsViewController
           ACTResourceVC.fileName = fileToOpen
           ACTResourceVC.fileLocation = Constants.linkACTResource
        } else if fileToOpen == "Preparing-for-the-SAT.pdf" {
          let SATResourceVC = segue.destination as! SectionsViewController
          SATResourceVC.fileName = fileToOpen
          SATResourceVC.fileLocation = Constants.linkSATResource
        } else if fileToOpen == "sat-practice-test-1-scoring.pdf" {
          let SAT1ScoringVC = segue.destination as! SectionsViewController
          SAT1ScoringVC.fileName = fileToOpen
          SAT1ScoringVC.fileLocation = Constants.SAT1ScoringResource
        } else if fileToOpen == "sat-practice-test-1.pdf" {
          let SATTest1VC = segue.destination as! SectionsViewController
          SATTest1VC.fileName = fileToOpen
          SATTest1VC.fileLocation = Constants.SATTest1Resource
        } else if fileToOpen == "sat-practice-test-1-essay.pdf" {
          let SAT1EssayVC = segue.destination as! SectionsViewController
          SAT1EssayVC.fileName = fileToOpen
          SAT1EssayVC.fileLocation = Constants.SAT1EssayResource
        } else if fileToOpen == "sat-practice-test-1-answers.pdf" {
          let SAT1AnswersVC = segue.destination as! SectionsViewController
          SAT1AnswersVC.fileName = fileToOpen
          SAT1AnswersVC.fileLocation = Constants.SAT1AnswersResource
        } else if fileToOpen == "sat-practice-answering-sheet.pdf" {
          let SATAnsweringSheetVC = segue.destination as! SectionsViewController
          SATAnsweringSheetVC.fileName = fileToOpen
          SATAnsweringSheetVC.fileLocation = Constants.SATAnsweringSheetResource
        } else if fileToOpen == "sat-practice-test-2-scoring.pdf" {
          let SAT2ScoringVC = segue.destination as! SectionsViewController
          SAT2ScoringVC.fileName = fileToOpen
          SAT2ScoringVC.fileLocation = Constants.SAT2ScoringResource
        } else if fileToOpen == "sat-practice-test-2.pdf" {
          let SATTest2VC = segue.destination as! SectionsViewController
          SATTest2VC.fileName = fileToOpen
          SATTest2VC.fileLocation = Constants.SATTest2Resource
        } else if fileToOpen == "sat-practice-test-2-essay.pdf" {
          let SAT2EssayVC = segue.destination as! SectionsViewController
          SAT2EssayVC.fileName = fileToOpen
          SAT2EssayVC.fileLocation = Constants.SAT2EssayResource
        } else if fileToOpen == "sat-practice-test-2-answers.pdf" {
          let SAT2AnswersVC = segue.destination as! SectionsViewController
          SAT2AnswersVC.fileName = fileToOpen
          SAT2AnswersVC.fileLocation = Constants.SAT2AnswersResource
        } else if fileToOpen == "sat-practice-test-3-scoring.pdf" {
          let SAT3ScoringVC = segue.destination as! SectionsViewController
          SAT3ScoringVC.fileName = fileToOpen
          SAT3ScoringVC.fileLocation = Constants.SAT3ScoringResource
        } else if fileToOpen == "sat-practice-test-3.pdf" {
          let SATTest3VC = segue.destination as! SectionsViewController
          SATTest3VC.fileName = fileToOpen
          SATTest3VC.fileLocation = Constants.SATTest3Resource
        } else if fileToOpen == "sat-practice-test-3-essay.pdf" {
          let SAT3EssayVC = segue.destination as! SectionsViewController
          SAT3EssayVC.fileName = fileToOpen
          SAT3EssayVC.fileLocation = Constants.SAT3EssayResource
        } else if fileToOpen == "sat-practice-test-3-answers.pdf" {
          let SAT3AnswersVC = segue.destination as! SectionsViewController
          SAT3AnswersVC.fileName = fileToOpen
          SAT3AnswersVC.fileLocation = Constants.SAT3AnswersResource
        } else if fileToOpen == "" {
          let ProfileVC = segue.destination as! SectionsViewController
            ProfileVC.fileName = fileToOpen
            ProfileVC.fileLocation = ""
        }
    }
    
    //MARK: - TableView Delegate
    //TODO: Perform tasks based on row selected by user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            case 0: loadWebpage(webpage: Constants.studyHabitsResource)
            case 1: fileToOpen = "College-Planner.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 2: fileToOpen = "CollegeVisitWorksheet.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 3: fileToOpen = ""
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 4: loadWebpage(webpage: Constants.howToRaiseGPAResource)
            case 5: fileToOpen = "Preparing-for-the-ACT.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 6: fileToOpen = "Preparing-for-the-SAT.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 7: fileToOpen = "sat-practice-test-1-scoring.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 8: fileToOpen = "sat-practice-test-1.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 9: fileToOpen = "sat-practice-test-1-essay.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 10: fileToOpen = "sat-practice-test-1-answers.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 11: fileToOpen = "sat-practice-answering-sheet.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 12: fileToOpen = "sat-practice-test-2-scoring.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 13: fileToOpen = "sat-practice-test-2.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 14: fileToOpen = "sat-practice-test-2-essay.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 15: fileToOpen = "sat-practice-test-2-answers.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 16: fileToOpen = "sat-practice-test-3-scoring.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 17: fileToOpen = "sat-practice-test-3.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 18: fileToOpen = "sat-practice-test-3-essay.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
            case 19: fileToOpen = "sat-practice-test-3-answers.pdf"
                performSegue(withIdentifier: Constants.fromResourceToSectionSegue, sender: self)
        default: loadWebpage(webpage: Constants.voicedAcademy)
        }
        
        //TODO: on select the row flashes grey and goes back to white
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Searchbar Method
extension ResourcesTableViewController: UISearchBarDelegate {
    
    //TODO: Search Realm for search text
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // input code for fetching data from Realm database based on search condition
        resourcesList = resourcesList?.filter("resourceName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: Constants.FStore.dateCreated, ascending: true)
        tableView.reloadData()
    }
    
    //TODO: Clear search and display resoruce list
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            retrieveResources()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
