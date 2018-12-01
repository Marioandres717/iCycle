//
//  UrlBuilder.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-11-30.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class UrlBuilder {
    
    static let baseURL = "https://marioandres.xyz/v1/"
    
    public static func getUserByUsernameAndPassword() -> String {
        return baseURL + "users/authenticate"
    }
    
    public static func createUser() -> String {
        return baseURL + "users"
    }
}
