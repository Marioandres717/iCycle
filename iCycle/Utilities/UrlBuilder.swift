//
//  UrlBuilder.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-11-30.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class UrlBuilder {
    
    static let baseURL = "https://marioandres.xyz/v1/"
    
    public static func getUserByUsernameAndPassword() -> String {
        return baseURL + "users/authenticate"
    }
    
    public static func createUser() -> String {
        return baseURL + "users"
    }
    
    public static func createRoute() -> String {
        return baseURL + "routes"
    }
    
    public static func getAllRoutes() -> String {
        return baseURL + "routes"
    }
    
    public static func getAllRoutePhotos(routeId: Int) -> String {
        return baseURL + "routes/\(routeId)/photo"
    }

    public static func addPhotoToRoute(routeId: Int, userId: Int) -> String {
        return baseURL + "routes/\(routeId)/user/\(userId)/photo"
    }
    
    public static func getAllUserPhotos(userId: Int) -> String {
        return baseURL + "user/\(userId)/photo"
    }
    
    public static func getMyRoutes(userId: Int) -> String {
        return baseURL + "routes/user/\(userId)"
    }
    
    public static func getSavedRoutes(userId: Int) -> String {
        return baseURL + "routes/user/\(userId)/saved"
    }
    
    public static func editUser(id: Int) -> String {
        return baseURL + "users/\(id)"
    }
    
    public static func saveRoute(id: Int, userId: Int) -> String {
        return baseURL + "routes/\(id)/user/\(userId)/save"
    }
    
    public static func hasVoted(id: Int, userId: Int) -> String {
        return baseURL + "routes/\(id)/user/\(userId)/hasVoted"
    }
    
    public static func hasSaved(id: Int, userId: Int) -> String {
        return baseURL + "routes/\(id)/user/\(userId)/hasSaved"
    }
    
    public static func upVoteRoute(id: Int, userId: Int) -> String {
        return baseURL + "routes/\(id)/upVote/\(userId)"
    }
    
    public static func downVoteRoute(id: Int, userId: Int) -> String {
        return baseURL + "routes/\(id)/downVote/\(userId)"
    }
}
