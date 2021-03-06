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
    // MARK: Attributes
    var pin: Node? // The new pin
    
    var routeMarkers: [GMSMarker]? // Marker to signify the route
    var pointMarkers: [GMSMarker]? // Marker to signify special points on the route
    
    var marker: GMSMarker? // The currently selected marker
    var newestRoute: GMSPolyline? // The newest path between two markers
    var routePoints: [String]? // The entire path
    var routeDistance: [Double] = []
    
    let path = GMSMutablePath()
    
    var pickerData: [String] = [String]()
    
    @IBOutlet weak var pinTypePicker: UIPickerView!
    @IBOutlet weak var pinTitle: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchLocationBar: UISearchBar!
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Delegates
        mapView.delegate = self
        pinTypePicker.delegate = self
        pinTitle.delegate = self
        locationManager.delegate = self
        
        // Location Management
        locationManager.requestWhenInUseAuthorization()
        
        // Customize the Screen
        initChameleonColors()
        
        // Fill the Picker
        pinTypePicker.dataSource = self
        
        // The different types of pins
        pickerData = ["Route", "Bike Shop", "Store", "Point of Interest", "Hazard"]
        
        // Update The Map with the previously placed pins
        if let routeMarkers = routeMarkers {
            if routeMarkers.count > 0 {
                updateRoutePins()
            }
        }
        
        if let pointMarkers = pointMarkers {
            if pointMarkers.count > 0 {
                updatePointPins()
            }
        }
        
        // Update the ability to save (default off)
        updateSaveButtonState()
    }
    
    // MARK: Customize the Screen
    private func initChameleonColors() {
        cancelButton.backgroundColor = FlatRed()
        saveButton.backgroundColor = FlatGreen()
    }
    
    // MARK: Custom Methods
    
    // Get the address of the pins
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
            
            // animate the text change
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Get the actual path between the last pin that was placed and the new one to be added
    private func drawRouteBetweenTwoLastPins (sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion : @escaping ()->()) {
    
        let source: String = "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)"
        let destination: String = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&mode=bicycling&key=AIzaSyBUJZaFSeeEgoJktJao7Fh3V02MsHMY2cI"

        
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                print("json \(json)")
                
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    if let points = routeOverviewPolyline?["points"]?.stringValue{
                        
                        self.routePoints! += [points]
                    } else {
                        print ("ERROR: routePoints is nil")
                    }
                    
                    let legs = route["legs"].arrayValue
                    for leg in legs {
                        let distance = leg["distance"].dictionary
                        if let value = distance?["value"]?.doubleValue{
                            self.routeDistance.append(value)
                        } else{
                            print ("ERROR: distance value is nil")
                        }
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
            
            completion()
        }
    }
    
    // Enable the save button when all conditions are met.
    func updateSaveButtonState() {
        if marker != nil {
            saveButton.backgroundColor = FlatGreen()
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = FlatGray()
            saveButton.isEnabled = false
        }
    }
    
    func updateRoutePins() {
        for routeMarker in routeMarkers! {
            routeMarker.appearAnimation = GMSMarkerAnimation.pop
            routeMarker.icon = UIImage(named: "routePin")
            routeMarker.map = mapView
        }
        
        if (routeMarkers!.count > 1) {
            for route in routePoints! {
                let path = GMSPath.init(fromEncodedPath: route)
                let polyline = GMSPolyline.init(path: path)
                polyline.spans = [GMSStyleSpan(color: .red)]
                polyline.strokeWidth = 3.0
                polyline.map = self.mapView
            }
        }
    }
    
    func updatePointPins() {
        for pointMarker in pointMarkers! {
            pointMarker.appearAnimation = GMSMarkerAnimation.pop
            pointMarker.map = mapView
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier) {
            case "cancelWaypoint":
            break
            case "saveWaypoint":
                guard let routeCreateViewController = segue.destination as? RouteCreateViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                pin = Node(long: marker!.position.longitude, lat: marker!.position.latitude, type: pickerData[pinTypePicker.selectedRow(inComponent: 0)], title: pinTitle.text ?? "")!
                
                if let pin = pin {
                    switch (pickerData[pinTypePicker.selectedRow(inComponent: 0)]) {
                    case "Route":
                        routeCreateViewController.routePins.append(pin)
                        break
                    default:
                        routeCreateViewController.pointPins.append(pin)
                        break;
                    }
                }
                
                if let routePoints = routePoints {
                    routeCreateViewController.routePoints = routePoints
                }
                routeCreateViewController.routeDistance = routeDistance

            break
            default:
                fatalError("Unexpected segue: \(segue.identifier)")
            break
        }
    }
}

// MARK: GMSMapViewDelegate
extension SelectWaypointViewController: GMSMapViewDelegate {
    
    // User Placed a Marker
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if marker != nil { // If a marker has been previously placed
            marker!.map = nil // Clear the previously placed pin
            if newestRoute != nil {
                newestRoute!.map = nil
                routePoints!.popLast()
                routeDistance.popLast()
            }
        }
        
        switch (pickerData[pinTypePicker.selectedRow(inComponent: 0)]) {
        case "Route":
            // Create a new marker using the tapped position.
            marker = GMSMarker(position: coordinate)
            marker!.appearAnimation = GMSMarkerAnimation.pop
            marker!.map = mapView
            marker!.title = pinTitle.text ?? ""
            marker!.icon = UIImage(named: "routePin")

            // If there are more than one route pin, draw the route between them
            if let routeMarkers = routeMarkers {
                if(routeMarkers.count > 1) {
                    drawRouteBetweenTwoLastPins(sourceCoordinate: CLLocationCoordinate2D(latitude: routeMarkers[routeMarkers.count-1].position.latitude, longitude: routeMarkers[routeMarkers.count-1].position.longitude), destinationCoordinate: coordinate, completion: {
                        
                        let path = GMSPath.init(fromEncodedPath: self.routePoints![self.routePoints!.count - 1])
                        self.newestRoute = GMSPolyline.init(path: path)
                        self.newestRoute!.spans = [GMSStyleSpan(color: .red)]
                        self.newestRoute!.strokeWidth = 3.0
                        self.newestRoute!.map = self.mapView
                    })
                }
            }
            
            path.add(coordinate);
            break;
        
        default:
            marker = GMSMarker(position: coordinate)
            marker!.appearAnimation = GMSMarkerAnimation.pop
            marker!.map = mapView
            marker!.title = pinTitle.text ?? ""
            switch (pickerData[pinTypePicker.selectedRow(inComponent: 0)]){
            case "Bike Shop":
                marker!.icon = UIImage(named: "bikeShop")
                break
            case "Store":
                marker!.icon = UIImage(named: "store")
                break
            case "Point of Interest":
                marker!.icon = UIImage(named: "pointOfInterest")
                break
            case "Hazard":
                marker!.icon = UIImage(named: "hazard")
                break
            default:
                marker!.icon = GMSMarker.markerImage(with: .black)
            }
            break
        }
        
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
        if marker != nil { // If a marker has been previously placed
            marker!.map = nil // Clear the previously placed pin
            if newestRoute != nil {
                newestRoute!.map = nil
                routePoints!.popLast()
                routeDistance.popLast()
                path.removeLastCoordinate()
            }
        }
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

// MARK: CLLocationManagerDelegate
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
        
        if routeMarkers!.count > 0 {
            mapView.camera = GMSCameraPosition(target: routeMarkers![routeMarkers!.count-1].position , zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        }
        else {
            // update map to center around the user's location
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        }
        
        // no longer need updates, stop updating
        locationManager.stopUpdatingLocation()
    }
}
