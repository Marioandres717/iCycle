//
//  SignUpViewController.swift
//  iCycle
//
//  Created by Mario Rendon Zapata on 2018-11-26.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var passTextField: UITextField!
//    @IBOutlet weak var confirmPassTextField: UITextField!
//    @IBOutlet weak var saveBtn: UIButton!
//    @IBOutlet weak var cancelBtn: UIButton!
    
    let apiPath = "http://localhost:3000/v1/users"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    setupView()
    }
    
    /*
    // MARK: ACTIONS
    
    @IBAction func handleSave(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passTextField.text else { return }
        
        let parameters = ["email": email, "username": username, "password": password]
        
        guard let url = URL(string: apiPath) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            
            }.resume()
        dismiss(animated: true, completion: nil)
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
 */
}
