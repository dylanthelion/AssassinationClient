//
//  APIManager.swift
//  Assassination
//
//  Created by Dylan on 1/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

class APIManager {
    
    init() {
        
    }
    
    class func CreateUser(name: String, email: String, password: String) -> (success : Bool, message : String) {
        
        let dataManager = DataManager.AppData
        
        let url = dataManager.CreateUserURL
        let requestType = "POST"
        var requestBody = Dictionary<String, String>()
        requestBody["UserName"] = name
        requestBody["Email"] = email
        requestBody["Password"] = password
        
        if let response = HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: requestBody) {
            
            if(((response[0] as NSString).substringToIndex(2) as String) == "ID") {
                if let id = response[0].getNumericPostscript() {
                    dataManager.appUser = User(setID: id, setName: name, setEmail: email, setPassword: password)
                    dataManager.saveUserData()
                    return (true, String(id))
                }
            }
            
            return (false, response[0])
        }
        
        
        return (false, "Something went wrong")
    }
    
    class  func AddDevice(name: String, password: String, email: String) -> (success : Bool, message : String) {
        
        let dataManager = DataManager.AppData
        let url = DataManager.AddDeviceURL(name, password: password)
        let requestType = "POST"
        
        if let response = HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: nil) {
            
            if(((response[0] as NSString).substringToIndex(2) as String) == "ID") {
                if let id = response[0].getNumericPostscript() {
                    dataManager.appUser = User(setID: id, setName: name, setEmail: email, setPassword: password)
                    dataManager.saveUserData()
                    return (true, String(id))
                }
            }
            
            return (false, response[0])
        }
        
        
        return (false, "Something went wrong")
    }
}