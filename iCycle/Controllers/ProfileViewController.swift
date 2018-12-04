//
//  ProfileViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-10.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URLSessionDelegate, URLSessionDataDelegate {
    
    var notesKeyboard: Bool = false
    var bikeChanges: Bool = false
    
    var user: User?
    var session: URLSession?
    var firebasePicURL: String? // we need this in the case that the request to the server fails, we use this reference to delete the image in firestorage

    @IBOutlet weak var myUsername: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var myRoutesButton: UIButton!
    @IBOutlet weak var myPhotosButton: UIButton!
    @IBOutlet weak var myBikePhoto: UIImageView!
    @IBOutlet weak var myBikeSerialNumber: UITextField!
    @IBOutlet weak var myBikeBrand: UITextField!
    @IBOutlet weak var myBikeNotes: UITextView!
    @IBOutlet weak var savedRoutes: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var bikeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.loadUser()!
        addUserInfoToView()
        
        saveChangesButton.backgroundColor = FlatGray()
        
        // Delegates
        myBikeSerialNumber.delegate = self
        myBikeBrand.delegate = self
        myBikeNotes.delegate = self
        // Customization
        sideMenu()
        customizeNavBar()
        initChameleonColors()
        
        // Listen for Keyboard Events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        // Stop Listening for Keyboard Events
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func addUserInfoToView() {
        myUsername.text = user?.userName ?? ""
        myBikeSerialNumber.text = user?.bikeSerialNumber ?? ""
        myBikeBrand.text = user?.bikeBrand ?? ""
        myBikeNotes.text = user?.bikeNotes ?? ""
        let urlToImage = user?.bikeImage ?? ""
        print("url to image \(urlToImage)")
        if urlToImage != "" {
            let storageRef = Storage.storage().reference(forURL: urlToImage)
            let maxSize: Int64 = 3 * 1024 * 1024 // 3MB
            storageRef.getData(maxSize: maxSize) { (data, error) in
                if let error = error {
                    print(error)
                    self.myBikePhoto.image = UIImage(named: "placeholder")
                } else {
                    print("Sucessfully fetched image")
                    self.myBikePhoto.image = UIImage(data: data!)
                }
            }
        } else {
            self.myBikePhoto.image = UIImage(named: "placeholder")
        }
        
    }
    
    @IBAction func addNewImage(_ sender: UITapGestureRecognizer) {
        myBikeBrand.resignFirstResponder()
        myBikeSerialNumber.resignFirstResponder()
        myBikePhoto.resignFirstResponder()
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let displayCamera = UIAlertAction(title: "Camera", style: .default) { action in
            self.addImageToProfile(optionSelected: "camera")
        }
        
        let displayPhotoLib = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.addImageToProfile(optionSelected: "library")
        }
        
        actionSheet.addAction(displayCamera)
        actionSheet.addAction(displayPhotoLib)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func addImageToProfile(optionSelected: String) {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        imgPickerController.allowsEditing = true
    
        if optionSelected == "camera" {
            imgPickerController.sourceType = .camera

        } else if optionSelected == "library" {
            imgPickerController.sourceType = .photoLibrary
            
        } else {
            fatalError("Invalid action")
        }
        imgPickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: imgPickerController.sourceType)!
        
        present(imgPickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage  {
            myBikePhoto.image = editImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myBikePhoto.image = originalImage
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage(completion: @escaping ((_ url: URL?) ->())) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "profile/\(imageName).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        let data = myBikePhoto.image?.jpegData(compressionQuality: 0.8)
        storageRef.putData(data!, metadata: uploadMetaData) { (metadata, error) in
            if (error != nil){
                print("ERROR: \(String(describing: error?.localizedDescription))")
            } else {
                print("upload complete! metadata: \(String(describing: metadata))")
                storageRef.downloadURL { (url, error) in
                  completion(url)
                }
            }
        }
    }
    
    func deleteImageFromFirebaseStorage() {
        let storage = Storage.storage()
        let url = self.firebasePicURL
        let storageRef = storage.reference(forURL: url!)
        storageRef.delete { error in
            if let error = error {
                print("\(error)")
            } else {
                print("image sucessfully deleted")
            }
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier) {
        case "viewSavedRoutes":
            guard let routeTableViewController = segue.destination as? RouteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            routeTableViewController.showSavedRoutes = true
            routeTableViewController.showAllRoutes = false
            routeTableViewController.showMyRoutes = false
            break
        case "viewMyRoutes":
            guard let routeTableViewController = segue.destination as? RouteTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            routeTableViewController.showSavedRoutes = false
            routeTableViewController.showAllRoutes = false
            routeTableViewController.showMyRoutes = true
            break
        default:
            fatalError("Unexpected segue: \(segue.identifier)")
            break
        }
    }
    
    // MARK: Customization
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.tintColor = FlatGreen()
        navigationController?.navigationBar.barTintColor = FlatBlack()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    func initChameleonColors() {
        view.backgroundColor = FlatBlack()
        
        myPhotosButton.backgroundColor = FlatForestGreen()
        myPhotosButton.layer.cornerRadius = 5
        myPhotosButton.layer.borderWidth = 1
        myPhotosButton.layer.borderColor = FlatGreen().cgColor

        savedRoutes.backgroundColor = FlatForestGreen()
        savedRoutes.layer.cornerRadius = 5
        savedRoutes.layer.borderWidth = 1
        savedRoutes.layer.borderColor = FlatGreen().cgColor
        
        saveChangesButton.backgroundColor = FlatSkyBlue()
        saveChangesButton.layer.cornerRadius = 5
        saveChangesButton.layer.borderWidth = 1
        saveChangesButton.layer.borderColor = FlatWhite().cgColor
        
        myRoutesButton.backgroundColor = FlatForestGreen()
        myRoutesButton.layer.cornerRadius = 5
        myRoutesButton.layer.borderWidth = 1
        myRoutesButton.layer.borderColor = FlatGreen().cgColor
        
        bikeView.layer.cornerRadius = 5
        bikeView.layer.borderWidth = 1
        bikeView.layer.borderColor = FlatGreen().cgColor
    }
    
    // MARK: Keyboard
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if myBikeNotes.isFirstResponder {
                view.frame.origin.y = -keyboardHeight
                notesKeyboard = true
            } else {
                notesKeyboard = false
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if notesKeyboard == true {
                view.frame.origin.y += keyboardHeight
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func handleSaveChanges(_ sender: UIButton) {
        guard let bikeSerial = myBikeSerialNumber.text else {return}
        guard let bikeBrand = myBikeBrand.text else {return}
        guard let bikeNotes = myBikeNotes.text else {return}
    
        uploadImageToFirebaseStorage() { (url) in
            self.firebasePicURL = url?.absoluteString
            let parameters = ["bikeSerialNumber": bikeSerial, "bikeBrand": bikeBrand, "bikeNotes": bikeNotes, "bikePhoto": url!.absoluteString] as [String : Any]
            
            HttpConfig.putRequestConfig(url: UrlBuilder.editUser(id: self.user!.id), parameters: parameters)
            
            let sessionConfig = HttpConfig.sessionConfig()
            
            self.session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            
            if let task = self.session?.dataTask(with: HttpConfig.request) {
                task.resume()
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {return}
        print(json)
        
        if let res = json as? [String: Any] {
            if let err = res["statusCode"] as? Int, let message = res["message"] as? String {
                DispatchQueue.main.async {
                    let alert = ErrorHandler.handleError(title: "Update profile Error",message: message + " \(err)")
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                        print("successfully update user!")
                        let updatedUser = User(json: res)
                        let sucessfullySaved = User.saveUser(user: updatedUser!)
                        if sucessfullySaved {
                            let oldImageURL = self.user?.bikeImage
                            self.user = User.loadUser()!
                            // if the user change their bike picture then delete the old picture
                            if oldImageURL != self.user?.bikeImage {
                                self.firebasePicURL = oldImageURL
                                self.deleteImageFromFirebaseStorage()
                            }
                        }
                    }
                }
            }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // request to api fail, deleting the image on fireStorage
        if error != nil {
            deleteImageFromFirebaseStorage()
            DispatchQueue.main.async {
                let alert = ErrorHandler.handleError(title: "Update profile Error",message: "It wasn't possible to edit user")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide Keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: UITextViewDelegate
extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
}
