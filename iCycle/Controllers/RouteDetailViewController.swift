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
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routeLines: [String] = []
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    var hasUpvoted: Bool = false
    var hasDownvoted: Bool = false
    
    var route: Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initChameleonColors()
        
        hasUpvoted = false
        hasDownvoted = false
        
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
        
        notesTextView.text = route.note
        authorLabel.text = route.user.userName
        
        populateMap(routePins: route.routePins, pointPins: route.pointPins)
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
        if (hasDownvoted == true) {
            hasDownvoted = false;
            downVoteButton.backgroundColor = FlatWhiteDark()
            downVoteButton.layer.borderColor = FlatGray().cgColor

            hasUpvoted = true;
            upVoteButton.backgroundColor = FlatForestGreen()
            upVoteButton.layer.borderColor = FlatForestGreenDark().cgColor
        } else if (hasUpvoted == true) {
            hasUpvoted = false;
            upVoteButton.backgroundColor = FlatWhiteDark()
            upVoteButton.layer.borderColor = FlatGray().cgColor
        } else if (hasUpvoted == false) {
            hasUpvoted = true;
            upVoteButton.backgroundColor = FlatForestGreen()
            upVoteButton.layer.borderColor = FlatForestGreenDark().cgColor
        }
    }
    
    @IBAction func downVote(_ sender: Any) {
        if (hasUpvoted == true) {
            hasUpvoted = false;
            upVoteButton.backgroundColor = FlatWhiteDark()
            upVoteButton.layer.borderColor = FlatGray().cgColor
            
            hasDownvoted = true;
            downVoteButton.backgroundColor = FlatBlue();
            downVoteButton.layer.borderColor = FlatBlueDark().cgColor
            
        } else if (hasDownvoted == true) {
            hasDownvoted = false;
            downVoteButton.backgroundColor = FlatWhiteDark()
            downVoteButton.layer.borderColor = FlatGray().cgColor
            
        } else if (hasDownvoted == false) {
            hasDownvoted = true;
            downVoteButton.backgroundColor = FlatBlue();
            downVoteButton.layer.borderColor = FlatBlueDark().cgColor
        }
    }
}
