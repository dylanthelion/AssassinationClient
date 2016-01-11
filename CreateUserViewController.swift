//
//  CreateUserViewController.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var AddPasswordLabel: UILabel!
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    
    @IBOutlet weak var EmailTextBox: UITextField!
    
    @IBOutlet weak var UserNameTextBox: UITextField!
    
    @IBOutlet weak var PasswordTextBox: UITextField!
    
    @IBOutlet weak var ChangeProfilePicButton: UIButton!
    
    let dataManager : DataManager = DataManager.AppData
    
    var FBResults : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        loadUserData()
    }
    
    func loadUserData() {
        print("Load data")
        if let _ = dataManager.appUser {
            
            if let _ = User.AppUserEmail, _ = User.AppUserName, _ = User.AppUserPassword {
                print("User exists")
                EmailTextBox.text = User.AppUserEmail!
                UserNameTextBox.text = User.AppUserName!
                PasswordTextBox.text = User.AppUserPassword!
                
                if let checkImage = dataManager.loadImageFromFile(User.AppUserName!) {
                    ProfileImageView.image = checkImage
                }
            }
        } else if let _ = FBResults {
            print("Load FB results")
            ChangeProfilePicButton.hidden = true
            ChangeProfilePicButton.enabled = false
            AddPasswordLabel.hidden = false
            EmailTextBox.text = FBResults!["email"]!
            UserNameTextBox.text = FBResults!["name"]!
            if let checkImage = dataManager.loadImageFromFile(FBResults!["name"]!) {
                print("Image found")
                ProfileImageView.image = checkImage
            }
        } else {
            ChangeProfilePicButton.hidden = true
            ChangeProfilePicButton.enabled = false
        }
    }
    
    @IBAction func SubmitUser(sender: AnyObject) {
        if let name = UserNameTextBox.text, email = EmailTextBox.text, password = PasswordTextBox.text {
            
            if(password.characters.count < 10) {
                PasswordTextBox.text = "Must be at least 10 characters"
                PasswordTextBox.textColor = UIColor.redColor()
                return
            }
            
            let response = APIManager.CreateUser(name, email: email, password: password)
            
            if(response.success) {
                AddPasswordLabel.hidden = true
                ChangeProfilePicButton.hidden = false
                ChangeProfilePicButton.enabled = true
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                AddPasswordLabel.text = response.message
                AddPasswordLabel.textColor = UIColor.redColor()
                AddPasswordLabel.hidden = false
            }
        }
    }
    
    @IBAction func SetProfilePic(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - ImagePickerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        var imageToPost : UIImage? = nil
        
        if let editedPic = info["UIImagePickerControllerEditedImage"] as? UIImage {
            imageToPost = editedPic
        } else if let uneditedPic = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageToPost = uneditedPic
        } else {
            print("Something went wrong")
            return
        }
        
        if let _ = imageToPost {
            let HTTPManager = HTTPRequests.RequestManager
            let url = dataManager.PostImageURL
            if let _ = url {
                let response = HTTPManager.postImage(url!, image: imageToPost!)
                if(response.0) {
                    dataManager.saveProfilePic(imageToPost!)
                    ProfileImageView.image = imageToPost!
                } else {
                    print(response.1)
                    return
                }
            }
            
        }
    }
    
}
