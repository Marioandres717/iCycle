//
//  MapViewController.swift
//  iCycle
//
//  Created by Valentyna Akulova on 2018-11-08.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import ChameleonFramework
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    //MARK: Attributes
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 12.0
    var allPoints: [Node] = []
    var firstRoutePins: [Node] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        sideMenu()
        customizeNavBar()
        initChameleonColors()
        
        getAllRoutePins(completion: {
            self.displayPins(pointPins: self.allPoints, routePins: self.firstRoutePins)
        })
        
    }
    
    // MARK: Chameleon related
    func initChameleonColors() {
        view.backgroundColor = FlatBlack()
    }
    
    // MARK: Navigation
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.tintColor = FlatGreen()
        navigationController?.navigationBar.barTintColor = FlatBlack()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    //MARK: Display Pins
    func getAllRoutePins (completion : @escaping ()->()) {
        var urlString = UrlBuilder.getAllRoutes()
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON {
        response in
        
        switch response.result {
            
        case .success(let result):
            let res = JSON(result)
            if res.count > 0 {
                for i in 0...(res.count - 1) {
                    
                    //let routePinsTemp = res[i]["routePins"]
                    //for j in 0...(routePinsTemp.count - 1) {
                        guard let node = Node(long: res[i]["routePins"][0]["long"].doubleValue, lat: res[i]["routePins"][0]["lat"].doubleValue, type: res[i]["routePins"][0]["type"].stringValue, title: res[i]["title"].stringValue) else {
                            fatalError("Could not read object from server correctly when creating a node")
                        }
                        self.firstRoutePins.append(node)
                   // }
                    
                    let pointPinsTemp = res[i]["pointPins"]
                    if (pointPinsTemp.count > 0) {
                        for j in 0...(pointPinsTemp.count - 1) {
                            guard let node = Node(long: res[i]["pointPins"][j]["long"].doubleValue, lat: res[i]["pointPins"][j]["lat"].doubleValue, type: res[i]["pointPins"][j]["type"].stringValue, title: res[i]["pointPins"][j]["title"].stringValue) else {
                                fatalError("Could not read object from server correctly when creating a node")
                            }
                            self.allPoints.append(node)
                        }
                    }
                }
            }
            break
        case .failure(let error):
            print(error)
            break
        }
        completion()
        }
    }
    
    func displayPins(pointPins: [Node], routePins: [Node]){
        
        if routePins != nil && routePins.count > 0 {
            for pin in routePins {
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.lat), longitude: CLLocationDegrees(pin.long))
                let marker = GMSMarker(position: position)
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.title = pin.title
                marker.icon = UIImage(named: "routePin")
                marker.map = self.mapView
            
            }
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
            }
    }

 
    // MARK: Chameleon related
    func initChameleonColors() {
        view.backgroundColor = FlatBlack()
    }
    
    // MARK: Navigation
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.tintColor = FlatGreen()
        navigationController?.navigationBar.barTintColor = FlatBlack()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }

}
}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
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

