//
//  RouteTableViewCell.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-12.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import Chameleon

class RouteTableViewCell: UITableViewCell {
    //MARK: Attributes
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var difficulty: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var author: UILabel!
    
    var route: Route?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.text = route?.title
        
        switch(route?.difficulty) {
        case 1:
            difficulty.text = "Low"
            difficulty.textColor = FlatGreen()
        case 2:
            difficulty.text = "Medium"
            difficulty.textColor = FlatYellow()
        case 3:
            difficulty.text = "High"
            difficulty.textColor = FlatRed()
        default:
            difficulty.text = "Low"
            difficulty.textColor = FlatGreen()
            break
        }
        
        distance.text = "_ Km"
        
        if let scoreValue = route?.score {
            score.text = String(scoreValue)
        }
        
        author.text = "USERNAME"
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
