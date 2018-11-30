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
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var difficultyView: UIView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var upvoteView: UIView!
    @IBOutlet weak var downvoteView: UIView!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    
    @IBOutlet weak var notes: UITextView!
    
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
                break
            case 2:
                difficultyLabel.text = "Medium"
                break
            case 3:
                difficultyLabel.text = "High"
                break
            default:
                break
            }
            
            navBar.title = route.title
            
            notes.text = route.note
            
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
        
        upvoteButton.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: upvoteView.frame, colors: [FlatBlackDark(), FlatGreen()])
        
        downvoteButton.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: downvoteView.frame, colors: [FlatBlackDark(), FlatSkyBlue()])
    }

    @IBAction func upvotePressed(_ sender: Any) {
        if (hasDownvoted == true) {
            hasDownvoted = false;
            downvoteButton.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: downvoteView.frame, colors: [FlatBlackDark(), FlatSkyBlue()])
            
            hasUpvoted = true;
            upvoteButton.backgroundColor = FlatGreen();
        } else if (hasUpvoted == true) {
            hasUpvoted = false;
            upvoteButton.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: upvoteView.frame, colors: [FlatBlackDark(), FlatGreen()])
            
        } else if (hasUpvoted == false) {
            hasUpvoted = true;
            upvoteButton.backgroundColor = FlatGreen();
        }
    }
    
    @IBAction func downvotePressed(_ sender: Any) {
        if (hasUpvoted == true) {
            hasUpvoted = false;
            upvoteButton.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: upvoteView.frame, colors: [FlatBlackDark(), FlatGreen()])
            
            hasDownvoted = true;
            downvoteButton.backgroundColor = FlatSkyBlue();
        } else if (hasDownvoted == true) {
            hasDownvoted = false;
            downvoteButton.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: downvoteView.frame, colors: [FlatBlackDark(), FlatSkyBlue()])
            
        } else if (hasDownvoted == false) {
            hasDownvoted = true;
            downvoteButton.backgroundColor = FlatSkyBlue();
        }
    }
    
}
