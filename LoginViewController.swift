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
    
    @IBOutlet weak var CreateUserButton: UIButton!
    
    @IBOutlet weak var PlayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBLoginButton.delegate = self
        FBLoginButton.readPermissions = self.facebookReadPermissions
        var loggedIn = false
        
        if let _ = dataManager.appUser {
            CreateUserButton.enabled = false
            loggedIn = true
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBLoginButton.enabled = false
            loggedIn = true
        }
        
        if(!loggedIn) {
            PlayButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                        print("result \(getResult)")
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
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

}
