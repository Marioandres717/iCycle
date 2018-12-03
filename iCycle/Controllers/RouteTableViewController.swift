//
//  RouteTableViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-09.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import ChameleonFramework
import Alamofire
import SwiftyJSON

class RouteTableViewController: UITableViewController {
    
    //MARK: Attributes
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var routes: [Route] = []
    var session: URLSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        sideMenu()
        customizeNavBar()
        initChameleonColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.routes = []
        loadRoutes {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RouteTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RouteTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RouteTableViewCell.")
        }
        
        let route = routes[indexPath.row]
        
        cell.title.text = route.title
        
        switch(route.difficulty) {
        case 1:
            cell.difficulty.text = "Low"
            cell.difficulty.textColor = FlatGreen()
        case 2:
            cell.difficulty.text = "Medium"
            cell.difficulty.textColor = FlatYellow()
        case 3:
            cell.difficulty.text = "High"
            cell.difficulty.textColor = FlatRed()
        default:
            cell.difficulty.text = "Low"
            cell.difficulty.textColor = FlatGreen()
            break
        }
        
        cell.distance.text = "_ Km"
        
        cell.score.text = String(route.score)
        
        cell.author.text = route.user.userName
        
        return cell
    }
    
    func loadRoutes(completion : @escaping ()->()) {
        let urlString = UrlBuilder.getAllRoutes()
        
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success(let result):
                let res = JSON(result)
                for i in 0...res.count {
                    let id = res[i]["id"].intValue
                    let title = res[i]["title"].stringValue
                    let note = res[i]["note"].stringValue
                    let difficulty = res[i]["difficulty"].intValue
                    let upVotes = res[i]["upVotes"].intValue
                    let downVotes = res[i]["downVotes"].intValue
                    let privateRoute = res[i]["private"].boolValue
                    let routePinsTemp = res[i]["routePins"]
                    let user = User(id: res[i]["user"]["id"].intValue, userName: res[i]["user"]["username"].stringValue, bikeSerialNumber: res[i]["user"]["bikeSerialNumber"].stringValue, bikeBrand: res[i]["user"]["bikeBrand"].stringValue, bikeNotes: res[i]["user"]["bikeNotes"].stringValue, bikeImage: nil)
                    var path: [Node] = []
                    for pin in routePinsTemp {
                        let obj = JSON(pin)
                        guard let node = Node(long: obj["long"].doubleValue, lat: obj["lat"].doubleValue, type: obj["type"].stringValue, title: obj["title"].stringValue) else {
                            fatalError("Could not read object from server correctly when creating a node")
                        }
                        path.append(node)
                    }
                    
                    let pointPinsTemp = res[i]["pointPins"]
                    var points: [Node] = []
                    for pin in pointPinsTemp {
                        let obj = JSON(pin)
                        guard let node = Node(long: obj["long"].doubleValue, lat: obj["lat"].doubleValue, type: obj["type"].stringValue, title: obj["title"].stringValue) else {
                            fatalError("Could not read object from server correctly when creating a node")
                        }
                        points.append(node)
                    }
                    
                    let tempRoute = Route(id: id, title: title, note: note, routePins: path, difficulty: difficulty, upVotes: upVotes, downVotes: downVotes, privateRoute: privateRoute, user: user, pointPins: points, voted: false)
                    
                    self.routes.append(tempRoute)
                }
                break
            case .failure(let error):
                print(error)
                break
            }
            completion()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowRouteDetail":
            guard let routeDetailViewController = segue.destination as? RouteDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedRouteCell = sender as? RouteTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedRouteCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRoute = routes[indexPath.row]
            routeDetailViewController.route = selectedRoute
        case "CreateRoute":
            break
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // Execute when returning from adding a route.
    @IBAction func unwindToRouteTable(segue:UIStoryboardSegue) {
        if let routeCreateController = segue.source as? RouteCreateViewController {
            
        }
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
    
    // MARK: Chameleon related
    func initChameleonColors() {
        view.backgroundColor = FlatBlack()
    }
}
