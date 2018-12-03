//
//  Http.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-12-01.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class HttpConfig {
    
    static var request = URLRequest(url: URL(string: UrlBuilder.baseURL)!)

    
    static func getRequestConfig(url: String) {
        guard let url = URL(string: url) else {return}
        self.request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    static func postRequestConfig(url: String, parameters: [String: Any]) {
        guard let url = URL(string: url) else {return}
        self.request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
    }
    
    static func putRequestConfig(url: String, parameters: [String: Any]) {
        guard let url = URL(string: url) else {return}
        self.request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
    }
    
    static func sessionConfig() -> URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = nil
        
        return sessionConfig
    }
}
