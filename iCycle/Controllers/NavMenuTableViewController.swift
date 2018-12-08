//
//  NavMenuTableViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-10.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import ChameleonFramework

class NavMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = FlatBlack() // Customize the Color of the background
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

}
