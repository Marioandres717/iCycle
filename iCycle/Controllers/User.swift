//
//  User.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-11-20.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class User {
    
    // MARK: Properties
    var id: Int
    var email: String
    var username: String
    
    init(id: Int, email: String, username: String) {
        self.id = id
        self.email = email
        self.username = username
    }
}
