//
//  MainMapRoutePin.swift
//  iCycle
//
//  Created by Valentyna Akulova on 2018-12-06.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation


class MainMapRoutePin {
    
    var node: Node
    var id: Int
    
    init(node: Node, id: Int) {
       
        self.node = node
        self.id = id
    }
}
