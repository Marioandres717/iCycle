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
    var title: String // Title of the route

    var note: String // Notes left by the creator of the route
    var routePins: [Node] // The path, as defined by the creator
    var pointPins: [Node] // Points of interest
    
    var difficulty: Int // Defined by the creator
    
    var voted: Bool? // If the user that is viewing the route has voted or not, this will be set when retriving the route
    
    var upVotes: Int // The number of upvotes a route has
    var downVotes: Int // The number of downVotes a route has
    var score: Int // The total score, upVotes - downVotes
    
    var privateRoute: Bool // If the route is private, defined by creator
    var user: User // The creator of the route
    var id: Int // The id of the route on the server
    
    var distance: Double
    
    init(id: Int, title: String, note: String, routePins: [Node], difficulty: Int, distance: Double, upVotes: Int, downVotes: Int, privateRoute: Bool, user: User, pointPins: [Node], voted: Bool?) {
        self.title = title
        self.note = note
        self.routePins = routePins
        self.difficulty = difficulty
        self.voted = voted
        self.upVotes = upVotes
        self.downVotes = downVotes
        self.score = upVotes - downVotes
        self.privateRoute = privateRoute
        self.user = user
        self.id = id
        self.pointPins = pointPins
        self.distance = distance
    }

}
