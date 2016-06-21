//
//  MainRallyViewController.swift
//  Assassination
//
//  Created by Dylan on 5/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MainRallyViewController: UIViewController, DataStoreDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, RallyGameTableViewCellDelegate {
    
    let dataStore = DataManager.AppData
    var allGames : [Game]?
    var mapViewDoneButton : UIBarButtonItem?
    var mapView : MKMapView?
    
    @IBOutlet weak var AllGamesTableView: UITableView!
    
    override func viewDidLoad() {
        loadGames()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.dataStore.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dataStore.delegate = self
    }
    
    func loadGames() {
        APIManager.GetAllGames()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = allGames {
            return allGames!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RallyGameTableViewCell", forIndexPath: indexPath) as! RallyGameTableViewCell
        let game = allGames![indexPath.row]
        cell.game = game
        cell.LocationDescriptionLabel.text = game.description!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd hh:mm"
        switch game.gameType!.rawValue {
        case 0:
            cell.GameTypeLabel.text = "Default"
        case 1 :
            cell.GameTypeLabel.text = "Free For All"
        case 2:
            cell.GameTypeLabel.text = "Individual Targets"
        case 3:
            cell.GameTypeLabel.text = "Team"
        default:
            print("Something went wrong")
        }
        cell.delegate = self
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailsVC = self.storyboard?.instantiateViewControllerWithIdentifier("GameDetailsViewController") as! GameDetailsViewController
        let game = self.allGames![indexPath.row]
        detailsVC.game = game
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func ModelDidUpdate(message: String?) {
        allGames = dataStore.gameStore.games
        dispatch_async(dispatch_get_main_queue(), {
            self.AllGamesTableView.reloadData()
        })
    }
    
    func PresentEditGameView(game : Game) {
        let editGameVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditGameVC") as! EditGameViewController
        editGameVC.game = game
        self.navigationController?.pushViewController(editGameVC, animated: true)
    }
    
    func PresentMapForLocation(location : CLLocationCoordinate2D, description : String) {
        let YCoord : CGFloat = self.view.frame.height / 3.0
        let height : CGFloat = YCoord * 2.0
        self.mapView = MKMapView(frame: CGRectMake(0,YCoord,self.view.frame.width,height))
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegionMake(location, span)
        self.mapView!.setRegion(region, animated: true)
        let placemark = MKPointAnnotation()
        placemark.coordinate = location
        placemark.title = description
        self.mapView?.addAnnotation(placemark)
        self.view.addSubview(self.mapView!)
        addMapViewDoneButton()
    }
    
    func addMapViewDoneButton() {
        self.mapViewDoneButton = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(MainRallyViewController.dismissMapView))
        self.navigationItem.rightBarButtonItem = self.mapViewDoneButton!
    }
    
    func dismissMapView() {
        
        self.mapView?.removeFromSuperview()
        self.mapView = nil
        self.navigationItem.rightBarButtonItem = nil
        self.mapViewDoneButton = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "CreateGameSegue" {
            let destinationVC = segue.destinationViewController as! CreateGameViewController
            destinationVC.locationManager.startLocating(destinationVC)
        }
    }
}