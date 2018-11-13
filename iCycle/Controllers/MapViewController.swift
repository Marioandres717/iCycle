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
import Chameleon
import SideMenu

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    //MARK: Attributes
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var locationManager = CLLocationManager()
    //var currentLocation: CLLocation?
    var zoomLevel: Float = 6.0
    
    //var currentPlace: GMSPlace?
    let defaultLocation = CLLocation(latitude: 50.4480, longitude: -104.6122)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu()
        customizeNavBar()
        initChameleonColors()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
 
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("hey \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    // MARK: Chameleon related
    func initChameleonColors() {
        view.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: view.frame, colors: [FlatGrayDark(), FlatOrange()])
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
        navigationController?.navigationBar.tintColor = FlatOrange()
        navigationController?.navigationBar.barTintColor = FlatBlack()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }

}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        let camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)


        locationManager.stopUpdatingLocation()
    }
}

