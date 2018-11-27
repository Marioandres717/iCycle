//
//  RouteTableViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-09.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import Chameleon

class RouteTableViewController: UITableViewController {
    
    //MARK: Attributes
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var routes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu()
        customizeNavBar()
        
        initChameleonColors()
        
        loadSampleRoutes()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        
        cell.routeTitle.text = route.title
        cell.score.text = String(route.score)
        if route.score == 0 {
            cell.score.textColor = FlatWhite()
        } else if route.score < 0 {
            cell.score.textColor = FlatRed()
        } else if route.score > 0 {
            cell.score.textColor = FlatGreen()
        }
        
        cell.upvoteButton.backgroundColor = FlatOrangeDark()
        cell.downvoteButton.backgroundColor = FlatOrangeDark()
        
        cell.upvoteButton.tintColor = FlatBlackDark()
        cell.downvoteButton.tintColor = FlatBlackDark()
        
        cell.score.backgroundColor = FlatOrangeDark()
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
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
        navigationController?.navigationBar.tintColor = FlatOrange()
        navigationController?.navigationBar.barTintColor = FlatBlack()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    // MARK: Chameleon related
    func initChameleonColors() {
        view.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: view.frame, colors: [FlatBlack(), FlatOrange()])
    }
    
    // MARK: Sample Data
    private func loadSampleRoutes() {
        let sampleRoute_1 = Route(title: "Sample1", note: "Notes about Sample1", path: [Node(long: 1, lat: 1), Node(long: 2, lat: 2)], difficulty: 2, voted: false, upVotes: 5, downVotes: 2, privateRoute: false, user: "Austin McPhail", saved: false)
        
        routes += [sampleRoute_1]
    }

}
