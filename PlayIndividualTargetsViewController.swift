//
//  PlayIndividualTargetsViewController.swift
//  Assassination
//
//  Created by Dylan on 6/2/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PlayIndividualTargetsViewController:  UIViewController, DataStoreDelegate, WebSocketDelegate, CLLocationManagerDelegate,
UITextFieldDelegate {
    
    let dataStore = DataManager.AppData
    var gameId : Int?
    let locationManager = LocationManager.sharedManager
    var socket : WebSocket!
    var targetLastLocation : CLLocationCoordinate2D?
    var targetName : String?
    var isGettingPlayers = false
    var targetPin : MKPlacemark?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtFieldMessage: UITextField!
    @IBOutlet weak var btnKill: UIButton!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var lblPlayers: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.startLocating(self)
        self.connectToGame()
        self.setUpMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataStore.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataStore.delegate = nil
        self.socket?.disconnect()
        self.socket?.delegate = nil
    }
    
    func ModelDidUpdate(message: String?) {
        if message! == "Successful kill!" {
            self.updateInfoMessageLabel(message!, color: UIColor.greenColor())
            return
        }
        let splitMessage = message?.componentsSeparatedByString(",")
        if splitMessage?.count == 4 {
            let checkLat = (splitMessage![2] as NSString).doubleValue
            let checkLong = (splitMessage![3] as NSString).doubleValue
            if checkLat != 0.0 && checkLong != 0.0 {
                self.targetLastLocation = CLLocationCoordinate2DMake(checkLat, checkLong)
                self.targetName = splitMessage![1]
                if let _ = self.mapView {
                    self.updateTargetLocation()
                }
            }
        } else {
            self.updateInfoPlayersLabel(message!, color: UIColor.blackColor())
        }
    }
    
    func connectToGame() {
        if self.gameId != nil && self.dataStore.userStore.isValidUser {
            let IndividualTargetsPath = String(format: "JoinIndividualTargetsGame/JoinGame?gameID=%@&playerID=%@&password=%@", String(self.gameId!), String(self.dataStore.userStore.user!.ID!), self.dataStore.userStore.user!.Password!).stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
            let url = NSURL(string: String(format: "ws://assassinationgame.azurewebsites.net/api/%@", IndividualTargetsPath))!
            print("URL: \(url.path!)")
            self.socket = WebSocket(url: url)
            socket.delegate = self
            self.socket!.connect()
        }
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error!.localizedDescription)")
    }
    
    func websocketDidWriteError(error: NSError?) {
        print("wez got an error from the websocket: \(error!.localizedDescription)")
        APIManager.JoinIndividualTargetsGameGetError(self.gameId!, location: self.locationManager.location!.coordinate)
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
        let check = text.rangeOfString("Target")
        if check != nil {
            self.updateInfoPlayersLabel(text, color: UIColor.blackColor())
        } else {
            self.updateInfoMessageLabel(text, color: UIColor.blackColor())
        }
        
        if let _ = self.locationManager.location {
            if !self.isGettingPlayers {
                self.getPlayers()
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("got some data: \(data.length)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if let _ = self.gameId, _ = self.dataStore.delegate, _ = self.socket {
            APIManager.UpdateLocation(gameId!, newLocation: newLocation.coordinate)
            let stringToSend = "\(String(self.gameId!)),\(self.dataStore.userStore.user!.Name!),\(String(newLocation.coordinate.latitude)),\(String(newLocation.coordinate.longitude))"
            self.socket?.writeString(stringToSend)
            if let _ = self.targetLastLocation {
                if self.checkIfWithinKillDistance(newLocation.coordinate) {
                    self.btnKill.enabled = true
                } else {
                    self.btnKill.enabled = false
                }
            }
        }
    }
    
    func setUpMap() {
        if let _ = self.locationManager.location {
            let coords = self.locationManager.location!.coordinate
            let span = MKCoordinateSpanMake(0.5, 0.5)
            //self.mapView.setCenterCoordinate(coords, animated: true)
            let region = MKCoordinateRegionMake(coords, span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        }
    }
    
    
    @IBAction func sendMessage(sender: AnyObject) {
        if let _ = self.socket, _ = self.txtFieldMessage.text, _ = self.gameId {
            print("send message")
            let message = "\(String(self.gameId!)),\(self.dataStore.userStore.user!.Name!): \(self.txtFieldMessage.text!))"
            print("Message to send: \(message)")
            self.socket!.writeString(message)
            if let _ = self.socket!.delegate {
                print("Delegate is fine")
            } else {
                print("Delegate is null")
            }
        }
    }
    
    @IBAction func Kill(sender: AnyObject) {
        if let _ = self.gameId, _ = self.locationManager.location, _ = self.targetName {
            APIManager.KillIndividualTargets(self.gameId!, newLocation: self.locationManager.location!.coordinate, target: self.targetName!)
        }
    }
    
    func updateInfoMessageLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.lblError.text = message
            self.lblError.textColor = color
        })
    }
    
    func updateInfoPlayersLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.lblPlayers.text = message
            self.lblPlayers.textColor = color
            self.isGettingPlayers = false
        })
    }
    
    func checkIfWithinKillDistance(location : CLLocationCoordinate2D) -> Bool {
        let distance : Double = sqrt(pow(Double(location.latitude - self.targetLastLocation!.latitude) * 111131.745, 2) + pow(Double(location.longitude - self.targetLastLocation!.longitude) * 78846.805720, 2));
        print("Distance to target: \(distance)")
        if distance <= 11.0 {
            return true
        } else {
            return false
        }
    }
    
    func getPlayers() {
        if self.isGettingPlayers {
            return
        }
        self.isGettingPlayers = true
        APIManager.GetPlayers(self.gameId!)
    }
    
    func updateTargetLocation() {
        if let _ = self.targetPin {
            self.mapView.removeAnnotation(self.targetPin!)
            self.targetPin = MKPlacemark(coordinate: self.targetLastLocation!, addressDictionary: nil)
            self.mapView.addAnnotation(self.targetPin!)
        } else {
            self.targetPin = MKPlacemark(coordinate: self.targetLastLocation!, addressDictionary: nil)
            self.mapView.addAnnotation(self.targetPin!)
        }
    }
}