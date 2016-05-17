//
//  EditUserViewController.swift
//  Assassination
//
//  Created by Dylan on 1/11/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class EditUserViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DataStoreDelegate {

    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var SetNameTextView: UITextField!
    @IBOutlet weak var SetEmailTextView: UITextField!
    @IBOutlet weak var SetPasswordTextView: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var ConfirmPasswordButton: UIButton!
    @IBOutlet weak var ConfirmPasswordLabel: UILabel!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    var changePassword = false
    let dataManager = DataManager.AppData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetNameTextView.delegate = self
        SetEmailTextView.delegate = self
        SetPasswordTextView.delegate = self
        if dataManager.userStore.isValidUser {
            loadAppUser()
        } else if let _ = dataManager.FBResults {
            loadFBUser()
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("Appear")
        self.dataManager.delegate = self
        self.ConfirmPasswordButton.setTitle("Change", forState: .Normal)
        self.ConfirmPasswordLabel.hidden = true
        self.ConfirmPasswordTextField.text = ""
        self.ConfirmPasswordTextField.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("Disappear")
        self.dataManager.delegate = nil
        changePassword = false
    }
    
    func loadAppUser() {
        
        if self.dataManager.userStore.isValidUser {
            print("User exists")
            dispatch_async(dispatch_get_main_queue(), {
                self.SetEmailTextView.text = self.dataManager.userStore.user?.Email!
                self.SetNameTextView.text = self.dataManager.userStore.user?.Name
                self.SetPasswordTextView.text = self.dataManager.userStore.user?.Password!
            
                if let checkImage = self.dataManager.loadImageFromFile((self.dataManager.userStore.user?.Name!)!) {
                    self.ProfileImageView.image = checkImage
                } else {
                    self.ProfileImageView.image = UIImage(named: "user.png")
                }
            })
        }
    }
    
    func loadFBUser() {
        
        print("Load FB results")
        SetEmailTextView.text = dataManager.FBResults!["email"]!
        SetNameTextView.text = dataManager.FBResults!["name"]!
        if let checkImage = dataManager.loadImageFromFile(dataManager.FBResults!["name"]!) {
            print("Image found")
            ProfileImageView.image = checkImage
        } else {
            ProfileImageView.image = UIImage(named: "user.png")
        }
    }
    
    @IBAction func SetProfilePic(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func SetEmail(sender: AnyObject) {
        self.changeUserNameOrEmail()
    }
    
    @IBAction func SetPassword(sender: AnyObject) {
        
        if !self.dataManager.userStore.isValidUser {
            return
        }
        
        if changePassword {
            if(self.SetEmailTextView.text! != self.dataManager.userStore.user?.Email! || self.SetNameTextView.text! != self.dataManager.userStore.user?.Name!) {
                self.errorLabel.text = "Incorrect username or email."
                self.errorLabel.textColor = UIColor.redColor()
                return
            }
            
            if(self.SetPasswordTextView.text! != self.ConfirmPasswordTextField.text!) {
                self.errorLabel.text = "Passwords don't match"
                self.errorLabel.textColor = UIColor.redColor()
                return
            }
            
            if(self.SetPasswordTextView.text!.characters.count < 10) {
                self.errorLabel.text = "Must be at least 10 characters"
                self.errorLabel.textColor = UIColor.redColor()
                return
            }
            APIManager.ChangePassword(self.ConfirmPasswordTextField.text!)
            self.errorLabel.text = "Updating..."
            self.errorLabel.textColor = UIColor.orangeColor()
        } else {
            changePassword = true
            self.ConfirmPasswordButton.setTitle("Confirm?", forState: .Normal)
            self.ConfirmPasswordLabel.hidden = false
            self.ConfirmPasswordTextField.hidden = false
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
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
            /*let HTTPManager = HTTPRequests.RequestManager
            let url = dataManager.PostImageURL
            if let _ = url {
                // Image controller is not set up yet
                HTTPManager.postImage(url!, image: imageToPost!, completion: {(parsedResponse : [String]) -> Void in
                    print("Handling")
                    if(((parsedResponse[0] as NSString).substringToIndex(7) as String) == "User ID") {
                        print("Success: \(parsedResponse[0] as NSString)")
                    } else {
                        print("Failed")
                        DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
                    }
                })
            }*/
            
        }
    }
    
    func changeUserNameOrEmail() {
        
        if !self.dataManager.userStore.isValidUser {
            return
        }
        
        if let name = SetNameTextView.text, email = SetEmailTextView.text, password = SetPasswordTextView.text {
            
            if(password != self.dataManager.userStore.user?.Password!) {
                self.errorLabel.text = "Incorrect password."
                self.errorLabel.textColor = UIColor.redColor()
                return
            }
            
            APIManager.EditUser(name, password: password, email: email)
            self.errorLabel.text = "Updating..."
            self.errorLabel.textColor = UIColor.orangeColor()
        }
    }
    
    func ModelDidUpdate(message : String?) {
        print("MDU in edit")
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
        }
        
        self.loadAppUser()
    }
    
    func updateInfoMessageLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorLabel.text = message
            self.errorLabel.textColor = color
        })
    }
}
