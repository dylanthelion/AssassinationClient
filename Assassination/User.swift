//
//  User.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation


class User {
    
    struct UserData {
        private static var ID : Int?
        private static var Name : String?
        private static var Email : String?
        private static var Password : String?
        private static var FBAccessToken : String?
        private static var FBUserID : String?
    }
    
    init() {
        
    }
    
    init(setID : Int, setName : String, setEmail : String, setPassword : String) {
        UserData.ID = setID
        UserData.Name = setName
        UserData.Email = setEmail
        UserData.Password = setPassword
    }
    
    class  var AppUserID: Int? {
        get { return UserData.ID }
        set { UserData.ID = newValue}
    }
    
    class var AppUserName: String? {
        get { return UserData.Name }
        set { UserData.Name = newValue }
    }
    
    class var AppUserPassword: String? {
        get { return UserData.Password }
        set { UserData.Password = newValue }
    }
    
    class var AppUserEmail: String? {
        get { return UserData.Email }
        set { UserData.Email = newValue }
    }
    
    class var FBAccessToken: String? {
        get { return UserData.FBAccessToken }
        set { UserData.FBAccessToken = newValue }
    }
    
    class var FBUserID: String? {
        get { return UserData.FBUserID }
        set { UserData.FBUserID = newValue }
    }
}