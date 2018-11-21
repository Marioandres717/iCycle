//
//  SignupViewController.swift
//  iCycle
//
//  Created by Mario Rendon on 2018-11-20.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    // MARK: ACTIONS
    
    @IBAction func handleSave(_ sender: UIButton) {
        print("saved")
    }
    
    @IBAction func handleCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: UI STYLES
    
    func setupView() {
        setupTextFields()
        setupBtns()
    }
    
    func setupTextFields() {
        
        emailTextField.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        var emailPlaceholder = NSMutableAttributedString()
        emailPlaceholder = NSMutableAttributedString(attributedString: NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
        emailTextField.attributedPlaceholder = emailPlaceholder
        
        usernameTextField.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        var usernamePlaceholder = NSMutableAttributedString()
        usernamePlaceholder = NSMutableAttributedString(attributedString: NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
        usernameTextField.attributedPlaceholder = usernamePlaceholder
        
        passTextField.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        var passPlaceholder = NSMutableAttributedString()
        passPlaceholder = NSMutableAttributedString(attributedString: NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
        passTextField.attributedPlaceholder = passPlaceholder
        
        confirmPassTextField.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        var confirmPassPlaceholder = NSMutableAttributedString()
        confirmPassPlaceholder = NSMutableAttributedString(attributedString: NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
        confirmPassTextField.attributedPlaceholder = confirmPassPlaceholder
        
    }
    
    func setupBtns() {
        saveBtn.layer.cornerRadius = 5
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.borderColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1).cgColor
        
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor(red: 255/255, green: 151/255, blue: 164/255, alpha: 1).cgColor
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
