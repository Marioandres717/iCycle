//
//  RouteTableViewCell.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-12.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import ChameleonFramework

class RouteTableViewCell: UITableViewCell {
    //MARK: Attributes
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var difficulty: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var savedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
