//
//  CreateGameViewController.swift
//  Assassination
//
//  Created by Dylan on 5/12/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AddressBook

class CreateGameViewController: UIViewController, UITextFieldDelegate, DataStoreDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var FromMapButton: UIButton!
    @IBOutlet weak var AddressTextField: UITextField!
    @IBOutlet weak var LocationDescriptionTextField: UITextField!
    @IBOutlet weak var NumberOfPlayersTextField: UITextField!
    @IBOutlet weak var RadiusTextField: UITextField!
    @IBOutlet weak var GameTypeTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var DateTextField: UITextField!
    
    var pickerViewDoneButton : UIBarButtonItem?
    var mapViewDoneButton : UIBarButtonItem?
    var datePickerDoneButton : UIBarButtonItem?
    
    var mapView : MKMapView?
    
    var dataStore : DataManager = DataManager.AppData
    var locationManager : LocationManager = LocationManager.sharedManager
    var currentlySelectedPickerView : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.startLocating(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataStore.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataStore.delegate = nil
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField.tag {
        case 2:
            print("Create picker view")
            self.disableTextFieldsForCustomInputView(textField.tag)
            let picker = self.createPickerViewWithOptions(ofType: 0)
            textField.inputView = picker
        case 4:
            self.disableTextFieldsForCustomInputView(textField.tag)
            let picker = self.createPickerViewWithOptions(ofType: 1)
            textField.inputView = picker
        case 5:
            print("Call date picker")
            self.disableTextFieldsForCustomInputView(5)
            self.showDatePicker(textField)
        default:
            print("Not a custom view")
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return 20
        case 1:
            return 4
        default:
            print("Error in numberOfRows")
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return String(row)
        case 1:
            switch row {
            case 0:
                return "Free For All"
            case 1:
                return "Individual Targets"
            case 2:
                return "Team"
            case 3:
                return "Default"
            default:
                print("Something went wrong in titleForRow")
                return "Default"
            }
        default:
            print("Something went wrong in titleForRow")
            return "HERP"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            self.NumberOfPlayersTextField.text = String(row)
        case 1:
            switch row {
            case 0:
                self.GameTypeTextField.text = "Free For All"
            case 1:
                self.GameTypeTextField.text = "Individual Targets"
            case 2:
                self.GameTypeTextField.text = "Team"
            case 3:
                self.GameTypeTextField.text = "Default"
            default:
                print("Error in didSelect")
            }
        default:
            print("Error in didSelect")
        }
        
        pickerView.endEditing(true)
    }
    
    @IBAction func FromMapButtonPressed(sender: AnyObject) {
        addMap()
    }
    
    @IBAction func SubmitButtonPressed(sender: AnyObject) {
    }
    
    func addMap() {
        let YCoord : CGFloat = self.view.frame.height / 3.0
        let height : CGFloat = YCoord * 2.0
        self.mapView = MKMapView(frame: CGRectMake(0,YCoord,self.view.frame.width,height))
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let myLocation = locationManager.location
        let myCoords : CLLocationCoordinate2D = myLocation!.coordinate
        let region = MKCoordinateRegionMake(myCoords, span)
        
        self.mapView!.setRegion(region, animated: true)
        self.mapView!.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        addGestureRecognizerToMap(self.mapView!)
        self.view.addSubview(self.mapView!)
        addMapViewDoneButton()
        self.disableTextFieldsForCustomInputView(12)
    }
    
    func showDatePicker(sender : UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(CreateGameViewController.datePickerChangedDate(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.addDatePickerDoneButton()
    }
    
    func datePickerChangedDate(sender : UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.DateTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func ModelDidUpdate(message: String?) {
        
    }
    
    func createPickerViewWithOptions(ofType type : Int) -> UIPickerView {
        print("Add picker view")
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.tag = type
        self.addPickerViewDoneButton(type)
        return picker
    }
    
    func addPickerViewDoneButton(pickerType : Int) {
        self.pickerViewDoneButton = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(CreateGameViewController.dismissPickerView))
        self.currentlySelectedPickerView = pickerType
        self.navigationItem.rightBarButtonItem = self.pickerViewDoneButton!
    }
    
    func addMapViewDoneButton() {
        self.pickerViewDoneButton = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(CreateGameViewController.dismissMapView))
        self.navigationItem.rightBarButtonItem = self.pickerViewDoneButton!
    }
    
    func addDatePickerDoneButton() {
        self.datePickerDoneButton = UIBarButtonItem(title: "DONE", style: .Plain, target: self, action: #selector(CreateGameViewController.dismissDatePicker))
        self.navigationItem.rightBarButtonItem = self.datePickerDoneButton!
    }
    
    func dismissPickerView() {
        switch self.currentlySelectedPickerView! {
        case 0:
            self.NumberOfPlayersTextField.resignFirstResponder()
        case 1:
            self.GameTypeTextField.resignFirstResponder()
        default:
            print("Error dismissing picker view")
        }
        
        self.navigationItem.rightBarButtonItem = nil
        self.pickerViewDoneButton = nil
        self.currentlySelectedPickerView = nil
        self.enableTextViews()
    }
    
    func dismissMapView() {
        
        self.mapView?.removeFromSuperview()
        self.mapView = nil
        self.navigationItem.rightBarButtonItem = nil
        self.mapViewDoneButton = nil
        self.enableTextViews()
    }
    
    func dismissDatePicker() {
        self.DateTextField.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = nil
        self.datePickerDoneButton = nil
        self.enableTextViews()
    }
    
    func addGestureRecognizerToMap(mapView : MKMapView) {
        
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(CreateGameViewController.getPointFromMap(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
    }
    
    func getPointFromMap(tapEvent : UILongPressGestureRecognizer) {
        if tapEvent.state != UIGestureRecognizerState.Ended {
            let touchLocation = tapEvent.locationInView(self.mapView)
            let locationCoordinate = self.mapView!.convertPoint(touchLocation,toCoordinateFromView: self.mapView!)
            let locationToSet = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            self.convertCoordFromMapToAddress(locationToSet)
        }
    }
    
    func convertCoordFromMapToAddress(coord : CLLocation) {
        
        let placemark = MKPlacemark(coordinate: coord.coordinate, addressDictionary: nil)
        self.mapView?.addAnnotation(placemark)
        
        CLGeocoder().reverseGeocodeLocation(coord, completionHandler: {(placemarks, error) -> Void in
            print(coord)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                let address = pm.addressDictionary!["FormattedAddressLines"] as! [String]
                let fullAddress = (address as NSArray).componentsJoinedByString(" ")
                self.AddressTextField.text = fullAddress
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func disableTextFieldsForCustomInputView(enabledViewTag : Int) {
        print("Tag to disable: \(enabledViewTag)")
        self.AddressTextField.userInteractionEnabled = false
        self.LocationDescriptionTextField.userInteractionEnabled = false
        self.RadiusTextField.userInteractionEnabled = false
        if enabledViewTag == 2 {
            self.GameTypeTextField.userInteractionEnabled = false
            self.DateTextField.userInteractionEnabled = false
            self.FromMapButton.userInteractionEnabled = false
        } else if enabledViewTag == 4 {
            self.NumberOfPlayersTextField.userInteractionEnabled = false
            self.DateTextField.userInteractionEnabled = false
            self.FromMapButton.userInteractionEnabled = false
        } else if enabledViewTag == 5 {
            self.NumberOfPlayersTextField.userInteractionEnabled = false
            self.FromMapButton.userInteractionEnabled = false
            self.GameTypeTextField.userInteractionEnabled = false
        } else if enabledViewTag == 12 {
            self.NumberOfPlayersTextField.userInteractionEnabled = false
            self.DateTextField.userInteractionEnabled = false
            self.GameTypeTextField.userInteractionEnabled = false
        }
    }
    
    func enableTextViews() {
        self.AddressTextField.userInteractionEnabled = true
        self.GameTypeTextField.userInteractionEnabled = true
        self.LocationDescriptionTextField.userInteractionEnabled = true
        self.DateTextField.userInteractionEnabled = true
        self.NumberOfPlayersTextField.userInteractionEnabled = true
        self.RadiusTextField.userInteractionEnabled = true
        self.FromMapButton.userInteractionEnabled = true
    }
    
}