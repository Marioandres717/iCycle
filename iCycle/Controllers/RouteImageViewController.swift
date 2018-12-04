//
//  RouteImageViewController.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-12-03.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class RouteImageViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var captionTextField: UITextView!
    @IBOutlet weak var addPictureBtn: UIButton!
    
    
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routeLines: [String] = []
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    var route: Route?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.user = User.loadUser()
        
        if let route = route {
            setUpRoute(route: route)
        }
    }
    
    // MARK: Methods
    
    func setUpRoute(route: Route) {
        navBar.title = route.title
        self.populateMap(routePins: route.routePins, pointPins: route.pointPins)
    }
    
    func updatePicturePins() {
        
    }
    
    func updateSaveState() {
    
    }
    
    func populateMap(routePins: [Node], pointPins: [Node]) {
        if routePins.count > 0 {
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
        
        if pointPins.count > 0 {
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
        
        for i in 1...(routePins.count - 1) {
            let p1 = CLLocationCoordinate2D(latitude: CLLocationDegrees(routePins[i-1].lat), longitude: CLLocationDegrees(routePins[i-1].long))
            let p2 = CLLocationCoordinate2D(latitude: CLLocationDegrees(routePins[i].lat), longitude: CLLocationDegrees(routePins[i].long))
            
            drawRouteBetweenTwoLastPins(sourceCoordinate: p1, destinationCoordinate: p2, completion: {
                let path = GMSPath.init(fromEncodedPath: self.routeLines[self.routeLines.count - 1])
                let polyline = GMSPolyline.init(path: path)
                polyline.spans = [GMSStyleSpan(color: .red)]
                polyline.strokeWidth = 3.0
                polyline.map = self.mapView
            })
        }
    }
    
    private func drawRouteBetweenTwoLastPins (sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion : @escaping ()->()) {
        
        let source: String = "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)"
        let destination: String = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&mode=bicycling&key=AIzaSyBUJZaFSeeEgoJktJao7Fh3V02MsHMY2cI"
        
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    if let points = routeOverviewPolyline?["points"]?.stringValue{
                        self.routeLines += [points]
                    } else {
                        print ("ERROR: routePoints is nil")
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
            completion()
        }
    }

    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "coordinatesForImage":
            guard let selectPictureCoordinatesVC = segue.destination as? SelectPictureCoordinatesViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            selectPictureCoordinatesVC.route = self.route
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // Execute when returning from adding a pin.
//    @IBAction func unwindToCreateRoute(segue:UIStoryboardSegue) {
//        if let selectWaypointViewController = segue.source as? SelectWaypointViewController {
//            updateMapPins()
//            updateSaveState()
//            updateDistance()
//        }
//    }
    
    @IBAction func unwidToAddPictureToRoute(segue: UIStoryboardSegue) {
        if let selectPictureCoordinatesViewController = segue.source as? SelectPictureCoordinatesViewController {
            updatePicturePins()
            updateSaveState()
        }
    }

}
