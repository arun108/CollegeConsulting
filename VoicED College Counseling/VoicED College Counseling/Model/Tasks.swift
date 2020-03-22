//
//  Tasks.swift
//  Grammar Assessment
//
//  Created by Arun Narayanan on 12/30/19.
//  Copyright © 2019 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class Tasks: Object {
    
    @objc dynamic var taskName: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Planner.self, property: "tasks")
}
