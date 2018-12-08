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

class MapViewController: UIViewController {
    
    //MARK: Attributes
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var locationManager = CLLocationManager()
    var zoomLevel: Float = 12.0
    
    var routeMarkers: [GMSMarker] = [] // Stores the first marker of every route.
    var allPoints: [Node] = [] // Stores all of the non-route pins
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Delegates
        locationManager.delegate = self
        mapView.delegate = self
        
        // Location Management
        locationManager.requestWhenInUseAuthorization()
        
        // Customize the Screen and Navigation
        sideMenu()
        customizeNavBar()
        initChameleonColors()
        
        // Retrieve all of the pins from the routes and display them
        getAllRoutePins(completion: {
            self.displayPins(pointPins: self.allPoints)
        })
        
    }
    
    // MARK: Customize the Screen and Navigation
    func initChameleonColors() {
        view.backgroundColor = FlatBlack()
    }
    
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
    
    //MARK: Retrieve all of the pins from the routes and display them
    func getAllRoutePins (completion : @escaping ()->()) {
        let urlString = UrlBuilder.getAllRoutes()
        
        // Send a request to the server to get the routes
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let result):
                let res = JSON(result)
                if res.count > 0 {
                    for i in 0...(res.count - 1) {
                        
                        guard let node = Node(long: res[i]["routePins"][0]["long"].doubleValue, lat: res[i]["routePins"][0]["lat"].doubleValue, type: res[i]["routePins"][0]["type"].stringValue, title: res[i]["title"].stringValue) else {
                            fatalError("Could not read object from server correctly when creating a node")
                        }
                        let id = res[i]["id"].intValue
                        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(node.lat), longitude: CLLocationDegrees(node.long))
                        let marker = GMSMarker(position: position)
                        marker.appearAnimation = GMSMarkerAnimation.pop
                        marker.title = "Route: \(node.title) (Press to view)"
                        marker.icon = UIImage(named: "routePin")
                        marker.map = self.mapView
                        marker.userData =  ["routeId" : id] as [String : Any]
                        
                        self.routeMarkers.append(marker)
                        
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
    
    // Display the pins on the map
    func displayPins(pointPins: [Node]){
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
    }
    
    // Before the segue to the detail screen, retrieve the route entirely and send it with the segue
    private func getRouteInfoById (id: Int, completion : @escaping (_: Route)->()) {
        let urlString = UrlBuilder.getRouteById(routeId: id)
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            
            switch response.result {
                
            case .success(let result):
                let res = JSON(result)
                print("RES: \(res)")
                let id = res["id"].intValue
                let title = res["title"].stringValue
                let note = res["note"].stringValue
                let difficulty = res["difficulty"].intValue
                let upVotes = res["upVotes"].intValue
                let downVotes = res["downVotes"].intValue
                let distance = res["distance"].doubleValue
                let privateRoute = res["private"].boolValue
                let routePinsTemp = res["routePins"]
                let user = User(id: res["user"]["id"].intValue, userName: res["user"]["username"].stringValue, bikeSerialNumber: res["user"]["bikeSerialNumber"].stringValue, bikeBrand: res["user"]["bikeBrand"].stringValue, bikeNotes: res["user"]["bikeNotes"].stringValue, bikeImage: nil)
                var path: [Node] = []
                for j in 0..<(routePinsTemp.count) {
                    guard let node = Node(long: res["routePins"][j]["long"].doubleValue, lat: res["routePins"][j]["lat"].doubleValue, type: res["routePins"][j]["type"].stringValue, title: res["routePins"][j]["title"].stringValue) else {
                        fatalError("Could not read object from server correctly when creating a node")
                    }
                    path.append(node)
                }
                
                let pointPinsTemp = res["pointPins"]
                var points: [Node] = []
                if (pointPinsTemp.count > 0) {
                    for j in 0...(pointPinsTemp.count - 1) {
                        guard let node = Node(long: res["pointPins"][j]["long"].doubleValue, lat: res["pointPins"][j]["lat"].doubleValue, type: res["pointPins"][j]["type"].stringValue, title: res["pointPins"][j]["title"].stringValue) else {
                            fatalError("Could not read object from server correctly when creating a node")
                        }
                        points.append(node)
                    }
                }
                
                let tempRoute = Route(id: id, title: title, note: note, routePins: path, difficulty: difficulty, distance: distance, upVotes: upVotes, downVotes: downVotes, privateRoute: privateRoute, user: user, pointPins: points, voted: false)
                
                completion(tempRoute)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "GoToTheRouteDetails" {
            
            guard let routeDetailViewController = segue.destination as? RouteDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // pass route to the route detail view controller
            routeDetailViewController.route = sender as? Route
        }
    }
    
}

// MARK: GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.activityIndicator.startAnimating()
        
        let data = marker.userData! as! [String : Any] // get the id of the pin that was tapped
        let id = data["routeId"] as! Int
        print("ROUTE ID: \(id)")
        getRouteInfoById(id: id, completion: { route in
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: "GoToTheRouteDetails", sender: route)
        })
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


