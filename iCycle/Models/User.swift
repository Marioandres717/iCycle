//
//  User.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-30.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

struct PropertyKeyUser {
    static let userName = "userName"
    static let id = "id"
}

class User: NSObject, NSCoding {
    var id: Int
    var userName: String
    var bikeSerialNumber: String?
    var bikeBrand: String?
    var bikeNotes: String?
    var bikeImage: UIImage?
    
    static let DocumentsDir = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDir.appendingPathComponent("user")
    
//    init(id: Int, userName: String, bikeSerialNumber: String?, bikeBrand: String?, bikeNotes: String?, bikeImage: UIImage?) {
//        self.id = id
//        self.userName = userName
//        self.bikeSerialNumber = bikeSerialNumber
//        self.bikeBrand = bikeBrand
//        self.bikeNotes = bikeNotes
//        self.bikeImage = bikeImage
//    }
    
    init(id: Int, userName: String) {
        self.id = id
        self.userName = userName
    }
    
    init?(json: [String: Any]) {
        self.userName = json["username"] as? String ?? ""
        self.id = json["id"] as? Int ?? -1
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let userName = aDecoder.decodeObject(forKey: PropertyKeyUser.userName) as? String else {
            return nil
        }
        
        let id = aDecoder.decodeInteger(forKey: PropertyKeyUser.id)
        self.init(id: id, userName: userName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userName, forKey: PropertyKeyUser.userName)
        aCoder.encode(id, forKey: PropertyKeyUser.id)
    }
    
    static func loadUser() -> User? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User
    }
    
    static func saveUser(user: User) -> Bool {
        let isSucessfulSave = NSKeyedArchiver.archiveRootObject(user, toFile: User.ArchiveURL.path)
        if isSucessfulSave {
            return true
        } else {
            return false
        }
    }
}
