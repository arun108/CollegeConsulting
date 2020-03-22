//
//  PopUpViewController.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/29/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = popUpView.frame.size.height / 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.showAnimate()
    }
    
    //TODO: Function to animate the display of information when user touches on the info button
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    //TODO: Function to animate the disappearing of information when user touches on the Close X button
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (finished) in
            if finished {
                self.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //MARK: - Buttons
    //TODO: Close button
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.removeAnimate()
    }
    

}
