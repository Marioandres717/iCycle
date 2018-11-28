//
//  SelectWaypointViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-27.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class SelectWaypointViewController: UIViewController {
    
    var pins: [Node]?
    
    var pin: Node?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.backgroundColor = FlatRed()
        saveButton.backgroundColor = FlatGreen()
        
        updateSaveButtonState()
    }
    
    // MARK: Map Functionality
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "unwindToCreateRoute":
            guard let routeCreateViewController = segue.destination as? RouteCreateViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if let pin = pin {
                routeCreateViewController.pins += [pin]
            }
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
 
    
    // Cancel without adding a pin.
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Enable the save button when all conditions are met.
    func updateSaveButtonState() {
        if pin != nil {
            saveButton.backgroundColor = FlatGreen()
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = FlatGray()
            saveButton.isEnabled = false
        }
    }
}
