//
//  PlannerRealmData.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 1/19/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class PlannerRealmData: Object {
    
    @objc dynamic var categories: String = ""
    @objc dynamic var tasks: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
}


