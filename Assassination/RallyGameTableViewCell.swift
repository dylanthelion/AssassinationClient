//
//  RallyGameTableViewCell.swift
//  Assassination
//
//  Created by Dylan on 5/17/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import CoreLocation

class RallyGameTableViewCell: UITableViewCell {
    
    var delegate : RallyGameTableViewCellDelegate?
    var game : Game?
    
    @IBOutlet weak var StartTimeLabel: UILabel!
    @IBOutlet weak var LocationDescriptionLabel: UILabel!
    @IBOutlet weak var GameTypeLabel: UILabel!
    
    @IBAction func showMap(sender: AnyObject) {
        if let _ = game {
            delegate?.PresentMapForLocation(CLLocationCoordinate2D(latitude: game!.locationCoordinate![0], longitude: game!.locationCoordinate![1]), description: (game?.description!)!)
        }
        
    }
    
    @IBAction func edit(sender: AnyObject) {
        if let _ = game {
            delegate?.PresentEditGameView(game!)
        }
    }
    
    
}

protocol RallyGameTableViewCellDelegate {
    func PresentEditGameView(game : Game)
    func PresentMapForLocation(location : CLLocationCoordinate2D, description : String)
}