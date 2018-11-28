//
//  LoginViewController.swift
//  iCycle
//
//  Created by Mario Rendon Zapata on 2018-11-26.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

//    @IBOutlet weak var loginBtn: UIButton!
//    @IBOutlet weak var signupBtn: UIButton!
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var stackView: UIStackView!
    
    let apiPath = "http://localhost:3000/v1/users/authenticate"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    setupView()
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupView() -> Void {
        setupTextFields()
        setupBtns()
    }
    
    // MARK: ACTIONS
    
    @IBAction func handleLogin(_ sender: UIButton) {
        
        guard let username = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        let parameters = ["username": username, "password": password]
        
        guard let url = URL(string: apiPath) else {return}
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
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
    }
    
    
    // MARK: UI STYLES
    
    func setupTextFields() -> Void {
        usernameTextField.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        
        var usernamePlaceholder = NSMutableAttributedString()
        
        usernamePlaceholder = NSMutableAttributedString(attributedString: NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
        
        usernameTextField.attributedPlaceholder = usernamePlaceholder
        
        passwordTextField.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        
        var passPlaceholder = NSMutableAttributedString()
        
        passPlaceholder = NSMutableAttributedString(attributedString: NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
        
        passwordTextField.attributedPlaceholder = passPlaceholder
    }
    
    func setupBtns() -> Void {
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.borderColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1).cgColor
        
        signupBtn.layer.cornerRadius = 5
        signupBtn.layer.borderWidth = 1
        signupBtn.layer.borderColor = UIColor(red: 255/255, green: 151/255, blue: 164/255, alpha: 1).cgColor
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
 */
}
