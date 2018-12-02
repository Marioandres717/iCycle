//
//  ProfileViewController.swift
//  iCycle
//
//  Created by Austin McPhail on 2018-11-10.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit
import ChameleonFramework

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var notesKeyboard: Bool = false
    var bikeChanges: Bool = false
    
    var user: User?

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
        
        saveChangesButton.isEnabled = false;
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
        myBikePhoto.image = user?.bikeImage ?? nil
        myBikeSerialNumber.text = user?.bikeSerialNumber ?? ""
        myBikeBrand.text = user?.bikeBrand ?? ""
        myBikeNotes.text = user?.bikeNotes ?? ""
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
    
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            myBikePhoto.image = editImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myBikePhoto.image = originalImage
        }
    
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
