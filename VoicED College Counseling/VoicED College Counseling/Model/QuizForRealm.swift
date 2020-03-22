//
//  QuizForRealm.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 1/31/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class QuizForRealm: Object {
    
    @objc dynamic var chapter : String = ""
    @objc dynamic var quizDescription : String = ""
    @objc dynamic var question : String = ""
    @objc dynamic var answer : Int = 0
    @objc dynamic var chosenAnswer : Int = 0
    @objc dynamic var button1 : String = ""
    @objc dynamic var button2 : String = ""
    @objc dynamic var button3 : String = ""
    @objc dynamic var button4 : String = ""
    
}
