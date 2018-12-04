//
//  RoutePhoto.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-12-03.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation
import GoogleMaps
import Firebase

class RoutePhoto {
    var photoUrl: String
    var photoImage: UIImage
    var long: Double
    var lat: Double
    var user: User
    var caption: String?
    var title: String
    
    init(photoUrl: String, long: Double, lat: Double, user: User, title: String, caption: String?) {
        self.photoUrl = photoUrl
        self.long = long
        self.lat = lat
        self.user = user
        self.title = title
        self.caption = caption
        self.photoImage = UIImage(named: "placeholder")!
        
        let urlToImage = self.photoUrl
        if urlToImage != "" {
            let storageRef = Storage.storage().reference(forURL: urlToImage)
            let maxSize: Int64 = 3 * 1024 * 1024 // 3MB
            storageRef.getData(maxSize: maxSize) { (data, error) in
                if let error = error {
                    print(error)
                    self.photoImage = UIImage(named: "placeholder")!
                } else {
                    print("Sucessfully fetched image")
                    self.photoImage = UIImage(data: data!)!
                }
            }
        } else {
            self.photoImage = UIImage(named: "placeholder")!
        }
    }
}
