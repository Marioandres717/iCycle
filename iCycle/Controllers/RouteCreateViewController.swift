//
//  RouteCreateViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-09.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import os.log

class RouteCreateViewController: UIViewController {
    var pins: [Node] = []
    
    var markers: [GMSMarker] = []
    
    @IBOutlet weak var routeTitle: UITextField!
    @IBOutlet weak var routeDifficulty: UISegmentedControl!
    @IBOutlet weak var routeNotes: UITextView!
    @IBOutlet weak var routeIsPrivate: UISwitch!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let apiPath = "marioandres.xyz/v1/routes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "saveRoute": // Saving and returning to the list of Routes
            print(segue.identifier)
            guard let routeTableViewController = segue.destination as? RouteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let title = routeTitle.text ?? ""
            let difficulty = routeDifficulty.selectedSegmentIndex + 1
            let notes = routeNotes.text ?? ""
            let privacy = routeIsPrivate.isOn
            
            let route = Route(title: title, note: notes, path: pins, difficulty: difficulty, voted: false, upVotes: 0, downVotes: 0, privateRoute: privacy, user: "TEMP_USER", saved: false)
            
            // SEND ROUTE TO BACKEND-------
            
            let parameters = ["title": route.title, "note": route.note, "path": route.path, "difficulty": route.difficulty, "privateRoute": route.privateRoute, "user": "1"] as [String : Any]
            
            guard let url = URL(string: apiPath) else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                
                if let data = data {
                    print(data)
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                    }
                }
                }.resume()
            
            
            //-----------------------------
            break
        case "addWaypoint":
            guard let selectWaypointViewController = segue.destination as? SelectWaypointViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            selectWaypointViewController.markers = markers
            break
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
 
    // Execute when returning from adding a pin.
    @IBAction func unwindToCreateRoute(segue:UIStoryboardSegue) {
        if let selectWaypointViewController = segue.source as? SelectWaypointViewController {
            updateMapPins()
            updateSaveState()
        }
    }
    
    // Update the save button when all conditions are met.
    func updateSaveState() {
        if pins.count < 2 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    func updateMapPins() {
        let newPin = pins[pins.count - 1]
        let position = CLLocationCoordinate2D(latitude: newPin.lat, longitude: newPin.long)
        let newMarker = GMSMarker(position: position)
        markers += [newMarker]
        
        for marker in markers {
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.map = mapView
        }
    }
}

// MARK: GMSMapViewDelegate

extension RouteCreateViewController: GMSMapViewDelegate {
    
}
