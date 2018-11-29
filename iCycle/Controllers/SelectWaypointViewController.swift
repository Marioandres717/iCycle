//
//  SelectWaypointViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-27.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class SelectWaypointViewController: UIViewController {
    
    var pins: [Node]?
    var pin: Node?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 12.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.backgroundColor = FlatRed()
        saveButton.backgroundColor = FlatGreen()
        
        mapView.delegate = self
        
        updateSaveButtonState()
    }
    
    // MARK: Map Functionality
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D){
        
        // object for turning latitude and logitude into a street address
        let geocoder = GMSGeocoder()
        
        // reverse geocode the coordinates
        geocoder.reverseGeocodeCoordinate(coordinate){
            response, error in
            guard let location = response?.firstResult(), let lines = location.lines else{
                return
            }
            
            // set the label text to the address
            self.locationLabel.text = lines.joined(separator: "\n")
            
            // animate the label change
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    
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

// MARK: GMSMapViewDelegate

extension SelectWaypointViewController: GMSMapViewDelegate {
    
    // reverse geocode location once the map stops moving
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition){
        reverseGeocodeCoordinate(position.target)
    }
}
