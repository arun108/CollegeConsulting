//
//  ModuleRealmData.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/19/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class ModuleRealmData: Object {
    
    @objc dynamic var moduleName: String = ""
    @objc dynamic var dateCreated: Date?
}
