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

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    //MARK: Attributes
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    //var currentLocation: CLLocation?
    var zoomLevel: Float = 12.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu()
        customizeNavBar()
        initChameleonColors()
        
        //mapView.camera = GMSCameraPosition.camera(withLatitude: 50, longitude:-100, zoom: zoomLevel)
        //mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
    }
 
   /* func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
    }*/
    
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

// MARK: - CLLocationManagerDelegate

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

