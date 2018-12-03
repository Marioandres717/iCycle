//
//  RouteDetailViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-10.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import ChameleonFramework
import Alamofire
import SwiftyJSON

class RouteDetailViewController: UIViewController {
    
    // MARK: Attributes
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var addPinButton: UIButton!
    @IBOutlet weak var routePhotosButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routeLines: [String] = []
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    var hasUpvoted: Bool = false
    var hasDownvoted: Bool = false
    var hasSaved: Bool = false
    
    var route: Route?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initChameleonColors()
        
        hasUpvoted = false
        hasDownvoted = false
        
        self.user = User.loadUser()
        
        if let route = route {
            setUpRoute(route: route)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Methods
    func initChameleonColors() {
        view.backgroundColor = FlatBlack()
        
        addPinButton.backgroundColor = FlatForestGreen()
        addPinButton.layer.cornerRadius = 3
        addPinButton.layer.borderWidth = 1
        addPinButton.layer.borderColor = FlatGreen().cgColor
        
        routePhotosButton.backgroundColor = FlatSkyBlue()
        routePhotosButton.layer.cornerRadius = 3
        routePhotosButton.layer.borderWidth = 1
        routePhotosButton.layer.borderColor = FlatBlue().cgColor
        
        upVoteButton.backgroundColor = FlatWhiteDark()
        upVoteButton.layer.cornerRadius = 3
        upVoteButton.layer.borderWidth = 1
        upVoteButton.layer.borderColor = FlatGray().cgColor
        
        downVoteButton.backgroundColor = FlatWhiteDark()
        downVoteButton.layer.cornerRadius = 3
        downVoteButton.layer.borderWidth = 1
        downVoteButton.layer.borderColor = FlatGray().cgColor
    }
    
    func setUpRoute (route: Route) {
        switch (route.difficulty) {
        case 1:
            difficultyLabel.text = "Low"
            difficultyLabel.textColor = FlatGreen()
            break
        case 2:
            difficultyLabel.text = "Medium"
            difficultyLabel.textColor = FlatYellow()
            break
        case 3:
            difficultyLabel.text = "High"
            difficultyLabel.textColor = FlatRed()
            break
        default:
            break
        }
        
        navBar.title = route.title
        
        var totalDistance = route.distance
        if  totalDistance > 1000 {
            totalDistance = totalDistance / 1000
            distanceLabel.text = String(format: "%.1f", totalDistance) + " km"
        } else {
            distanceLabel.text = String(format: "%.0f", totalDistance) + " m"
        }
        
        notesTextView.text = route.note
        authorLabel.text = route.user.userName
        
        getVote(completion: {res in
            switch(res) {
            case "up":
                self.hasDownvoted = false;
                self.downVoteButton.backgroundColor = FlatWhiteDark()
                self.downVoteButton.layer.borderColor = FlatGray().cgColor
                
                self.hasUpvoted = true;
                self.upVoteButton.backgroundColor = FlatForestGreen()
                self.upVoteButton.layer.borderColor = FlatForestGreenDark().cgColor
                break
            case "down":
                self.hasUpvoted = false;
                self.upVoteButton.backgroundColor = FlatWhiteDark()
                self.upVoteButton.layer.borderColor = FlatGray().cgColor
                
                self.hasDownvoted = true;
                self.downVoteButton.backgroundColor = FlatBlue();
                self.downVoteButton.layer.borderColor = FlatBlueDark().cgColor
                break
            case "none":
                self.hasUpvoted = false
                self.hasDownvoted = false
                break
            default:
                fatalError("Unexpected response: \(res)")
            }
            
            self.getHasSaved(completion: {res in
                if res == true {
                    self.hasSaved = true
                    self.saveButton.title = "Un-save"
                } else {
                    self.hasSaved = false
                    self.saveButton.title = "Save"
                }
                self.populateMap(routePins: route.routePins, pointPins: route.pointPins)
            })
        })
    }
    
    func getVote(completion: @escaping (_ res: String)->()) {
        let urlString = UrlBuilder.hasVoted(id: self.route!.id, userId: self.user!.id)
        
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let res = json["voted"].stringValue
                completion(res)
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
    
    func save(completion: @escaping (_ res: Bool)->()) {
        let urlString = UrlBuilder.saveRoute(id: self.route!.id, userId: self.user!.id)
        
        Alamofire.request(urlString, method: .put).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                completion(JSON(value).boolValue)
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
    
    func getHasSaved(completion: @escaping (_ res: Bool)->()) {
        let urlString = UrlBuilder.hasSaved(id: self.route!.id, userId: self.user!.id)
        
        Alamofire.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let res = json["saved"].boolValue
                completion(res)
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
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
    
    // MARK: Actions
    @IBAction func upVote(_ sender: Any) {
        
        let urlString = UrlBuilder.upVoteRoute(id: self.route!.id, userId: self.user!.id)
        
        Alamofire.request(urlString, method: .put).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if JSON(value).boolValue == true {
                    if (self.hasDownvoted == true) {
                        self.hasDownvoted = false;
                        self.downVoteButton.backgroundColor = FlatWhiteDark()
                        self.downVoteButton.layer.borderColor = FlatGray().cgColor
                        
                        self.hasUpvoted = true;
                        self.upVoteButton.backgroundColor = FlatForestGreen()
                        self.upVoteButton.layer.borderColor = FlatForestGreenDark().cgColor
                    } else if (self.hasUpvoted == true) {
                        self.hasUpvoted = false;
                        self.upVoteButton.backgroundColor = FlatWhiteDark()
                        self.upVoteButton.layer.borderColor = FlatGray().cgColor
                    } else if (self.hasUpvoted == false) {
                        self.hasUpvoted = true;
                        self.upVoteButton.backgroundColor = FlatForestGreen()
                        self.upVoteButton.layer.borderColor = FlatForestGreenDark().cgColor
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
    
    @IBAction func downVote(_ sender: Any) {
        
        let urlString = UrlBuilder.downVoteRoute(id: self.route!.id, userId: self.user!.id)
        
        Alamofire.request(urlString, method: .put).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if JSON(value).boolValue == true {
                    if (self.hasUpvoted == true) {
                        self.hasUpvoted = false;
                        self.upVoteButton.backgroundColor = FlatWhiteDark()
                        self.upVoteButton.layer.borderColor = FlatGray().cgColor
                        
                        self.hasDownvoted = true;
                        self.downVoteButton.backgroundColor = FlatBlue();
                        self.downVoteButton.layer.borderColor = FlatBlueDark().cgColor
                        
                    } else if (self.hasDownvoted == true) {
                        self.hasDownvoted = false;
                        self.downVoteButton.backgroundColor = FlatWhiteDark()
                        self.downVoteButton.layer.borderColor = FlatGray().cgColor
                        
                    } else if (self.hasDownvoted == false) {
                        self.hasDownvoted = true;
                        self.downVoteButton.backgroundColor = FlatBlue();
                        self.downVoteButton.layer.borderColor = FlatBlueDark().cgColor
                    }
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
    
    @IBAction func saveRoute(_ sender: Any) {
        save(completion: { res in
            print(res)
            if res == true {
                print("Before: \(self.hasSaved)")
                self.hasSaved = !self.hasSaved
                print("After: \(self.hasSaved)")
                
                if self.hasSaved == true {
                    print("Save")
                    self.saveButton.title = "Un-save"
                } else {
                    print("Un-save")
                    self.saveButton.title = "Save"
                }
            }
        })
    }
}
