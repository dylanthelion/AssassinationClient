//
//  Game.swift
//  Assassination
//
//  Created by Dylan on 5/12/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation
import CoreLocation

class Game {
    
    var id : Int?
    var locationCoordinate : [CLLocationDegrees]?
    var description : String?
    var numberOfPlayers : Int?
    var radiusInMeters : Int?
    var startTime : NSDate?
    var isActiveGame : Bool?
    var gameLength : Int?
    var gameType : GameType?
    
    init() {
        id = 0
        isActiveGame = false
        gameType = .IndividualTargets
    }
}

enum GameType : Int {
    case Default
    case FreeForAll
    case IndividualTargets
    case Team
}