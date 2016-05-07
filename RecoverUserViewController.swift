//
//  RecoverUserViewController.swift
//  Assassination
//
//  Created by Dylan on 5/9/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class RecoverUserViewController: UIViewController, UITextFieldDelegate, DataStoreDelegate {
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    let dataManager = DataManager.AppData
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.dataManager.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dataManager.delegate = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func ModelDidUpdate(message: String?) {
        print("MDU in recover")
        if let _ = message {
            let textColor : UIColor
            if message! == "Success!" {
                textColor = UIColor.greenColor()
            } else {
                textColor = UIColor.redColor()
            }
            self.updateInfoMessageLabel(message!, color: textColor)
        } else if !self.dataManager.userStore.isValidUser {
            self.updateInfoMessageLabel("Incomplete user. Create an account!", color: UIColor.redColor())
        }
    }
    
    
    @IBAction func RecoverAccount(sender: AnyObject) {
        if(self.PasswordTextField.text!.characters.count < 10) {
            self.updateInfoMessageLabel("Password must be at least 10 characters", color: UIColor.redColor())
        }
        if self.EmailTextField.text?.characters.count < 10 {
            self.updateInfoMessageLabel("Please enter a valid email address", color: UIColor.redColor())
        }
        APIManager.RecoverAccountWithEmailAndPassword(self.EmailTextField.text!, password: self.PasswordTextField.text!)
        self.updateInfoMessageLabel("Recovering", color: UIColor.orangeColor())
    }
    
    func updateInfoMessageLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ErrorLabel.text = message
            self.ErrorLabel.textColor = color
        })
    }
}