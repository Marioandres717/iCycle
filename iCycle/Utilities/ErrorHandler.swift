//
//  ErrorHandler.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-11-30.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import Foundation

class ErrorHandler {

    public static func handleError(title: String, message: String) -> UIAlertController {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            return alertController
    }
}
