//
//  RouteCreateViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-09.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import os.log

class RouteCreateViewController: UIViewController, URLSessionDelegate, URLSessionDataDelegate {
    // MARK: Attributes
    // For saving in the Route
    var routePins: [Node] = []
    var pointPins: [Node] = []
    
    // For Display on the Map
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routePoints: [String] = []
    var routeDistance: [Double] = []
    
    var session: URLSession?
    var user: User?
    
    var route: Route?
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    @IBOutlet weak var routeTitle: UITextField!
    @IBOutlet weak var routeDifficulty: UISegmentedControl!
    @IBOutlet weak var routeNotes: UITextView!
    @IBOutlet weak var routeIsPrivate: UISwitch!
    @IBOutlet weak var distanceTextLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Delegates
        routeTitle.delegate = self
        routeNotes.delegate = self
        locationManager.delegate = self
        
        // Location Management
        locationManager.requestWhenInUseAuthorization()
        
        // Listen for Keyboard Events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // Stop Listening for Keyboard Events
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "saveRoute": // Saving and returning to the list of Routes
            print(segue.identifier)
            guard let routeTableViewController = segue.destination as? RouteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            routeTableViewController.routes = []
            routeTableViewController.tableView.reloadData()
            // SEND ROUTE TO BACKEND-------
            saveRoute(completion: {
                print("Created route \(self.route!.title)")
            })
            //-----------------------------
            break
        case "addWaypoint":
            guard let selectWaypointViewController = segue.destination as? SelectWaypointViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            selectWaypointViewController.routeMarkers = routeMarkers
            selectWaypointViewController.pointMarkers = pointMarkers
            selectWaypointViewController.routePoints = routePoints
            selectWaypointViewController.routeDistance = routeDistance
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
            updateDistance()
        }
    }
    
    // MARK: Custom Methods
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Send the route to the server
    func saveRoute (completion : @escaping ()->()) {
        let urlString = UrlBuilder.createRoute()
        
        let title = routeTitle.text ?? ""
        let difficulty = routeDifficulty.selectedSegmentIndex + 1
        let notes = routeNotes.text ?? ""
        let privacy = routeIsPrivate.isOn
        let totalDistance = routeDistance.reduce(0, +)
        self.user = User.loadUser()
        
        var parameters : [String: Any] = [
            "title": title,
            "note": notes,
            "routePins": [],
            "pointPins": [],
            "distance": totalDistance,
            "difficulty": difficulty,
            "private": privacy,
            "userId": user?.id ?? -1
        ]
        
        for i in 0...(routePins.count - 1) {
            parameters["routePins"] = (parameters["routePins"] as? [[String: Any]] ?? []) + [["long": routePins[i].long, "lat": routePins[i].lat, "type": routePins[i].type, "title": routePins[i].title ?? ""]]
        }
        
        if (pointPins.count > 0) {
            for i in 0...(pointPins.count - 1) {
                parameters["pointPins"] = (parameters["pointPins"] as? [[String: Any]] ?? []) + [["long": pointPins[i].long, "lat": pointPins[i].lat, "type": pointPins[i].type, "title": pointPins[i].title ?? ""]]
            }
        }
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success(let result):
                let res = JSON(result)
                let id = res["id"].intValue
                let title = res["title"].stringValue
                let note = res["note"].stringValue
                let difficulty = res["difficulty"].intValue
                let upVotes = res["upVotes"].intValue
                let downVotes = res["downVotes"].intValue
                let distance = res["distance"].doubleValue
                let privateRoute = res["private"].boolValue
                let routePinsTemp = res["routePins"]
                var path: [Node] = []
                for i in 0...(routePinsTemp.count - 1) {
                    let obj = JSON(routePinsTemp[i])
                    guard let node = Node(long: obj["long"].doubleValue, lat: obj["lat"].doubleValue, type: obj["type"].stringValue, title: obj["title"].stringValue) else {
                        fatalError("Could not read object from server correctly when creating a node")
                    }
                    path.append(node)
                }
                let pointPinsTemp = res["pointPins"]
                var points: [Node] = []
                if (pointPinsTemp.count > 0) {
                    for i in 0...(pointPinsTemp.count - 1) {
                        let obj = JSON(pointPinsTemp[i])
                        guard let node = Node(long: obj["long"].doubleValue, lat: obj["lat"].doubleValue, type: obj["type"].stringValue, title: obj["title"].stringValue) else {
                            fatalError("Could not read object from server correctly when creating a node")
                        }
                        points.append(node)
                    }
                }
                self.route = Route(id: id, title: title, note: note, routePins: path, difficulty: difficulty, distance: distance, upVotes: upVotes, downVotes: downVotes, privateRoute: privateRoute, user: self.user!, pointPins: points, voted: false)
                break
            case .failure(let error):
                print(error)
                break
            }
            completion()
        }
    }
    
    // Update the save button when all conditions are met.
    func updateSaveState() {
        if routePins.count < 2 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    // After adding a pin, update the map to display the new path and pin
    func updateMapPins() {
        if routePins != nil && routePins.count > 0 {
            for pin in routePins {
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.lat), longitude: CLLocationDegrees(pin.long))
                let marker = GMSMarker(position: position)
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.title = pin.title
                marker.icon = UIImage(named: "routePin")
                marker.map = self.mapView
                
                routeMarkers += [marker]
            }
            mapView.camera = GMSCameraPosition(target: routeMarkers[routeMarkers.count-1].position , zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        }
        
        if pointPins != nil && pointPins.count > 0 {
            for pin in pointPins {
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.lat), longitude: CLLocationDegrees(pin.long))
                let marker = GMSMarker(position: position)
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.title = pin.title
                switch pin.type {
                case "Bike Shop":
                    marker.icon = UIImage(named: "bikeShop")
                case "Store":
                    marker.icon = UIImage(named: "store")
                case "Point of Interest":
                    marker.icon = UIImage(named: "pointOfInterest")
                case "Hazard":
                    marker.icon = UIImage(named: "hazard")
                default:
                    marker.icon = GMSMarker.markerImage(with: .black)
                }
                
                marker.map = self.mapView
                
                pointMarkers += [marker]
                
            }
        }
        
        if (routePins.count > 1) {
            for route in routePoints {
                let path = GMSPath.init(fromEncodedPath: route)
                let polyline = GMSPolyline.init(path: path)
                polyline.spans = [GMSStyleSpan(color: .red)]
                polyline.strokeWidth = 3.0
                polyline.map = self.mapView
            }
        }
    }
    
    // Change the distance after adding a new pin
    func updateDistance(){
        var totalDistance = routeDistance.reduce(0, +)
        if totalDistance > 1000 {
            totalDistance = totalDistance / 1000
            distanceTextLabel.text = String(format: "%.1f", totalDistance) + " km"
        } else {
            distanceTextLabel.text = String(format: "%.0f", totalDistance) + " m"
        }
        print("total distance: \(totalDistance)")
    }
    
    // MARK: Actions
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            view.frame.origin.y += keyboardHeight
        }
    }
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
}

// MARK: UITextFieldDelegate
extension RouteCreateViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide Keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: UITextViewDelegate
extension RouteCreateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
}

// MARK: CLLocationManagerDelegate
extension RouteCreateViewController: CLLocationManagerDelegate {
    
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
        
        if routeMarkers.count < 1 {
            // update map to center around the user's location
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        }
        
        // no longer need updates, stop updating
        locationManager.stopUpdatingLocation()
    }
}
