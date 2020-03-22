//
//  ProfileRealmData.swift
//  VoicED College Counseling
//
//  Created by Arun Narayanan on 2/26/20.
//  Copyright © 2020 Arun Narayanan. All rights reserved.
//

import Foundation
import RealmSwift

class ProfileRealmData: Object {
    
    @objc dynamic var profileName: String = ""
    @objc dynamic var productID: String = ""
    @objc dynamic var additionalInfo: String = ""
    @objc dynamic var purchased: Bool = false
    @objc dynamic var webLink: String = ""
    @objc dynamic var dateCreated: Date?
}
