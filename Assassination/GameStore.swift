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
    var currentGame : Game?
    
    class var AppGameStore: GameStore {
        return GameManager
    }
    
    func loadGames(loadedGames : [Game]) {
        games = loadedGames
    }
    
    func addGameToRally(game : Game) {
        print("Add game")
        if let _ = games {
            for localGame in games! {
                if localGame.id! == game.id! {
                    print("Game exists: \(game.id!)")
                    return
                }
            }
            print("Adding game: \(games!.count)")
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
    
    func getCurrentGame() -> Game? {
        return currentGame
    }
}