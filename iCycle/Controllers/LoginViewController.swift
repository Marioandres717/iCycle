//
//  LoginViewController.swift
//  iCycle
//
//  Created by Mario Rendon Zapata on 2018-11-26.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, URLSessionDelegate, URLSessionDataDelegate {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    var session: URLSession?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    func setupView() -> Void {
        setupTextFields()
        setupBtns()
    }
    
//    @objc func handleLogout() {
//        print("calling")
//        UserDefaults.standard.set(false, forKey: "isLoggedIn")
//        UserDefaults.standard.synchronize()
//    }
    
    // MARK: ACTIONS
    @IBAction func handleLogin(_ sender: UIButton) {
        guard let username = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        let parameters = ["username": username, "password": password]
        print("username: \(username) & password: \(password)")

        HttpConfig.postRequestConfig(url: UrlBuilder.getUserByUsernameAndPassword(), parameters: parameters)
        
        let sessionConfig = HttpConfig.sessionConfig()

        self.session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        if let task = self.session?.dataTask(with: HttpConfig.request) {
            task.resume()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {return}
        print(json)
        
        if let res = json as? [String: Any] {
            if let err = res["statusCode"] as? Int, let message = res["message"] as? String {
                DispatchQueue.main.async {
                    let alert = ErrorHandler.handleError(title: "Login Error",message: message + " \(err)")
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let user = User(json: res)!
                    let isSucessfulSave = User.saveUser(user: user)
                    if isSucessfulSave {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        self.performSegue(withIdentifier: "startApp", sender: nil)
                    } else {
                        let alert = ErrorHandler.handleError(title: "Unexpected error", message: "Try again")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
      }
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
}

// MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide Keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Actions
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
}
