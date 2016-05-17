//
//  GameStore.swift
//  Assassination
//
//  Created by Dylan on 5/17/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let GameManager = GameStore()

class GameStore {
    
    var games : [Game]?
    
    class var AppGameStore: GameStore {
        return GameManager
    }
    
    func loadGames(loadedGames : [Game]) {
        games = loadedGames
    }
    
    func addGameToRally(game : Game) {
        if let _ = games {
            games!.append(game)
        } else {
            games = [game]
        }
    }
    
    func GetAllGames() -> (Bool, [Game]?) {
        if let _ = self.games {
            return (true, games!)
        }
        return (false, nil)
    }
}