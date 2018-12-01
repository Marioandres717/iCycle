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
    var user: User
    var id: Int
    
    init(id: Int, title: String, note: String, path: [Node], difficulty: Int, voted: Bool, upVotes: Int, downVotes: Int, privateRoute: Bool, user: User, saved: Bool) {
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
        self.id = id
    }
    
    init?(json: [String: Any]) {
        self.title = json["title"] as? String ?? ""
        self.note = json["note"] as? String ?? ""
        self.difficulty = json["difficulty"] as? Int ?? 1
        self.voted = json["title"] as? Bool ?? false
        self.upVotes = json["upVotes"] as? Int ?? 0
        self.downVotes = json["downVotes"] as? Int ?? 0
        self.score = upVotes - downVotes
        self.privateRoute = json["private"] as? Bool ?? false
        self.saved = false
        self.id = json["id"] as? Int ?? -1
        
        
        let u = json["user"] as? [String: Any] ?? nil
        self.user = User(json: u!)!
    
        self.path = []
        let pathCoordinates = json["coordinates"] as? [String] ?? nil
        for coordinate in pathCoordinates! {
            let stringWithLongAndLat = coordinate.components(separatedBy: ",")
            let stringWithLong = stringWithLongAndLat[0].components(separatedBy: ": ")[1]
            let stringWithLat = stringWithLongAndLat[1].components(separatedBy: ": ")[1].dropLast()
            self.path.append(Node(long: Double(stringWithLong)!, lat: Double(stringWithLat)!)!)
            
        }
    }
}
