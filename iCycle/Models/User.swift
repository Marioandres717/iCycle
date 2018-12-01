//
//  User.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-30.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class User {
    var id: Int
    var userName: String
    var bikeSerialNumber: String?
    var bikeBrand: String?
    var bikeNotes: String?
    var bikeImage: UIImage?
    
    init(id: Int, userName: String, bikeSerialNumber: String?, bikeBrand: String?, bikeNotes: String?, bikeImage: UIImage?) {
        self.id = id
        self.userName = userName
        self.bikeSerialNumber = bikeSerialNumber
        self.bikeBrand = bikeBrand
        self.bikeNotes = bikeNotes
        self.bikeImage = bikeImage
    }
}
