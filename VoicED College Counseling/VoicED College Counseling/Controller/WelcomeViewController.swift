//
//  WelcomeViewController.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/28/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var voicedIcon: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        registerButton.layer.cornerRadius = registerButton.frame.size.height / 5
        loginButton.layer.cornerRadius = loginButton.frame.size.height / 5
        
        moveVoicedIcon()
    }
    
    //TODO: Define navigationbar color and layout when returning back from menu items
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.red
    }
    
    //TODO: Animation on the welcome screen
    func moveVoicedIcon() {
        UIView.animate(withDuration: 5.0, delay: 2.0, options: .curveEaseOut, animations: {
            let voicedIconTransform = self.voicedIcon.transform
            let scaledTransform = voicedIconTransform.scaledBy(x: 0.625, y: 0.625)
            let scaledAndTranslatedTransform = scaledTransform.translatedBy(
                x: -(self.view.frame.width/2 - self.view.frame.width/2),
                y: -(self.view.frame.height/2))
            UIView.animate(withDuration: 0.7, animations: {
                self.voicedIcon.transform = scaledAndTranslatedTransform
            })
        }, completion: {finished in})
    }

}
