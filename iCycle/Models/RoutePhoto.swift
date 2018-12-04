//
//  RoutePhoto.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-12-03.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation
import GoogleMaps

class RoutePhoto {
    var photo: String
    var long: Double
    var lat: Double
    var user: User
    var caption: String?
    var title: String
    
    init(photo: String, long: Double, lat: Double, user: User, title: String, caption: String?) {
        self.photo = photo
        self.long = long
        self.lat = lat
        self.user = user
        self.title = title
        self.caption = caption
    }
}
