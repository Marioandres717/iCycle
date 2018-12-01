//
//  SignUpViewController.swift
//  iCycle
//
//  Created by Mario Rendon Zapata on 2018-11-26.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, URLSessionDelegate, URLSessionDataDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var session: URLSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    // MARK: ACTIONS
    
    @IBAction func handleSubmit(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passTextField.text else { return }
        
        let parameters = ["email": email, "username": username, "password": password]
        
        HttpConfig.postRequestConfig(url: UrlBuilder.createUser(), parameters: parameters)
        
        let sessionConfig = HttpConfig.sessionConfig()
        
        self.session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        if let task = self.session?.dataTask(with: HttpConfig.request) {
            task.resume()
        }
    }
    
    
    @IBAction func handleCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
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
        submitBtn.layer.cornerRadius = 5
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1).cgColor
        
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor(red: 255/255, green: 151/255, blue: 164/255, alpha: 1).cgColor
    }
}
