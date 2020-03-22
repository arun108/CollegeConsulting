//
//  Planner.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 12/30/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class Planner: Object {
    
    @objc dynamic var plannerName: String = ""
    @objc dynamic var dateCreated: Date?
//    @objc dynamic var rowColor: String = ""
    let tasks = List<Tasks>()
}
