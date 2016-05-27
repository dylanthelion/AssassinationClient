//
//  CreateUserViewController.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, DataStoreDelegate {

    @IBOutlet weak var AddPasswordLabel: UILabel!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var EmailTextBox: UITextField!
    @IBOutlet weak var UserNameTextBox: UITextField!
    @IBOutlet weak var PasswordTextBox: UITextField!
    @IBOutlet weak var ChangeProfilePicButton: UIButton!
    @IBOutlet weak var Checkbox: UIButton!
    
    let dataManager : DataManager = DataManager.AppData
    var checked : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        EmailTextBox.delegate = self
        UserNameTextBox.delegate = self
        PasswordTextBox.delegate = self
        loadUserData()
        
        if let tabBarItems = self.tabBarController?.tabBar.items {
            tabBarItems[1].enabled = false
        }
        self.dataManager.delegate = self
    }
    
    func loadUserData() {
        print("Load data")
        self.dataManager.loadUserData()
        
        dispatch_async(dispatch_get_main_queue(), {
            if let _ = self.dataManager.FBResults {
                self.ChangeProfilePicButton.hidden = true
                self.ChangeProfilePicButton.enabled = false
                self.AddPasswordLabel.hidden = false
                self.EmailTextBox.text = self.dataManager.FBResults!["email"]!
                self.UserNameTextBox.text = self.dataManager.FBResults!["name"]!
                if let checkImage = self.dataManager.loadImageFromFile(self.dataManager.FBResults!["name"]!) {
                    print("Image found")
                    self.ProfileImageView.image = checkImage
                } else {
                    self.ProfileImageView.image = UIImage(named: "user.png")
                }
            } else {
                self.ChangeProfilePicButton.hidden = true
                self.ChangeProfilePicButton.enabled = false
            }
        })
        
    }
    
    func updateInfoMessageLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.AddPasswordLabel.text = message
            self.AddPasswordLabel.textColor = color
        })
    }
    
    @IBAction func SubmitUser(sender: AnyObject) {
        
        if(checked) {
            AddDeviceToAccount()
        } else {
            CreateUser()
        }
    }
    
    @IBAction func SetProfilePic(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func AddDevice(sender: AnyObject) {
        if(checked) {
            checked = false
            Checkbox.setBackgroundImage(UIImage(named: "blank.png"), forState: .Normal)
        } else {
            checked = true
            Checkbox.setBackgroundImage(UIImage(named: "checked.jpg"), forState: .Normal)
        }
    }
    
    // MARK: - API funcs
    
    private func CreateUser() {
        
        if let name = UserNameTextBox.text, email = EmailTextBox.text, password = PasswordTextBox.text {
            
            if(password.characters.count < 10) {
                PasswordTextBox.text = "Must be at least 10 characters"
                PasswordTextBox.textColor = UIColor.redColor()
                return
            }
            
            APIManager.CreateUser(name, email: email, password: password)
            self.AddPasswordLabel.text = "Creating..."
            self.AddPasswordLabel.textColor = UIColor.orangeColor()
        }
    }
    
    private func AddDeviceToAccount() {
        print("ADD device")
        if let name = UserNameTextBox.text, email = EmailTextBox.text, password = PasswordTextBox.text {
            
            if(password.characters.count < 10) {
                PasswordTextBox.text = "Must be at least 10 characters"
                PasswordTextBox.textColor = UIColor.redColor()
                return
            }
            
            APIManager.AddDevice(name, password: password, email: email)
            self.AddPasswordLabel.text = "Adding..."
            self.AddPasswordLabel.textColor = UIColor.orangeColor()
        }
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
            //let HTTPManager = HTTPRequests.RequestManager
            let url = dataManager.PostImageURL
            if let _ = url {
                /*let response = HTTPManager.postImage(url!, image: imageToPost!)
                if(response.0) {
                    dataManager.saveProfilePic(imageToPost!)
                    ProfileImageView.image = imageToPost!
                } else {
                    print(response.1)
                    return
                }*/
            }
            
        }
    }
    
    // MARK: - TextView Delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK : - DataStoreDelegate
    
    func ModelDidUpdate(message : String?) {
        
        if let _ = message {
            let textColor : UIColor
            if message! == "Success!" {
                textColor = UIColor.greenColor()
            } else {
                textColor = UIColor.redColor()
            }
            self.updateInfoMessageLabel(message!, color: textColor)
        } else if !self.dataManager.userStore.isValidUser {
            self.updateInfoMessageLabel("Create an account!", color: UIColor.greenColor())
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
