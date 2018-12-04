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
import Firebase

class RouteImageViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var captionTextField: UITextView!
    @IBOutlet weak var addPictureBtn: UIButton!
    
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routePictureMarkers: [GMSMarker] = []
    var routeLines: [String] = []
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    var route: Route?
    var routePictures: [RoutePhoto] = []
    var user: User?
    var pictureSelected: UIImage?

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
//        if routePictures.isEmpty == false {
//            for
//        }
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
            break
            
        case "unwindToAddPictureToCollection":
            guard let routePictureCollectionViewController = segue.destination as? RoutePictureCollectionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            print("HERE")
            routePictureCollectionViewController.photos.append(self.routePictures[self.routePictures.count - 1])
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

    @IBAction func saveRoutePhoto(_ sender: Any) {
        print("SAVING PHOTO")
        saveRoutePhoto(completion: { res in
            self.routePictures.append(res)
            self.performSegue(withIdentifier: "unwindToAddPictureToCollection", sender: self)
        })
    }
    
    @IBAction func unwidToAddPictureToRoute(segue: UIStoryboardSegue) {
        if let selectPictureCoordinatesViewController = segue.source as? SelectPictureCoordinatesViewController {
            updatePicturePins()
           // updateSaveState()
        }
    }
    
    func saveRoutePhoto(completion: @escaping (_ res: RoutePhoto)->()) {
        let title = titleTextField.text ?? ""
        let caption = captionTextField.text ?? ""
        self.user = User.loadUser()
        let urlString = UrlBuilder.addPhotoToRoute(routeId: route!.id, userId: self.user!.id)
        let temp = routePictureMarkers[routePictureMarkers.endIndex - 1]
        let coordinates = ["long": temp.position.longitude, "lat": temp.position.latitude]
        
        self.uploadImageToFirebaseStorage(completion: { (url) in
            let parameters : [String: Any] = [
                "title": title,
                "caption": caption,
                "coordinates": coordinates,
                "photo": url!.absoluteString,
                ]
            print("URL \(url!.absoluteString)")
            Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {(response) in
                switch response.result {
                    case .success(let result):
                        let res = JSON(result)
                        let id = res["id"].intValue
                        let title = res["title"].stringValue
                        let caption = res["caption"].stringValue
                        let photo = res["photo"].stringValue
                        let lat = res["coordinates"]["lat"].doubleValue
                        let long = res["coordinates"]["long"].doubleValue
                    
                        completion(RoutePhoto(photoUrl: url!.absoluteString, long: long, lat: lat, user: self.user!, routeId: self.route!.id, title: title, caption: caption))
                default:
                    print("ERRORRRR")
                }
            }
        })
    }

    func uploadImageToFirebaseStorage(completion: @escaping ((_ url: URL?) ->())) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "routes/\(imageName).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        let data = pictureSelected!.jpegData(compressionQuality: 0.8)
        storageRef.putData(data!, metadata: uploadMetaData) { (metadata, error) in
            if (error != nil){
                print("ERROR: \(String(describing: error?.localizedDescription))")
            } else {
                print("upload complete! metadata: \(String(describing: metadata))")
                storageRef.downloadURL { (url, error) in
                    print("calling Completion \(url!.absoluteString)")
                    completion(url)
                }
            }
        }
    }
    
//    func deleteImageFromFirebaseStorage() {
//        let storage = Storage.storage()
//        let url = self.firebasePicURL
//        let storageRef = storage.reference(forURL: url!)
//        storageRef.delete { error in
//            if let error = error {
//                print("\(error)")
//            } else {
//                print("image sucessfully deleted")
//            }
//        }
//    }
}
