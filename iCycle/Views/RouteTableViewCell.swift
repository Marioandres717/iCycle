//
//  RouteTableViewCell.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-12.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {
    //MARK: Attributes
    @IBOutlet weak var routeTitle: UILabel!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var routeStart: UILabel!
    @IBOutlet weak var routeEnd: UILabel!
    
    @IBOutlet weak var routeSaved: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
