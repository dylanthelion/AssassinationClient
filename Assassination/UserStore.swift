//
//  UserStore.swift
//  Assassination
//
//  Created by Dylan on 5/6/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let AppUser = UserStore()

class UserStore {
    
    var user : User?
    var delegate : UserStoreDelegate?
    
    class var currentUser: UserStore {
        return AppUser
    }
    
    init() {
        
    }
    
    var isValidUser: Bool {
        if let check = self.user {
            if let _ = check.ID, _ = check.Email, _ = check.Name, _ = check.Password {
                return true
            }
        }
        
        return false
    }
    
    func CreateUser(newUser : User) {
        if(newUser.ID == nil || newUser.Email == nil || newUser.Name == nil || newUser.Password == nil) {
            return
        }
        self.user = newUser
        if let _ = self.delegate {
            self.delegate?.UserCreated(self.user!)
        }
    }
    
    func CreateUserFromProperties(id : Int, name : String, email : String, password : String, fbToken : String?, fbId : String?) {
        if let _ = self.user {
            self.user?.ID = id
            self.user?.Name = name
            self.user?.Email = email
            self.user?.Password = password
            self.user?.FBAccessToken = fbToken
            self.user?.FBUserID = fbId
            if let _ = self.delegate {
                self.delegate?.UserCreated(self.user!)
            }
            return
        }
        let newUser = User()
        newUser.ID = id
        newUser.Name = name
        newUser.Email = email
        newUser.Password = password
        newUser.FBAccessToken = fbToken
        newUser.FBUserID = fbId
        self.user = newUser
        if let _ = self.delegate {
            self.delegate?.UserCreated(self.user!)
        }
    }
    
    func addFBResultsToUser(token : String, id : String) {
        if self.user == nil {
            self.user = User()
        }
        self.user?.FBAccessToken = token
        self.user?.FBUserID = id
    }
    
    func logoutUserFB() {
        if self.user == nil {
            return
        }
        self.user?.FBUserID = nil
        self.user?.FBAccessToken = nil
    }
    
    func getUser() -> User? {
        return self.user
    }
}

protocol UserStoreDelegate {
    func UserCreated(user : User)
    func UserUpdated(newUser : User)
    func UserDeleted()
    func UserAPIActionFailed(message : String?)
}