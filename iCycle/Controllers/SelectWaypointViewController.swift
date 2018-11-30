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
import os.log

class SelectWaypointViewController: UIViewController {
    var pin: Node?
    
    var markers: [GMSMarker]?
    var marker: GMSMarker?
    
    let path = GMSMutablePath()
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchLocationBar: UISearchBar!
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 12.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.backgroundColor = FlatRed()
        saveButton.backgroundColor = FlatGreen()
        
        mapView.delegate = self
        
        if let markers = markers {
            if(markers.count > 0) {
                updateMapPins()
            }
        }
        
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
            self.searchLocationBar.text = lines.joined(separator: "\n")
            
            // animate the label change
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let routeCreateViewController = segue.destination as? RouteCreateViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        if let pin = pin {
            routeCreateViewController.pins += [pin]
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
    
    func updateMapPins() {
        for marker in markers! {
            marker.appearAnimation = GMSMarkerAnimation.pop
            marker.map = mapView
        }
    }
}

// MARK: GMSMapViewDelegate

extension SelectWaypointViewController: GMSMapViewDelegate {
    
    // reverse geocode location once the map stops moving
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if marker != nil {
            marker!.map = nil // Clear the previously placed pin
            pin = nil;
        }
        
        marker = GMSMarker(position: coordinate)
        marker!.appearAnimation = GMSMarkerAnimation.pop
        marker!.title = "New Waypoint"
        marker!.map = mapView
        
        path.add(coordinate);
        //if (path.length(of: <#T##GMSLengthKind#>))
        
        pin = Node(long: coordinate.longitude, lat: coordinate.latitude)
        
        updateSaveButtonState()
        
        reverseGeocodeCoordinate(coordinate)
    }
}
