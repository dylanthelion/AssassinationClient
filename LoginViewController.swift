//
//  LoginViewController.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_hometown"]
    
    let dataManager : DataManager = DataManager.AppData

    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    
    @IBOutlet weak var FBLogoutButton: UIButton!
    @IBOutlet weak var CreateUserButton: UIButton!
    
    @IBOutlet weak var PlayButton: UIButton!
    
    @IBOutlet weak var ProfilePicImage: UIImageView!
    
    var FBResults : Dictionary<String, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = self.facebookReadPermissions
        
        checkLogin()
        
    }
    
    func checkLogin() {
        var loggedIn = false
        
        if let _ = dataManager.appUser {
            CreateUserButton.enabled = false
            loggedIn = true
            if let checkImage = dataManager.loadImageFromFile(User.AppUserName!) {
                ProfilePicImage.image = checkImage
            }
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBLoginButton.enabled = false
            FBLogoutButton.enabled = true
            loggedIn = true
        } else {
            FBLoginButton.enabled = true
            FBLogoutButton.enabled = false
        }
        
        if(!loggedIn) {
            PlayButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let checkID = segue.identifier {
            
            if(checkID == "CreateUser") {
                //If account already created, fill fields from ViewDidLoad
                if let _ = dataManager.appUser {
                    return
                    // If logged in through Facebook, fill fields from login results
                } else if let _ = FBResults, destination = segue.destinationViewController as? CreateUserViewController {
                    destination.FBResults = FBResults
                }
            }
        }
    }
    
    // MARK: - FBLoginDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            FBSDKLoginManager().logOut()
        } else if result.isCancelled {
            FBSDKLoginManager().logOut()
        } else {
            var allPermsGranted = true
            let grantedPermissions = result.grantedPermissions.map( {"\($0)"} )
            for permission in self.facebookReadPermissions {
                if !grantedPermissions.contains(permission) {
                    allPermsGranted = false
                    break
                }
            }
            if allPermsGranted {
                
                User.FBAccessToken = result.token.tokenString
                User.FBUserID = result.token.userID
                
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: result.token.tokenString, version: nil, HTTPMethod: "GET")
                req.startWithCompletionHandler({ (connection, getResult, error : NSError!) -> Void in
                    if(error == nil)
                    {
                        print("Logged in to FB!")
                        self.FBResults = getResult as? Dictionary<String, String>
                        
                        let urlString = "https://graph.facebook.com/\(self.FBResults!["id"]!)/picture?type=large"
                        let requestType = "GET"
                        let url = NSURL(string: urlString)!
                        
                        if let response = HTTPRequests.RequestManager.GetImageResponse(url, requestType: requestType, requestBody: nil) {
                            self.dataManager.saveImageToFile(response, name: self.FBResults!["name"]!)
                        }
                        
                self.performSegueWithIdentifier("CreateUser", sender: nil)
                    }
                    else
                    {
                        print("error \(error)")
                    }
                })
            } else {
                print("Not all permissions were granted")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        FBSDKLoginManager().logOut()
        User.FBAccessToken = nil
        User.FBUserID = nil
        dataManager.deleteUserData()
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    @IBAction func FBLogut(sender: AnyObject) {
        FBSDKLoginManager().logOut()
        FBLoginButton.enabled = true
        FBLogoutButton.enabled = false
    }
}
