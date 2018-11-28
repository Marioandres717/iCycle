//
//  Route.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-12.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation
import UIKit

class Route {
    //MARK: Properties
    var title: String

    var note: String
    var path: [Node]
    
    var difficulty: Int
    
    var voted: Bool
    var upVotes: Int
    var downVotes: Int
    var score: Int
    
    var privateRoute: Bool
    var saved: Bool
    var user: String
    
    init(title: String, note: String, path: [Node], difficulty: Int, voted: Bool, upVotes: Int, downVotes: Int, privateRoute: Bool, user: String, saved: Bool){
        self.title = title
        self.note = note
        self.path = path
        self.difficulty = difficulty
        self.voted = voted
        self.upVotes = upVotes
        self.downVotes = downVotes
        self.score = upVotes - downVotes
        self.privateRoute = privateRoute
        self.saved = saved
        self.user = user
    }
}
