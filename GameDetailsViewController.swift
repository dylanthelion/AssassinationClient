//
//  GameDetailsViewController.swift
//  Assassination
//
//  Created by Dylan on 5/21/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GameDetailsViewController: UIViewController, DataStoreDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableViewMain: UITableView!
    @IBOutlet weak var JoinButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    var mapViewDoneButton : UIBarButtonItem?
    
    var dataStore : DataManager = DataManager.AppData
    var game : Game?
    var mapView : MKMapView?
    
    override func viewDidLoad() {
        if let _ = self.game {
            APIManager.GetGame(self.game!.id!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataStore.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataStore.delegate = nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.dataStore.gameStore.currentGame == nil {
            return 0
        }
        
        if section == 0 {
            return 6
        } else {
            return self.dataStore.gameStore.currentGame!.joinedPlayers!.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.dataStore.gameStore.currentGame == nil {
            return 0
        }
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 1 {
            if self.dataStore.gameStore.currentGame == nil {
                return "Players:"
            } else {
                return "Players: \(self.dataStore.gameStore.currentGame!.joinedPlayers!.count)"
            }
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwoColumnTableViewCell", forIndexPath: indexPath) as! TwoColumnTableViewCell
        if let _ = self.dataStore.gameStore.currentGame {
            switch indexPath.section {
            case 0:
                switch  indexPath.row {
                case 0:
                    cell.addLabels("Moderator:", textRight: self.dataStore.gameStore.currentGame!.moderator!)
                case 1:
                    cell.addLabels("Location:", textRight: self.dataStore.gameStore.currentGame!.description!)
                case 2:
                    cell.addLabels("Show Map", textRight: "")
                case 3:
                    cell.addLabels("Game Type:", textRight: "Individual Targets")
                case 4:
                    if let _ = self.game {
                        //self.dataStore.gameStore.currentGame?.startTime = self.game?.startTime!
                    }
                    let dateFormatter  = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    //cell.addLabels("Start Time:", textRight: dateFormatter.stringFromDate(self.dataStore.gameStore.currentGame!.startTime!))
                case 5:
                    cell.addLabels("Number of Players:", textRight: String(self.dataStore.gameStore.currentGame!.numberOfPlayers!))
                default:
                    print("Something went wrong")
                }
            default:
                cell.addLabels(dataStore.gameStore.currentGame!.joinedPlayers![indexPath.row], textRight: "")
            }
        } else {
            print("Game is nil")
        }
        let xCoord : CGFloat = 0.0
        let yCoord : CGFloat = 0.0
        let width : CGFloat = cell.frame.width / 2.0
        let height : CGFloat = cell.frame.height
        cell.LabelLeft?.frame = CGRectMake(xCoord, yCoord, width, height)
        cell.LabelRight?.frame = CGRectMake(width, yCoord, width, height)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0 && indexPath.row == 2) {
            if let _ = self.dataStore.gameStore.currentGame {
                self.addMap()
            }
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func ModelDidUpdate(message: String?) {
        if let _ = message {
            if(message! == "Game info") {
                dispatch_async(dispatch_get_main_queue(), {
                    self.TableViewMain.reloadData()
                    self.TableViewMain.reloadRowsAtIndexPaths(self.TableViewMain.indexPathsForVisibleRows!, withRowAnimation: .None)
                })
            } else if message! == "Targets set up! Get going!" {
                // Game local setup?
                self.updateInfoMessageLabel(message!, color: UIColor.greenColor())
            } else {
                let color : UIColor
                if message! == "Success!" {
                    color = UIColor.greenColor()
                } else {
                    color = UIColor.redColor()
                }
                self.updateInfoMessageLabel(message!, color: color)
            }
        }
    }
    
    func addMap() {
        let YCoord : CGFloat = 40.0
        let height : CGFloat = self.view.frame.height - YCoord
        self.mapView = MKMapView(frame: CGRectMake(0,YCoord,self.view.frame.width,height))
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let myLocation = self.dataStore.gameStore.currentGame!.locationCoordinate!
        let myCoords = CLLocationCoordinate2DMake(myLocation[0], myLocation[1])
        let region = MKCoordinateRegionMake(myCoords, span)
        
        self.mapView!.setRegion(region, animated: true)
        self.mapView!.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        let placemark = MKPointAnnotation()
        placemark.coordinate = myCoords
        placemark.title = self.dataStore.gameStore.currentGame!.description!
        self.mapView?.addAnnotation(placemark)
        self.view.addSubview(self.mapView!)
        addMapViewDoneButton()
    }
    
    func addMapViewDoneButton() {
        self.mapViewDoneButton = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(CreateGameViewController.dismissMapView))
        self.navigationItem.rightBarButtonItem = self.mapViewDoneButton!
    }
    
    func dismissMapView() {
        self.mapView?.removeFromSuperview()
        self.mapView = nil
        self.navigationItem.rightBarButtonItem = nil
        self.mapViewDoneButton = nil
    }
    
    @IBAction func JoinButtonPressed(sender: AnyObject) {
        if !self.dataStore.userStore.isValidUser || self.game == nil {
            return
        }
        
        APIManager.JoinGame(self.game!.id!)
    }
    
    @IBAction func DeleteButtonPressed(sender: AnyObject) {
        if !self.dataStore.userStore.isValidUser || self.game == nil {
            self.updateInfoMessageLabel("Account or game invalid", color: UIColor.redColor())
            return
        }
        let alertVC = UIAlertController(title: "Delete Game", message: "Are you sure?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("Delete cancelled")
        }
        alertVC.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.updateInfoMessageLabel("Deleting...", color: UIColor.orangeColor())
            APIManager.DeleteGame(self.game!.id!)
        }
        alertVC.addAction(OKAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    @IBAction func LeaveButtonPressed(sender: AnyObject) {
        if !self.dataStore.userStore.isValidUser || self.game == nil {
            return
        }
        
        APIManager.LeaveGame(self.game!.id!)
    }
    
    @IBAction func SetupButtonPressed(sender: AnyObject) {
        if !self.dataStore.userStore.isValidUser || self.game == nil {
            return
        }
        self.updateInfoMessageLabel("Setting up...", color: UIColor.orangeColor())
        APIManager.SetupGame(self.game!.id!)
    }
    
    
    func updateInfoMessageLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ErrorLabel.text = message
            self.ErrorLabel.textColor = color
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "PlaySegue" {
            if let check = segue.destinationViewController as? PlayIndividualTargetsViewController {
                check.gameId = self.game!.id!
            }
        }
    }
    
}