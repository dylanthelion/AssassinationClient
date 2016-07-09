//
//  APIManager.swift
//  Assassination
//
//  Created by Dylan on 1/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

class APIManager {
    
    var userStoreDelegate : UserStoreDelegate?
    
    init() {
        
    }
    
    class func CreateUser(name: String, email: String, password: String) {
        
        let dataManager = DataManager.AppData
        
        let url = dataManager.CreateUserURL
        let requestType = "POST"
        var requestBody = Dictionary<String, AnyObject>()
        requestBody["UserName"] = name
        requestBody["Email"] = email
        requestBody["Password"] = password
        requestBody["ID"] = 0
        
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: requestBody, completion: {(parsedResponse : [String]) -> Void in
            if(((parsedResponse[0] as NSString).substringToIndex(2) as String) == "ID") {
                if let id = parsedResponse[0].getNumericPostscript() {
                    DataManager.AppData.userStore.CreateUserFromProperties(id, name: name, email: email, password: password, fbToken: nil, fbId: nil)
                    DataManager.AppData.saveUserData()
                }
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
        
    }
    
    class  func AddDevice(name: String, password: String, email: String) {
        let dataManager = DataManager.AppData
        
        let url = dataManager.AddDeviceURL(name, password: password)
        let requestType = "POST"
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : [String]) -> Void in
            if(((parsedResponse[0] as NSString).substringToIndex(7) as String) == "User ID") {
                print("Success: \(parsedResponse[0] as NSString)")
                if let id = parsedResponse[0].getNumericPostscript() {
                    DataManager.AppData.userStore.CreateUserFromProperties(id, name: name, email: email, password: password, fbToken: nil, fbId: nil)
                    DataManager.AppData.saveUserData()
                }
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func EditUser(name: String, password: String, email: String) {
        let dataManager = DataManager.AppData
        let url = dataManager.EditUserURL
        let requestType = "PUT"
        var requestBody = Dictionary<String, AnyObject>()
        requestBody["UserName"] = name
        requestBody["Email"] = email
        requestBody["Password"] = password
        requestBody["ID"] = dataManager.userStore.user?.ID!
        
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: requestBody, completion: {(parsedResponse : [String]) -> Void in
            if((parsedResponse[0] as NSString) == "Changed!") {
                DataManager.AppData.userStore.CreateUserFromProperties((dataManager.userStore.user?.ID!)!, name: name, email: email, password: password, fbToken: nil, fbId: nil)
                DataManager.AppData.saveUserData()
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func ChangePassword(password: String) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            DataManager.AppData.UserAPIActionFailed("User not created yet")
        }
        let url = dataManager.ChangePasswordURL(dataManager.userStore.user!.Name!, oldPassword: dataManager.userStore.user!.Password!, newPassword: password, email: dataManager.userStore.user!.Email!, id: String(dataManager.userStore.user!.ID!))
        let requestType = "PUT"
        
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : [String]) -> Void in
            if((parsedResponse[0] as NSString) == "Changed!") {
                DataManager.AppData.userStore.CreateUserFromProperties((dataManager.userStore.user?.ID!)!, name: dataManager.userStore.user!.Name!, email: dataManager.userStore.user!.Email!, password: password, fbToken: dataManager.userStore.user!.FBAccessToken, fbId: dataManager.userStore.user!.FBUserID)
                DataManager.AppData.saveUserData()
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func RecoverAccountWithEmailAndPassword(email: String, password: String) {
        
        let dataManager = DataManager.AppData
        let url = dataManager.GetUserDataWithEmailURL(email, password: password)
        let requestType = "GET"
        
        HTTPRequests.RequestManager.GetJSONResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : Dictionary<String, AnyObject>) -> Void in
            if let _ = parsedResponse["ID"] {
            DataManager.AppData.userStore.CreateUserFromProperties(Int((parsedResponse["ID"]! as! NSString).intValue), name: parsedResponse["UserName"]! as! String, email: email, password: password, fbToken: dataManager.userStore.user!.FBAccessToken, fbId: dataManager.userStore.user!.FBUserID)
                DataManager.AppData.saveUserData()
            } else {
                DataManager.AppData.UserAPIActionFailed("Unknown error")
            }
            }, errorHandler: {(parsedResponse : [String]) -> Void in
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
        })
    }
    
    class func CreateGame(game : Game) {
        
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.CreateGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!)
        let requestType = "POST"
        var body = Dictionary<String, AnyObject>()
        body["ID"] = game.id!
        body["Location"] = ["ID" : 0, "Latitude" : game.locationCoordinate![0], "Longitude" : game.locationCoordinate![1], "Altitude" : 0]
        body["LocationDescription"] = game.description!
        body["NumberOfPlayers"] = game.numberOfPlayers!
        body["RadiusInMeteres"] = game.radiusInMeters!
        let dateFormatter  = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        body["StartTime"] = dateFormatter.stringFromDate(game.startTime!)
        body["IsActiveGame"] = game.isActiveGame!
        body["GameLengthInMinutes"] = game.gameLength!
        body["GameType"] = game.gameType!.rawValue
        
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: body, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString).substringToIndex(4) == "Game" {
                DataManager.AppData.UserAPIActionSuccessful("Success!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func GetAllGames() {
        let dataManager = DataManager.AppData
        let url = DataManager.AppData.GetAllGamesURL
        let requestType = "GET"
        HTTPRequests.RequestManager.GetJSONArrayOfObjectsResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : [AnyObject]) -> Void in
            if let _ = parsedResponse[0] as? NSDictionary {
                print("Number: \(parsedResponse.count)")
                for game in parsedResponse {
                    let parsedGame = game as! NSDictionary
                    let parsedLocation = parsedGame["Location"] as! NSDictionary
                    let gameToLoad = Game()
                    gameToLoad.description = parsedGame["LocationDescription"]! as? String
                    gameToLoad.gameLength = parsedGame["GameLengthInMinutes"]! as? Int
                    gameToLoad.gameType = GameType(rawValue: (parsedGame["GameType"]! as? Int)!)
                    gameToLoad.id = parsedGame["ID"]! as? Int
                    gameToLoad.isActiveGame = parsedGame["IsActiveGame"]! as? Bool
                    gameToLoad.locationCoordinate = [CLLocationDegrees(parsedLocation["Latitude"]! as! Double),  CLLocationDegrees(parsedLocation["Longitude"]! as! Double)]
                    gameToLoad.numberOfPlayers = parsedGame["NumberOfPlayers"]! as? Int
                    gameToLoad.radiusInMeters = parsedGame["RadiusInMeters"]! as? Int
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    gameToLoad.startTime = dateFormatter.dateFromString(parsedGame["StartTime"]! as! String)
                    dataManager.gameStore.addGameToRally(gameToLoad)
                }
                dataManager.UserAPIActionSuccessful("Success!")
            } else {
                dataManager.UserAPIActionFailed("Failed to load games from server")
            }
        })
    }
    
    class func DeleteGame(gameId : Int) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.DeleteGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let requestType = "DELETE"
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString) == "Deleted!" {
                DataManager.AppData.UserAPIActionSuccessful("Success!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func EditGame(game : Game) {
        
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.EditGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: game.id!)
        let requestType = "PUT"
        var body = Dictionary<String, AnyObject>()
        body["ID"] = game.id!
        body["Location"] = ["ID" : 0, "Latitude" : game.locationCoordinate![0], "Longitude" : game.locationCoordinate![1], "Altitude" : 0]
        body["LocationDescription"] = game.description!
        body["NumberOfPlayers"] = game.numberOfPlayers!
        body["RadiusInMeters"] = game.radiusInMeters!
        let dateFormatter  = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        body["StartTime"] = dateFormatter.stringFromDate(game.startTime!)
        body["IsActiveGame"] = game.isActiveGame!
        body["GameLengthInMinutes"] = game.gameLength!
        body["GameType"] = game.gameType!.rawValue
        var game = Dictionary<String, AnyObject>()
        game["game"] = body
        
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: game, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString).substringToIndex(4) == "Game" {
                DataManager.AppData.UserAPIActionSuccessful("Success!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func GetGame(gameId : Int) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.GetGameURL(gameId)
        let requestType = "GET"
        HTTPRequests.RequestManager.GetJSONResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : Dictionary<String, AnyObject>) -> Void in
            if let _ = parsedResponse["Moderator"] {
                let currentGame = Game()
                currentGame.description = (parsedResponse["Location"]! as! String)
                let checkGameType : String = parsedResponse["Game Type"]! as! String
                switch checkGameType {
                case "IndividualTargets" :
                    currentGame.gameType = GameType.IndividualTargets
                case "FreeForAll" :
                    currentGame.gameType = GameType.FreeForAll
                case "Team" :
                    currentGame.gameType = GameType.Team
                default :
                    print("Failed to parse game type: \(checkGameType)")
                }
                currentGame.id = gameId
                currentGame.joinedPlayers = (parsedResponse["Players"] as! [String])
                currentGame.locationCoordinate = [Double(parsedResponse["Latitude"] as! String)!, Double(parsedResponse["Longitude"] as! String)!]
                currentGame.moderator = (parsedResponse["Moderator"] as! String)
                currentGame.numberOfPlayers = Int(parsedResponse["Needed"] as! String)
                //let date =  parsedResponse["StartTime"] as! String
                //Date returned from server is currently in short form: hh:mm. Use date passed from Rally
                currentGame.startTime = NSDate()
                DataManager.AppData.gameStore.currentGame = currentGame
                DataManager.AppData.UserAPIActionSuccessful("Game info")
            } else {
                DataManager.AppData.UserAPIActionFailed("Unknown error")
            }
            }, errorHandler: {(parsedResponse : [String]) -> Void in
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
        })
    }
    
    class func JoinGame(gameId : Int) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        //let url = dataManager.JoinGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let url = dataManager.JoinGameURL(4, password: "dylan1dylan1", gameId: gameId)
        let requestType = "PUT"
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString) == "Joined!" {
                DataManager.AppData.UserAPIActionSuccessful("Success!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func LeaveGame(gameId : Int) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        //let url = dataManager.LeaveGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let url = dataManager.LeaveGameURL(4, password: "dylan1dylan1", gameId: gameId)
        let requestType = "DELETE"
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString) == "Removed!" {
                DataManager.AppData.UserAPIActionSuccessful("Success!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func SetupGame(gameId : Int) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.SetupGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let requestType = "POST"
        let body = []
        // Team game not set up yet
        HTTPRequests.RequestManager.GetJSONArrayResponseWithArrayBody(url, requestType: requestType, requestBody: body as [AnyObject], completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString) == "Targets set up! Get going!" {
                DataManager.AppData.UserAPIActionSuccessful("Targets set up! Get going!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func UpdateLocation(gameId : Int, newLocation : CLLocationCoordinate2D) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.UpdateLocationURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let requestType = "POST"
        var body = Dictionary<String, AnyObject>()
        body["Latitude"] = newLocation.latitude
        body["Longitude"] = newLocation.longitude
        body["Altitude"] = 0.0
        // Team game not set up yet
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: body, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString) == "Updated!" {
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func KillIndividualTargets(gameId : Int, newLocation : CLLocationCoordinate2D, target : String) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.KillPlayerURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId, TargetName: target)
        let requestType = "DELETE"
        var body = Dictionary<String, AnyObject>()
        body["Latitude"] = newLocation.latitude
        body["Longitude"] = newLocation.longitude
        body["Altitude"] = 0.0
        // Team game not set up yet
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: body, completion: {(parsedResponse : [String]) -> Void in
            if(parsedResponse[0] as NSString) == "Kill!" {
                DataManager.AppData.UserAPIActionSuccessful("Successful kill!")
            } else {
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
            }
        })
    }
    
    class func JoinIndividualTargetsGameGetError(gameId : Int, location : CLLocationCoordinate2D) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.JoinIndividualTargetsGameURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let requestType = "GET"
        var body = Dictionary<String, AnyObject>()
        body["Latitude"] = location.latitude
        body["Longitude"] = location.longitude
        body["Altitude"] = 0.0
        // Team game not set up yet
        HTTPRequests.RequestManager.GetJSONArrayResponse(url, requestType: requestType, requestBody: body, completion: {(parsedResponse : [String]) -> Void in
            
            DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
        })
    }
    
    class func GetPlayers(gameId : Int) {
        let dataManager = DataManager.AppData
        if !dataManager.userStore.isValidUser {
            return
        }
        
        let url = dataManager.GetPlayersURL(dataManager.userStore.user!.ID!, password: dataManager.userStore.user!.Password!, gameId: gameId)
        let requestType = "GET"
        
        HTTPRequests.RequestManager.GetJSONResponse(url, requestType: requestType, requestBody: nil, completion: {(parsedResponse : Dictionary<String, AnyObject>) -> Void in
            if let _ = parsedResponse["Targets"] {
                let targets = parsedResponse["Targets"] as! [String]
                let players = parsedResponse["NonTargets"] as! [String]
                var message = "Targets-"
                for target in targets {
                    message += " \(target),"
                }
                message += " Others-"
                for player in players {
                    message += " \(player),"
                }
                    DataManager.AppData.UserAPIActionSuccessful(message)
            } else {
                DataManager.AppData.UserAPIActionFailed("Unknown error")
            }
            }, errorHandler: {(parsedResponse : [String]) -> Void in
                DataManager.AppData.UserAPIActionFailed(parsedResponse[0])
        })
    }
}