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

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}

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
    
    private func drawRouteBetweenTwoLastPins (sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        /*
        let rectangle = GMSPolyline(path: path)
        
        rectangle.strokeWidth = 2.0
        if (path.count() > 1){
            rectangle.map = mapView
        }*/
        let source: String = "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)"
        let destination: String = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(source)&destinations=\(destination)&key=AIzaSyCrX4BFXbvFAvct8Q1xp1ml6yW8rhdNs6A"
        /*
        Alamofire.request(urlString).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.map = self.mapView
            }
        }*/
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier) {
            case "cancelWaypoint":
            break
            case "saveWaypoint":
                guard let routeCreateViewController = segue.destination as? RouteCreateViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                if let pin = pin {
                    routeCreateViewController.pins += [pin]
                }
            break
            default:
                fatalError("Unexpected segue: \(segue.identifier)")
            break
        }
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
    
    // reverse geocode location at a tap location
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
        
        
        pin = Node(long: coordinate.longitude, lat: coordinate.latitude)
        
        updateSaveButtonState()
        
        reverseGeocodeCoordinate(coordinate)
    }
}
