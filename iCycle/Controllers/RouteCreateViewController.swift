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
    // For saving in the Route
    var routePins: [Node] = []
    var pointPins: [Node] = []
    
    // For Display on the Map
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routePoints: [String] = []
    
    var session: URLSession?
    var user: User?
    
    var route: Route?
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 12.0
    
    @IBOutlet weak var routeTitle: UITextField!
    @IBOutlet weak var routeDifficulty: UISegmentedControl!
    @IBOutlet weak var routeNotes: UITextView!
    @IBOutlet weak var routeIsPrivate: UISwitch!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Delegates
        mapView.delegate = self
        routeTitle.delegate = self
        routeNotes.delegate = self
        locationManager.delegate = self
        
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
    
    deinit {
        // Stop Listening for Keyboard Events
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "saveRoute": // Saving and returning to the list of Routes
            print(segue.identifier)
            guard let routeTableViewController = segue.destination as? RouteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
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
    
    //MARK: Methods
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func saveRoute (completion : @escaping ()->()) {
        let urlString = UrlBuilder.createRoute()
        
        let title = routeTitle.text ?? ""
        let difficulty = routeDifficulty.selectedSegmentIndex + 1
        let notes = routeNotes.text ?? ""
        let privacy = routeIsPrivate.isOn
        
        self.user = User.loadUser()
        
        let path = routePins.map({(pin) -> String in
            return "{'long': \(pin.long),'lat': \(pin.lat),'type': \(pin.type),'title': \(pin.title!)}"
        })
        
        let points = pointPins.map({(pin) -> String in
            return "{'long': \(pin.long),'lat': \(pin.lat),'type': \(pin.type),'title': \(pin.title!)}"
        })
        
        
        let parameters = ["title": title, "note": notes, "routePins": path, "difficulty": difficulty, "private": privacy, "userId": user?.id ?? -1, "pointPins": points] as [String : Any]
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success(let result):
                let res = JSON(result)
                print(res)
                let id = res["id"].intValue
                let title = res["title"].stringValue
                let note = res["note"].stringValue
                let difficulty = res["difficulty"].intValue
                let upVotes = res["upVotes"].intValue
                let downVotes = res["downVotes"].intValue
                let privateRoute = res["private"].boolValue
                let routePinsTemp = JSON(res["routePins"])
                var path: [Node] = []
                for pin in routePinsTemp {
                    let obj = JSON(pin)
                    guard let node = Node(long: obj["long"].doubleValue, lat: obj["lat"].doubleValue, type: obj["type"].stringValue, title: obj["title"].stringValue) else {
                        fatalError("Could not read object from server correctly when creating a node")
                    }
                    path.append(node)
                }
                
                let pointPinsTemp = JSON(res["pointPins"])
                var points: [Node] = []
                for pin in pointPinsTemp {
                    let obj = JSON(pin)
                    guard let node = Node(long: obj["long"].doubleValue, lat: obj["lat"].doubleValue, type: obj["type"].stringValue, title: obj["title"].stringValue) else {
                        fatalError("Could not read object from server correctly when creating a node")
                    }
                    points.append(node)
                }
                
                self.route = Route(id: id, title: title, note: note, routePins: path, difficulty: difficulty, upVotes: upVotes, downVotes: downVotes, privateRoute: privateRoute, user: self.user!, pointPins: points, voted: false)
                
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
                print("pin type: \(pin.type)")
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
                polyline.map = self.mapView
            }
        }
    }
    
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

// MARK: GMSMapViewDelegate
extension RouteCreateViewController: GMSMapViewDelegate {
    
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
