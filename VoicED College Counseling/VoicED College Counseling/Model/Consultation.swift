//
//  Consultation.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 1/29/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class Consultation: Object {
    
    @objc dynamic var emailAddress: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var extraCurricular: String = ""
    @objc dynamic var collegeMajor: String = ""
    @objc dynamic var wgpa: String = ""
    @objc dynamic var ugpa: String = ""
    @objc dynamic var schoolRank: String = ""
    @objc dynamic var rank: String = ""
    @objc dynamic var satScore: String = ""
    @objc dynamic var actScore: String = ""
    @objc dynamic var subjectTests: String = ""
    @objc dynamic var targetedCollegeCount: String = ""
    @objc dynamic var stateBound: String = ""
    @objc dynamic var talentOrPassion: String = ""
    @objc dynamic var questions: String = ""
    @objc dynamic var phoneOption: String = ""
    @objc dynamic var zoomOption: String = ""

}
