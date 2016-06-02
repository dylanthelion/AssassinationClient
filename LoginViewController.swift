//
//  LoginViewController.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, DataStoreDelegate, CLLocationManagerDelegate {
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends", "user_hometown"]
    let dataManager : DataManager = DataManager.AppData
    var locationManager : LocationManager = LocationManager.sharedManager

    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var FBLogoutButton: UIButton!
    @IBOutlet weak var CreateUserButton: UIButton!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var ProfilePicImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = self.facebookReadPermissions
        self.locationManager.startLocating(self)
        
        //checkLogin()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.dataManager.delegate = self
        checkLogin()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dataManager.delegate = nil
    }
    
    // Checks login status, and fetches data if needed. THIS NEEDS TO BE BROKEN UP SO BADLY WHERE'S YOKO?
    
    func checkLogin() {
        var loggedIn = false
        if !dataManager.userStore.isValidUser {
            dataManager.userStore.user = nil
        }
        self.dataManager.loadUserDataSync()
        if let check = dataManager.userStore.user {
            print("User found!")
            CreateUserButton.enabled = false
            loggedIn = true
            if let checkImage = dataManager.loadImageFromFile(check.Name!) {
                ProfilePicImage.image = checkImage
            }
            
        } else if FBSDKAccessToken.currentAccessToken() != nil {
            FBLoginButton.enabled = false
            FBLogoutButton.enabled = true
            if(dataManager.FBResults == nil) {
                if let check = dataManager.getFBTokenString() {
                    let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: check, version: nil, HTTPMethod: "GET")
                    req.startWithCompletionHandler({ (connection, getResult, error : NSError!) -> Void in
                        if(error == nil)
                        {
                            print("Logged in to FB!")
                            self.dataManager.FBResults = getResult as? Dictionary<String, String>
                            
                            let urlString = "https://graph.facebook.com/\(self.dataManager.FBResults!["id"]!)/picture?type=large"
                            let requestType = "GET"
                            let url = NSURL(string: urlString)!
                            
                            if let response = HTTPRequests.RequestManager.GetImageResponse(url, requestType: requestType, requestBody: nil) {
                                self.dataManager.saveImageToFile(response, name: self.dataManager.FBResults!["name"]!)
                            }
                            
                            self.performSegueWithIdentifier("CreateUser", sender: nil)
                        }
                        else
                        {
                            print("error \(error)")
                        }
                    })
                }
            }
            loggedIn = true
        } else {
            FBLoginButton.enabled = true
            FBLogoutButton.enabled = false
        }
        
        if(!loggedIn) {
            PlayButton.enabled = false
            PlayButton.hidden = true
            if let tabBarItems = self.tabBarController?.tabBar.items {
                tabBarItems[1].enabled = false
            }
        } else {
            PlayButton.enabled = true
            PlayButton.hidden = false
            if let tabBarItems = self.tabBarController?.tabBar.items {
                tabBarItems[1].enabled = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = segue.identifier {
            
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "CreateUser" && self.dataManager.userStore.isValidUser {
            return false
        }
        return true
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
                self.dataManager.userStore.addFBResultsToUser(result.token.tokenString, id: result.token.userID)
                dataManager.saveFBTokenString(result.token.tokenString)
                
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: result.token.tokenString, version: nil, HTTPMethod: "GET")
                req.startWithCompletionHandler({ (connection, getResult, error : NSError!) -> Void in
                    if(error == nil)
                    {
                        print("Logged in to FB!")
                        self.dataManager.FBResults = getResult as? Dictionary<String, String>
                        
                        let urlString = "https://graph.facebook.com/\(self.dataManager.FBResults!["id"]!)/picture?type=large"
                        let requestType = "GET"
                        let url = NSURL(string: urlString)!
                        
                        if let response = HTTPRequests.RequestManager.GetImageResponse(url, requestType: requestType, requestBody: nil) {
                            self.dataManager.saveImageToFile(response, name: self.dataManager.FBResults!["name"]!)
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
    
    // MARK: - FBLogin Delegate
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        FBSDKLoginManager().logOut()
        self.dataManager.userStore.logoutUserFB()
        //dataManager.deleteUserData()
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    // ACTION

    @IBAction func FBLogut(sender: AnyObject) {
        FBSDKLoginManager().logOut()
        FBLoginButton.enabled = true
        FBLogoutButton.enabled = false
    }
    
    func ModelDidUpdate(message: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.checkLogin()
        })
    }
}
