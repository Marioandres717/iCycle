//
//  MapViewController.swift
//  iCycle
//
//  Created by Valentyna Akulova on 2018-11-08.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import Chameleon
import SideMenu

class MapViewController: UIViewController {
    
    //override func loadView() {
    //}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initChameleonColors()
        loadMap()
        
        
 
    }
    
    // MARK: GoogleMaps
    private func loadMap (){
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        //mapView.addSubview(optionsButton)
    }
    
    // MARK: Chameleon related
    func initChameleonColors() {
        view.backgroundColor = FlatGrayDark()
    }

}
