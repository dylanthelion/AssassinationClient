//
//  EditUserViewController.swift
//  Assassination
//
//  Created by Dylan on 1/11/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class EditUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ProfileImageView: UIImageView!
    
    @IBOutlet weak var SetNameTextView: UITextField!
    
    @IBOutlet weak var SetEmailTextView: UITextField!
    
    @IBOutlet weak var SetPasswordTextView: UITextField!
    
    let dataManager = DataManager.AppData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetNameTextView.delegate = self
        SetEmailTextView.delegate = self
        SetPasswordTextView.delegate = self
        if let _ = dataManager.appUser {
            loadAppUser()
        } else if let _ = dataManager.FBResults {
            loadFBUser()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func loadAppUser() {
        
        if let _ = User.AppUserEmail, _ = User.AppUserName, _ = User.AppUserPassword {
            print("User exists")
            SetEmailTextView.text = User.AppUserEmail!
            SetNameTextView.text = User.AppUserName!
            SetPasswordTextView.text = User.AppUserPassword!
            
            if let checkImage = dataManager.loadImageFromFile(User.AppUserName!) {
                ProfileImageView.image = checkImage
            } else {
                ProfileImageView.image = UIImage(named: "user.png")
            }
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
    }
    
    @IBAction func SetUserName(sender: AnyObject) {
    }
    
    @IBAction func SetEmail(sender: AnyObject) {
    }
    
    @IBAction func SetPassword(sender: AnyObject) {
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
}
