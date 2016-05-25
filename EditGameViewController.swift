//
//  EditGameViewController.swift
//  Assassination
//
//  Created by Dylan on 5/18/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class EditGameViewController: CreateGameViewController {
    
    var game : Game?
    
    @IBOutlet weak var EditAddressTextField: UITextField!
    @IBOutlet weak var EditDescriptionTextField: UITextField!
    @IBOutlet weak var EditNumberOfPlayersTextField: UITextField!
    @IBOutlet weak var EditRadiusInMetersTextField: UITextField!
    @IBOutlet weak var EditGameTypeTextField: UITextField!
    @IBOutlet weak var EditStartTimeTextField: UITextField!
    @IBOutlet weak var EditGameLengthTextField: UITextField!
    @IBOutlet weak var EditErrorLabel: UILabel!
    @IBOutlet weak var EditFromMapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.dataStore.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dataStore.delegate = nil
    }
    
    override func ModelDidUpdate(message: String?) {
        if let _ = message {
            let color : UIColor
            if message! == "Success!" {
                color = UIColor.greenColor()
            } else {
                color = UIColor.redColor()
            }
            self.updateInfoMessageLabel(message!, color: color)
        }
    }
    
    func setUp() {
        if self.game == nil {
            return
        }
        
        if let _ = self.game?.description {
            self.EditDescriptionTextField.text = self.game!.description!
        }
        
        if let _ = self.game?.gameLength {
            self.EditGameLengthTextField.text = String(self.game!.gameLength!)
        }
        
        if let _ = self.game?.gameType {
            switch self.game!.gameType! {
            case GameType.Default:
                self.EditGameTypeTextField.text = "Default"
            case GameType.FreeForAll :
                self.EditGameTypeTextField.text = "Free For All"
            case GameType.IndividualTargets :
                self.EditGameTypeTextField.text = "Individual Targets"
            case GameType.Team :
                self.EditGameTypeTextField.text = "Team"
            }
        }
        
        if let _ = self.game?.numberOfPlayers {
            self.EditNumberOfPlayersTextField.text = String(self.game!.numberOfPlayers!)
        }
        
        if let _ = self.game?.radiusInMeters {
            self.EditRadiusInMetersTextField.text = String(self.game!.radiusInMeters!)
        }
        
        if let _ = self.game?.startTime {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            self.EditStartTimeTextField.text = dateFormatter.stringFromDate((self.game!.startTime!))
        }
        
        if let _ = self.game?.locationCoordinate {
            self.currentlySelectedLocation = self.game!.locationCoordinate!
        }
    }
    
    @IBAction func Delete(sender: AnyObject) {
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
            print("setup delete")
            self.updateInfoMessageLabel("Deleting...", color: UIColor.orangeColor())
            APIManager.DeleteGame(self.game!.id!)
        }
        alertVC.addAction(OKAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func Edit(sender: AnyObject) {
        if let _ = self.EditAddressTextField.text {
            CLGeocoder().geocodeAddressString(self.EditAddressTextField.text!, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    self.updateInfoMessageLabel(error!.localizedDescription, color: UIColor.redColor())
                    return
                }
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    let address = pm.location?.coordinate
                    self.currentlySelectedLocation = [(address?.latitude)!, (address?.longitude)!]
                }
            })
        }
        
        var description : String = self.EditDescriptionTextField.text!
        if description == "" {
            description = "None"
        }
        
        let numberOfPlayers : Int = Int((self.EditNumberOfPlayersTextField.text! as NSString).intValue)
        let radiusInMeters : Int = Int((self.EditRadiusInMetersTextField.text! as NSString).intValue)
        let gameLength : Int = Int((self.EditGameLengthTextField.text! as NSString).intValue)
        if (numberOfPlayers < 5 || radiusInMeters < 100 || gameLength < 10) {
            self.updateInfoMessageLabel("Problems parsing numerical fields. Players must be 5, Radius must 100, length must be 10", color: UIColor.redColor())
            return
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let startTime : NSDate? = dateFormatter.dateFromString(self.EditStartTimeTextField.text!)
        self.game?.locationCoordinate = self.currentlySelectedLocation!
        self.game?.description = description
        self.game?.gameLength = gameLength
        self.game?.numberOfPlayers = numberOfPlayers
        self.game?.radiusInMeters = radiusInMeters
        if(startTime!.timeIntervalSinceNow > 0) {
            self.game?.startTime = startTime!
        }
        
        self.updateInfoMessageLabel("Creating...", color: UIColor.orangeColor())
        APIManager.EditGame(self.game!)
    }
    
    @IBAction func EditFromMapButtonPressed(sender: AnyObject) {
        self.addMap()
    }
    
    override func disableTextFieldsForCustomInputView(enabledViewTag : Int) {
        print("Tag to disable: \(enabledViewTag)")
        self.EditAddressTextField.userInteractionEnabled = false
        self.EditDescriptionTextField.userInteractionEnabled = false
        self.EditRadiusInMetersTextField.userInteractionEnabled = false
        self.EditGameLengthTextField.userInteractionEnabled = false
        if enabledViewTag == 2 {
            self.EditGameTypeTextField.userInteractionEnabled = false
            self.EditStartTimeTextField.userInteractionEnabled = false
            self.EditFromMapButton.userInteractionEnabled = false
        } else if enabledViewTag == 4 {
            self.EditNumberOfPlayersTextField.userInteractionEnabled = false
            self.EditStartTimeTextField.userInteractionEnabled = false
            self.EditFromMapButton.userInteractionEnabled = false
        } else if enabledViewTag == 5 {
            self.EditNumberOfPlayersTextField.userInteractionEnabled = false
            self.EditFromMapButton.userInteractionEnabled = false
            self.EditGameTypeTextField.userInteractionEnabled = false
        } else if enabledViewTag == 12 {
            self.EditNumberOfPlayersTextField.userInteractionEnabled = false
            self.EditStartTimeTextField.userInteractionEnabled = false
            self.EditGameTypeTextField.userInteractionEnabled = false
        }
    }
    
    override func enableTextViews() {
        self.EditAddressTextField.userInteractionEnabled = true
        self.EditGameTypeTextField.userInteractionEnabled = true
        self.EditDescriptionTextField.userInteractionEnabled = true
        self.EditStartTimeTextField.userInteractionEnabled = true
        self.EditNumberOfPlayersTextField.userInteractionEnabled = true
        self.EditRadiusInMetersTextField.userInteractionEnabled = true
        self.EditFromMapButton.userInteractionEnabled = true
        self.EditGameLengthTextField.userInteractionEnabled = true
    }
    
    override func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            self.EditNumberOfPlayersTextField.text = String(row)
        case 1:
            switch row {
            case 0:
                self.EditGameTypeTextField.text = "Free For All"
            case 1:
                self.EditGameTypeTextField.text = "Individual Targets"
            case 2:
                self.EditGameTypeTextField.text = "Team"
            case 3:
                self.EditGameTypeTextField.text = "Default"
            default:
                print("Error in didSelect")
            }
        default:
            print("Error in didSelect")
        }
        
        pickerView.endEditing(true)
    }
    
    override func showDatePicker(sender : UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EditGameViewController.datePickerChangedDate(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.addDatePickerDoneButton()
    }
    
    override func datePickerChangedDate(sender : UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.EditStartTimeTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    override func addDatePickerDoneButton() {
        self.datePickerDoneButton = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(EditGameViewController.dismissDatePicker))
        self.navigationItem.rightBarButtonItem = self.datePickerDoneButton!
    }
    
    override func dismissPickerView() {
        switch self.currentlySelectedPickerView! {
        case 0:
            self.EditNumberOfPlayersTextField.resignFirstResponder()
        case 1:
            self.EditGameTypeTextField.resignFirstResponder()
        default:
            print("Error dismissing picker view")
        }
        
        self.navigationItem.rightBarButtonItem = nil
        self.pickerViewDoneButton = nil
        self.currentlySelectedPickerView = nil
        self.enableTextViews()
    }
    
    override func dismissDatePicker() {
        self.EditStartTimeTextField.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = nil
        self.datePickerDoneButton = nil
        self.enableTextViews()
    }
    
    override func addGestureRecognizerToMap(mapView : MKMapView) {
        
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(EditGameViewController.getPointFromMap(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
    }
    
    override func convertCoordFromMapToAddress(coord : CLLocation) {
        
        let placemark = MKPlacemark(coordinate: coord.coordinate, addressDictionary: nil)
        self.mapView?.addAnnotation(placemark)
        
        CLGeocoder().reverseGeocodeLocation(coord, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                let address = pm.addressDictionary!["FormattedAddressLines"] as! [String]
                let fullAddress = (address as NSArray).componentsJoinedByString(" ")
                self.EditAddressTextField.text = fullAddress
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    override func updateInfoMessageLabel(message : String, color: UIColor) {
        print("View updated!")
        dispatch_async(dispatch_get_main_queue(), {
            self.EditErrorLabel.text = message
            self.EditErrorLabel.textColor = color
        })
    }
}