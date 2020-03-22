//
//  Resource.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/18/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class Resource: Object {
    
    @objc dynamic var resourceName: String = ""
    @objc dynamic var dateCreated: Date?
    let sections = List<Sections>()
}
