//
//  ResourceRealmData.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/18/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class ResourceRealmData: Object {
    
    @objc dynamic var resources: String = ""
    @objc dynamic var sections: String = ""
    @objc dynamic var dateCreated: Date?
}
