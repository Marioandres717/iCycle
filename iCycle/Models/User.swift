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
    static let bikeSerialNumber = "bikeSerialNumber"
    static let bikeBrand = "bikeBrand"
    static let bikeNotes = "bikeNotes"
    static let bikeImage = "bikeImage"
}

class User: NSObject, NSCoding {
    var id: Int
    var userName: String
    var bikeSerialNumber: String
    var bikeBrand: String
    var bikeNotes: String
    var bikeImage: UIImage
    
    static let DocumentsDir = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDir.appendingPathComponent("user")
    
    init(id: Int, userName: String, bikeSerialNumber: String, bikeBrand: String, bikeNotes: String, bikeImage: UIImage) {
        self.id = id
        self.userName = userName
        self.bikeSerialNumber = bikeSerialNumber
        self.bikeBrand = bikeBrand
        self.bikeNotes = bikeNotes
        self.bikeImage = bikeImage
    }
    
    init?(json: [String: Any]) {
        self.userName = json["username"] as? String ?? ""
        self.id = json["id"] as? Int ?? -1
        self.bikeSerialNumber = json["bikeSerialNumber"] as? String ?? ""
        self.bikeBrand = json["bikeBrand"] as? String ?? ""
        self.bikeNotes = json["bikeNotes"] as? String ?? ""
        self.bikeImage = json["bikeImage"] as? UIImage ?? UIImage(named: "placeholder")!
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let userName = aDecoder.decodeObject(forKey: PropertyKeyUser.userName) as? String else {
            return nil
        }
        
        let id = aDecoder.decodeInteger(forKey: PropertyKeyUser.id)
        
        guard let bikeSerialNumber = aDecoder.decodeObject(forKey: PropertyKeyUser.bikeSerialNumber) as? String else {
            return nil
        }
        
        guard let bikeBrand = aDecoder.decodeObject(forKey: PropertyKeyUser.bikeBrand) as? String else {
            return nil
        }
        
        guard let bikeNotes = aDecoder.decodeObject(forKey: PropertyKeyUser.bikeBrand) as? String else {
            return nil
        }
        
        guard let bikeImage = aDecoder.decodeObject(forKey: PropertyKeyUser.bikeImage) as? UIImage else {
            return nil
        }
        
        self.init(id: id, userName: userName, bikeSerialNumber: bikeSerialNumber, bikeBrand: bikeBrand, bikeNotes: bikeNotes, bikeImage: bikeImage)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userName, forKey: PropertyKeyUser.userName)
        aCoder.encode(id, forKey: PropertyKeyUser.id)
        aCoder.encode(bikeSerialNumber, forKey: PropertyKeyUser.bikeSerialNumber)
        aCoder.encode(bikeBrand, forKey: PropertyKeyUser.bikeBrand)
        aCoder.encode(bikeNotes, forKey: PropertyKeyUser.bikeNotes)
        aCoder.encode(bikeImage, forKey: PropertyKeyUser.bikeImage)
    }
    
    static func loadUser() -> User? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User
    }
    
    static func saveUser(user: User) -> Bool {
        let isSucessfulSave = NSKeyedArchiver.archiveRootObject(user, toFile: User.ArchiveURL.path)
        if isSucessfulSave {
//            let u = loadUser()!
//            print("UUUUU \(u)")
            return true
        } else {
            return false
        }
    }
}
