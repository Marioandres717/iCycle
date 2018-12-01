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
            
            let title = routeTitle.text ?? ""
            let difficulty = routeDifficulty.selectedSegmentIndex + 1
            let notes = routeNotes.text ?? ""
            let privacy = routeIsPrivate.isOn
            
            print("path pins: \(routePins)")
            
            let path = routePins.map({(pin) -> String in
                return "{'long': \(pin.long),'lat': \(pin.lat),'type': \(pin.type),'title': \(pin.title)}"
            })
            
            let points = pointPins.map({(pin) -> String in
                return "{'long': \(pin.long),'lat': \(pin.lat),'type': \(pin.type),'title': \(pin.title)}"
            })
                        
            // SEND ROUTE TO BACKEND-------
            self.user = User.loadUser()
            let parameters = ["title": title, "note": notes, "routePins": path, "difficulty": difficulty, "private": privacy, "userId": user?.id ?? -1, "pointPins": points] as [String : Any]
            
            print("params: \(parameters)")
            
            HttpConfig.postRequestConfig(url: UrlBuilder.createRoute(), parameters: parameters)
            
            let sessionConfig = HttpConfig.sessionConfig()
            
            session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            
            if let task = self.session?.dataTask(with: HttpConfig.request) {
                task.resume()
            }
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
        /*
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&mode=driving&key=AIzaSyBUJZaFSeeEgoJktJao7Fh3V02MsHMY2cI"
        
        
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //print("JSON HERE: \(json)")
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    if let points = routeOverviewPolyline?["points"]?.stringValue{
                        
                        self.routePoints! += [points]
                        //print
                    } else {
                        print ("ERROR: routePoints is nil")
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
            
            completion()
        }
 */
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
                marker.map = self.mapView
                
                routeMarkers += [marker]
            }
        }
        
        if pointPins != nil && pointPins.count > 0 {
            for pin in pointPins {
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.lat), longitude: CLLocationDegrees(pin.long))
                let marker = GMSMarker(position: position)
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.title = pin.title
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
