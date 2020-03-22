//
//  Quiz.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 2/15/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import Foundation

class Quiz {
    
    let chapter : String
    let description : String
    let question : String
    let answer : Int
    let button1 : String
    let button2 : String
    let button3 : String
    let button4 : String
    
    init(chapterText : String, descriptionText : String, questionText : String, correctAnswer : Int, button1Label : String, button2Label : String, button3Label : String, button4Label : String) {
        chapter = chapterText
        description = descriptionText
        question = questionText
        answer = correctAnswer
        button1 = button1Label
        button2 = button2Label
        button3 = button3Label
        button4 = button4Label
    }
}
