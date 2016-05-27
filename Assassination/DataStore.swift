//
//  DataStore.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let manager = DataManager()

class DataManager : UserStoreDelegate {
    
    let fileManager = NSFileManager.defaultManager()
    let userStore = UserStore.currentUser
    let gameStore = GameStore.AppGameStore
    var created : Bool = false
    var FBResults : Dictionary<String, String>?
    var delegate : DataStoreDelegate?
    
    init() {
        self.userStore.delegate = self
        loadUserData()
    }
    
    class var AppData: DataManager {
        return manager
    }
    
    var DocumentsDirectoryPath : NSURL {
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]
        return urls[0]
    }
    
    // Loads user data. Called automatically from the login screen.
    
    func loadUserData() {
        dispatch_async(dispatch_get_main_queue(), {
            let path = self.DocumentsDirectoryPath.URLByAppendingPathComponent("UserData.plist")
            if(self.fileManager.fileExistsAtPath(path.path!)) {
                self.loadFromAppDirectory()
            }
            return
        })
    }
    
    // BE CAREFUL! Loading sync from a singleton can cause blocks and read errors
    
    func loadUserDataSync() {
        let path = self.DocumentsDirectoryPath.URLByAppendingPathComponent("UserData.plist")
        if(self.fileManager.fileExistsAtPath(path.path!)) {
            self.loadFromAppDirectory()
        }
    }
    
    // Loads user information from the App Directory
    
    func loadFromAppDirectory() {
        // If user has already been created, skip loading
        if self.userStore.isValidUser {
            return
        } else {
            self.userStore.user = nil
        }
        print("Load user")
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/UserData.plist")
        let dataEntry = NSDictionary(contentsOfFile: path.path!) as! Dictionary<String, String>
        if let checkID = dataEntry["ID"], checkName = dataEntry["Name"], checkEmail = dataEntry["Email"], checkPassword = dataEntry["Password"] {
            if let _ = dataEntry["FBToken"], _ = dataEntry["FBID"] {
                self.userStore.CreateUserFromProperties(Int(checkID)!, name: checkName, email: checkEmail, password: checkPassword, fbToken: dataEntry["FBToken"], fbId: dataEntry["FBID"])
            } else {
                self.userStore.CreateUserFromProperties(Int(checkID)!, name: checkName, email: checkEmail, password: checkPassword, fbToken: nil, fbId: nil)
            }
            created = true
            self.UserCreated(self.userStore.user!)
        }
    }
    
    // Saves User to Documents directory.
    
    func saveUserData() {
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/UserData.plist")
        
        let dictionaryToWrite = buildDataToWrite()
        
        (dictionaryToWrite as NSDictionary).writeToURL(path, atomically: true)
        created = true
    }
    
    // Deletes User form Documents directory. Called when account is cancelled, or logged out.
    
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
    
    // Saves FB token string, for fetching FB user data
    
    func saveFBTokenString(token : String) -> Bool {
        
        
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/FBToken.plist")
        do {
            try (token as NSString).writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            return false
        }
        
        return true
    }
    
    // Gets the FB Token for retrieving user data from FB server. Should only be called if user is logged in to FB, but has not set up an account.
    
    func getFBTokenString() -> String? {
        
        let path = DocumentsDirectoryPath.URLByAppendingPathComponent("/FBToken.plist")
        
        if(!fileManager.fileExistsAtPath(path.path!)) {
            return nil
        }
        
        do {
            return try NSString(contentsOfFile: path.path!, encoding: NSUTF8StringEncoding) as String
        } catch _ {
            return nil
        }
    }
    
    // Builds the Dictionary to write to UserData.plist
    
    func buildDataToWrite() -> Dictionary<String, String> {
        
        var dictionaryToWrite = [String:String]()
        
        if let check = self.userStore.user {
            dictionaryToWrite["ID"] = String(check.ID!)
            dictionaryToWrite["Name"] = check.Name!
            dictionaryToWrite["Email"] = check.Email!
            dictionaryToWrite["Password"] = check.Password!
            if let _ = check.FBAccessToken, _ = check.FBUserID {
                dictionaryToWrite["FBToken"] = check.FBAccessToken!
                dictionaryToWrite["FBID"] = check.FBUserID!
            }
            
        }
        
        return dictionaryToWrite
    }
    
    // I <3 DESCRIPTIVE METHOD NAMES
    
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
        if let check = self.userStore.user {
            saveImageToFile(image, name: check.Name!)
        }
    }
    
    // Store Delegates
    // MARK: - User Store
    
    func UserCreated(user: User) {
        if let _ = self.delegate {
            self.delegate?.ModelDidUpdate("Success!")
        }
    }
    
    func UserDeleted() {
        if let _ = self.delegate {
            self.delegate?.ModelDidUpdate("Deleted!")
        }
    }
    
    func UserUpdated(newUser: User) {
        if let _ = self.delegate {
            self.delegate?.ModelDidUpdate("Success!")
        }
    }
    
    func UserAPIActionFailed(message : String?) {
        if let _ = self.delegate {
            if let _ = message {
                self.delegate?.ModelDidUpdate(message!)
            } else {
                self.delegate?.ModelDidUpdate("Something went wrong")
            }
        }
    }
    
    func UserAPIActionSuccessful(message : String?) {
        if let _ = self.delegate {
            if let _ = message {
                self.delegate?.ModelDidUpdate(message!)
            } else {
                self.delegate?.ModelDidUpdate("Problem parsing response")
            }
        }
    }
    
    // API URLs
    
    var CreateUserURL : NSURL? {
        return NSURL(string: String(format: "%@Account/CreateUser?UUID=%@", Constants.API_URL, UIDevice.currentDevice().identifierForVendor!.UUIDString))
    }
    
    var EditUserURL : NSURL? {
        
        if let check = self.userStore.user {
            return NSURL(string: String(format: "%@Account/EditUser?id=%@", Constants.API_URL, String(check.ID!)))
        }
        
        return nil
    }
    
    var DeleteUserURL : NSURL? {
        
        if let check = self.userStore.user {
            return NSURL(string: String(format: "%@Account/DeleteUser?playerID=%@&email=%@&password=%@", Constants.API_URL, String(check.ID!), check.Email!, check.Password!))
        }
        
        return nil
    }
    
    var PostImageURL : NSURL? {
        
        if let check = self.userStore.user {
            return NSURL(string: String(format: "%@Image/SetImage?playerID=%@&password=%@", Constants.API_URL, String(check.ID!), check.Password!))
        }
        
        return nil
    }
    
    func AddDeviceURL(name: String, password : String) -> NSURL? {
        return NSURL(string: String(format: "%@Device/AddDeviceToAccount?userName=%@&password=%@&UUID=%@", Constants.API_URL, name, password, UIDevice.currentDevice().identifierForVendor!.UUIDString).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
    
    func ChangePasswordURL(name: String, oldPassword: String, newPassword: String, email: String, id: String) -> NSURL? {
        return NSURL(string: String(format: "%@ManageAccount/ChangePassword?playerID=%@&userName=%@&email=%@&oldPassword=%@&newPassword=%@", Constants.API_URL, id, name, email, oldPassword, newPassword).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
    
    func GetUserDataWithEmailURL(email: String, password: String) -> NSURL? {
        return NSURL(string: String(format: "%@ManageAccount/GetUserDataWithEmail?email=%@&password=%@", Constants.API_URL, email, password).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
    
    func CreateGameURL(playerId : Int, password : String) -> NSURL? {
        return NSURL(string: String(format: "%@Game/CreateGame?playerID=%@&password=%@", Constants.API_URL, String(playerId), password).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
    
    var GetAllGamesURL : NSURL? {
        return NSURL(string: String(format: "%@Rally/AllGames", Constants.API_URL))
    }
    
    func EditGameURL(playerId : Int, password: String, gameId : Int) -> NSURL? {
        return NSURL(string: String(format: "%@Game/EditGame?playerID=%@&password=%@&gameID=%@", Constants.API_URL, String(playerId), password, String(gameId)).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
    
    func DeleteGameURL(playerId : Int, password: String, gameId : Int) -> NSURL? {
        return NSURL(string: String(format: "%@Game/DeleteGame?gameID=%@&playerID=%@&password=%@", Constants.API_URL, String(gameId), String(playerId), password).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
    
    func JoinGameURL(playerId : Int, password: String, gameId : Int) -> NSURL? {
        return NSURL(string: String(format: "%@Rally/JoinGame?gameID=%@&playerID=%@&password=%@", Constants.API_URL, String(gameId), String(playerId), password).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    }
}

protocol DataStoreDelegate {
    func ModelDidUpdate(message : String?)
}