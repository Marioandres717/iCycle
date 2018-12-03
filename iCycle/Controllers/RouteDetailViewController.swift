//
//  RouteDetailViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-10.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import ChameleonFramework

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
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var hasUpvoted: Bool = false
    var hasDownvoted: Bool = false
    
    var route: Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initChameleonColors()
        
        hasUpvoted = false
        hasDownvoted = false
        
        if let route = route {
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
            
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
