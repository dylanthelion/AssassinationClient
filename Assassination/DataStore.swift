//
//  DataStore.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let manager = DataManager()

class DataManager {
    
    let fileManager = NSFileManager.defaultManager()
    var appUser : User?
    var created : Bool = false
    var FBResults : Dictionary<String, String>?
    
    
    init() {
        loadUserData()
    }
    
    class var AppData: DataManager {
        return manager
    }
    
    var DocumentsDirectoryPath : NSURL {
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]
        return urls[0]
    }
    
    func loadUserData() {
        
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/UserData.plist")
        if(fileManager.fileExistsAtPath(path.path!)) {
            loadFromAppDirectory()
        }
    }
    
    func loadFromAppDirectory() {
        
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/UserData.plist")
        let dataEntry = NSDictionary(contentsOfFile: path.path!) as! Dictionary<String, String>
        
        if let checkID = dataEntry["ID"], checkName = dataEntry["Name"], checkEmail = dataEntry["Email"], checkPassword = dataEntry["Password"] {
            appUser = User(setID: Int(checkID)!, setName: checkName, setEmail: checkEmail, setPassword: checkPassword)
            created = true
        }
        
        if let _ = dataEntry["FBToken"], _ = dataEntry["FBID"] {
            User.FBAccessToken = dataEntry["FBToken"]
            User.FBUserID = dataEntry["FBID"]
        }
    }
    
    func saveUserData() {
        
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/UserData.plist")
        
        let dictionaryToWrite = buildDataToWrite()
        
        (dictionaryToWrite as NSDictionary).writeToURL(path, atomically: true)
        created = true
    }
    
    func deleteUserData() {
        
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/UserData.plist")
        
        if(!fileManager.fileExistsAtPath(path.path!)) {
            return
        }
        
        do {
            try fileManager.removeItemAtURL(path)
        } catch _ {
            print("Failed to delete UserData file")
        }
    }
    
    func buildDataToWrite() -> Dictionary<String, String> {
        
        var dictionaryToWrite = [String:String]()
        
        if let _ = appUser {
            dictionaryToWrite["ID"] = String(User.AppUserID!)
            dictionaryToWrite["Name"] = User.AppUserName!
            dictionaryToWrite["Email"] = User.AppUserEmail!
            dictionaryToWrite["Password"] = User.AppUserPassword!
            if let _ = User.FBAccessToken, _ = User.FBUserID {
                dictionaryToWrite["FBToken"] = User.FBAccessToken!
                dictionaryToWrite["FBID"] = User.FBUserID!
            }
            
        }
        
        return dictionaryToWrite
    }
    
    func saveImageToFile(image : UIImage, name : String) {
        
        let fileExtension = "/\(name)"
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent(fileExtension)
        
        let imageData = UIImagePNGRepresentation(image)
        fileManager.createFileAtPath(path.path!, contents: imageData, attributes: nil)
        
    }
    
    func loadImageFromFile(name : String) -> UIImage? {
        
        let fileExtension = "/\(name)"
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent(fileExtension)
        if(fileManager.fileExistsAtPath(path.path!)) {
            return UIImage(contentsOfFile: path.path!)
        }
        return nil
    }
    
    func updateUserImageName(oldName : String, newName : String) {
        if let checkImage = loadImageFromFile(oldName) {
            
            do {
               try fileManager.removeItemAtPath(oldName)
            } catch {
                print("Deletion failed")
            }
            
            saveImageToFile(checkImage, name: newName)
        }
    }
    
    func saveProfilePic(image : UIImage) {
        if let _ = appUser {
            saveImageToFile(image, name: User.AppUserName!)
        }
    }
    
    // API URLs
    
    var CreateUserURL : NSURL? {
        return NSURL(string: String(format: "%@/Account/CreateUser?UUID=%@", Constants.API_URL, UIDevice.currentDevice().identifierForVendor!.UUIDString))
    }
    
    var EditUserURL : NSURL? {
        
        if let _ = appUser {
            return NSURL(string: String(format: "%@/Account/EditUser?id=%@", Constants.API_URL, String(User.AppUserID)))
        }
        
        return nil
    }
    
    var DeleteUserURL : NSURL? {
        
        if let _ = appUser {
            return NSURL(string: String(format: "%@/Account/DeleteUser?playerID=%@&email=%@&password=%@", Constants.API_URL, String(User.AppUserID!), User.AppUserEmail!, User.AppUserPassword!))
        }
        
        return nil
    }
    
    var PostImageURL : NSURL? {
        
        if let _ = appUser {
            return NSURL(string: String(format: "%@/Image/SetImage?playerID=%@&password=%@", Constants.API_URL, String(User.AppUserID!), User.AppUserPassword!))
        }
        
        return nil
    }
    
    class func AddDeviceURL(name: String, password : String) -> NSURL? {
            return NSURL(string: String(format: "%@/Device/AddDeviceToAccount?userName=%@&password=%@&UUID=%@", Constants.API_URL, name, password, UIDevice.currentDevice().identifierForVendor!.UUIDString))
    }
}