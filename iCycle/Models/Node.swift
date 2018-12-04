//
//  Node.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-27.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class Node {
    var title: String?
    var type: String
    var long: Double
    var lat: Double
    
    init?(long: Double, lat: Double, type: String, title: String?) {
        if let title = title {
            self.title = title
        }
        self.type = type
        self.long = long
        self.lat = lat
    }
}
