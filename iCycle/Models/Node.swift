//
//  Node.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-27.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class Node: Codable {
    var long: Double
    var lat: Double
    
    init?(long: Double, lat: Double) {
        self.long = long
        self.lat = lat
    }
}
