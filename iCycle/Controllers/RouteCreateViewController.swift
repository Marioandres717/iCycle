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
    var pins: [Node] = []
    var markers: [GMSMarker] = []
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
            print(JSONSerialization.isValidJSONObject(Node.self))
            guard let routeTableViewController = segue.destination as? RouteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let title = routeTitle.text ?? ""
            let difficulty = routeDifficulty.selectedSegmentIndex + 1
            let notes = routeNotes.text ?? ""
            let privacy = routeIsPrivate.isOn
            
            print("path pins: \(pins)")
            
            let path = pins.map({(pin) -> String in
                return "{'long': \(pin.long),'lat': \(pin.lat)}"
            })
                        
            // SEND ROUTE TO BACKEND-------
            self.user = User.loadUser()
            let parameters = ["title": title, "note": notes, "coordinates": path, "difficulty": difficulty, "private": privacy, "userId": user?.id ?? -1] as [String : Any]
            
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
            selectWaypointViewController.markers = markers
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
        
        if (markers.count > 1) {
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
