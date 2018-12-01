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
import Alamofire
import SwiftyJSON
import os.log

class SelectWaypointViewController: UIViewController {
    var pin: Node?
    
    var markers: [GMSMarker]?
    var marker: GMSMarker?
    var newestRoute: GMSPolyline?
    var routePoints: [String]?
    
    let path = GMSMutablePath()
    
    var pickerData: [String] = [String]()
    
    @IBOutlet weak var pinTypePicker: UIPickerView!
    @IBOutlet weak var pinTitle: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchLocationBar: UISearchBar!
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 12.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize Buttons
        cancelButton.backgroundColor = FlatRed()
        saveButton.backgroundColor = FlatGreen()
        
        // Set Delegates
        mapView.delegate = self
        pinTypePicker.delegate = self
        pinTitle.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        // Fill the Picker
        pinTypePicker.dataSource = self
        
        // Input the data into the array
        pickerData = ["Route", "Bike Shop", "Store", "Point of Interest", "Hazard"]
        
        // Update The Map
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
    
    private func drawRouteBetweenTwoLastPins (sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion : @escaping ()->()) {
    
        let source: String = "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)"
        let destination: String = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        
        //let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(source)&destinations=\(destination)&key=AIzaSyBUJZaFSeeEgoJktJao7Fh3V02MsHMY2cI"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&mode=driving&key=AIzaSyBUJZaFSeeEgoJktJao7Fh3V02MsHMY2cI"

        
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    if let points = routeOverviewPolyline?["points"]?.stringValue{
                        
                        self.routePoints! += [points]
                    } else {
                        print ("ERROR: routePoints is nil")
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
            
            completion()
        }
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
                    routeCreateViewController.pins.append(pin)
                }
                
                if let routePoints = routePoints {
                    routeCreateViewController.routePoints = routePoints
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
        
        if (markers!.count > 1) {
            for route in routePoints! {
                let path = GMSPath.init(fromEncodedPath: route)
                let polyline = GMSPolyline.init(path: path)
                polyline.map = self.mapView
            }
        }
    }
}

// MARK: GMSMapViewDelegate

extension SelectWaypointViewController: GMSMapViewDelegate {
    
    // reverse geocode location at a tap location
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if marker != nil {
            marker!.map = nil // Clear the previously placed pin
            newestRoute!.map = nil
            routePoints!.popLast()
            pin = nil;
        }
        
        marker = GMSMarker(position: coordinate)
        marker!.appearAnimation = GMSMarkerAnimation.pop
        marker!.title = "New Waypoint"
        marker!.map = mapView
        
        
        if let markers = markers {
            if(markers.count > 0) {
                
                drawRouteBetweenTwoLastPins(sourceCoordinate: CLLocationCoordinate2D(latitude: markers[markers.count-1].position.latitude, longitude: markers[markers.count-1].position.longitude), destinationCoordinate: coordinate, completion: {
                    print ("routePoints: \(self.routePoints)")
                    
                    let path = GMSPath.init(fromEncodedPath: self.routePoints![self.routePoints!.count - 1])
                    self.newestRoute = GMSPolyline.init(path: path)
                    self.newestRoute!.map = self.mapView
                })
            }
        }
        

        path.add(coordinate);
        
        pin = Node(long: coordinate.longitude, lat: coordinate.latitude, type: pickerData[pinTypePicker.selectedRow(inComponent: 1)], title: pinTitle.text ?? "")!
        
        updateSaveButtonState()
        
        reverseGeocodeCoordinate(coordinate)
    }
}

// MARK: UISearchBarDelegate
extension SelectWaypointViewController: UISearchBarDelegate {
    
}

// MARK: UITextFieldDelegate
extension SelectWaypointViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide Keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: UIPickerViewDelegate
extension SelectWaypointViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(pickerData[row])
    }
}

// MARK: UIPickerViewDataSource
extension SelectWaypointViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
}


extension SelectWaypointViewController: CLLocationManagerDelegate {
    
    // called when user grants or revokes location permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status == .denied{
            mapView.camera = GMSCameraPosition.camera(withLatitude: 50, longitude:-100, zoom: 3) //North America
        }
        guard status == .authorizedWhenInUse else {
            return
        }
        
        // once permission is granted, start updating the location
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true //ligth blue dot on the map will appear
        mapView.settings.myLocationButton = true //button, when tapped, shows user's current location
    }
    
    // called when location manager receives new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        
        // update map to center around the user's location
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        
        // no longer need updates, stop updating
        locationManager.stopUpdatingLocation()
    }
}
