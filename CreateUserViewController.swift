//
//  CreateUserViewController.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {

    @IBOutlet weak var AddPasswordLabel: UILabel!
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    
    @IBOutlet weak var EmailTextBox: UITextField!
    
    @IBOutlet weak var UserNameTextBox: UITextField!
    
    @IBOutlet weak var PasswordTextBox: UITextField!
    
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
            AddPasswordLabel.hidden = false
            EmailTextBox.text = FBResults!["email"]!
            UserNameTextBox.text = FBResults!["name"]!
            if let checkImage = dataManager.loadImageFromFile(FBResults!["name"]!) {
                print("Image found")
                ProfileImageView.image = checkImage
            }
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
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                AddPasswordLabel.text = response.message
                AddPasswordLabel.textColor = UIColor.redColor()
                AddPasswordLabel.hidden = false
            }
        }
    }
    
    @IBAction func SetProfilePic(sender: AnyObject) {
    }
    
    
}
