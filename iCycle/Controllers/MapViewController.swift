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
    
    private var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 6.0
    
    var currentPlace: GMSPlace?
    let defaultLocation = CLLocation(latitude: 50.4480, longitude: -104.6122)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initChameleonColors()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //set camera to default location
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //mapView.delegate = self
        //self.view = mapView
        
    }
 
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("hey \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    // MARK: Chameleon related
    func initChameleonColors() {
        //view.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: view.frame, colors: [FlatBlack(), FlatOrange()])
        //navigationBar.backgroundColor = FlatBlack()
    }

}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        guard status == .authorizedWhenInUse else {
            return
        }
    
        locationManager.startUpdatingLocation()
        
        //mapView.isMyLocationEnabled = true
        //mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
    }
}
