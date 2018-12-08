//
//  SelectPictureCoordinatesViewController.swift
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

class SelectPictureCoordinatesViewController: UIViewController {
    //MARK: Attributes
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var routeMarkers: [GMSMarker] = []
    var pointMarkers: [GMSMarker] = []
    var routeLines: [String] = []
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 13.0
    
    var marker: GMSMarker? // The currently selected marker

    var route: Route?
    var user: User?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the Delegates
        mapView.delegate = self
        locationManager.delegate = self
        
        // Location Management
        locationManager.requestWhenInUseAuthorization()
        
        if let route = route {
            setUpRoute(route: route)
        }
        
        // Disable the save button by default
        saveBtn.isEnabled = false
        
        // Load the user
        self.user = User.loadUser()
    }
    
    // MARK: Custom Methods
    
    func setUpRoute(route: Route) {
        self.populateMap(routePins: route.routePins, pointPins: route.pointPins)
    }
    
    // Display pins on the map
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
    
    // Draw the path between pins
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
    
    func addImageToRoute(optionSelected: String) {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        imgPickerController.allowsEditing = true
        
        if optionSelected == "camera" {
            imgPickerController.sourceType = .camera
            
        } else if optionSelected == "library" {
            imgPickerController.sourceType = .photoLibrary
            
        } else {
            fatalError("Invalid action")
        }
        imgPickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: imgPickerController.sourceType)!
        
        present(imgPickerController, animated: true, completion: nil)
    }
    
    
    // MARK: Map Functionality
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D){
        
        // object for turning latitude and logitude into a street address
        let geocoder = GMSGeocoder()
        
        // reverse geocode the coordinates
        geocoder.reverseGeocodeCoordinate(coordinate){
            response, error in
            guard let location = response?.firstResult(), let lines = location.lines else{
                return
            }
            
            // animate the text change
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Actions
    @IBAction func addNewImage(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let displayCamera = UIAlertAction(title: "Camera", style: .default) { action in
            self.addImageToRoute(optionSelected: "camera")
        }
        
        let displayPhotoLib = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.addImageToRoute(optionSelected: "library")
        }
        
        actionSheet.addAction(displayCamera)
        actionSheet.addAction(displayPhotoLib)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier) {
        case "savePictureCoordinates":
            guard let routeImageViewController = segue.destination as? RouteImageViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if let img = self.image {
                routeImageViewController.pictureSelected = img
                routeImageViewController.routePictureMarkers.append(marker!)
            }
            
            break
        default:
            fatalError("Unexpected segue: \(segue.identifier)")
            break
        }
    }

}

extension SelectPictureCoordinatesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage  {
           self.image = editImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension SelectPictureCoordinatesViewController: GMSMapViewDelegate {
    
    // user placed a marker
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if self.image != nil {
            marker = GMSMarker(position: coordinate)
            marker!.appearAnimation = GMSMarkerAnimation.pop
            marker!.map = mapView
            //marker!.title = pinTitle.text ??
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), image: self.image!, borderColor: UIColor.darkGray)
            marker!.iconView = customMarker
            // updateSaveButtonState()
            reverseGeocodeCoordinate(coordinate)
            mapView.isUserInteractionEnabled = false
            selectImageBtn.isEnabled = false
            saveBtn.isEnabled = true
        }
    }
}

extension SelectPictureCoordinatesViewController: CLLocationManagerDelegate {
    
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
        
        if routeMarkers.count > 0 {
            mapView.camera = GMSCameraPosition(target: routeMarkers[routeMarkers.count-1].position , zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        }
        else {
            // update map to center around the user's location
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        }
        
        // no longer need updates, stop updating
        locationManager.stopUpdatingLocation()
    }
}
