//
//  Sections.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/18/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class Sections: Object {
    
    @objc dynamic var sectionName: String = ""
    @objc dynamic var dateCreated: Date?
    var parentResource = LinkingObjects(fromType: Resource.self, property: "sections")
}
