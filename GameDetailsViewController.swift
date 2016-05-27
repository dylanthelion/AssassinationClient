//
//  GameDetailsViewController.swift
//  Assassination
//
//  Created by Dylan on 5/21/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class GameDetailsViewController: UIViewController, DataStoreDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableViewMain: UITableView!
    @IBOutlet weak var JoinButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    var dataStore : DataManager = DataManager.AppData
    var game : Game?
    
    override func viewDidLoad() {
        
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
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! TwoColumnTableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func ModelDidUpdate(message: String?) {
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
    
    @IBAction func JoinButtonPressed(sender: AnyObject) {
        if !self.dataStore.userStore.isValidUser || self.game == nil {
            return
        }
        
        APIManager.JoinGame(self.game!.id!)
    }
    
    @IBAction func DeleteButtonPressed(sender: AnyObject) {
    }
    
    func updateInfoMessageLabel(message : String, color: UIColor) {
        dispatch_async(dispatch_get_main_queue(), {
            self.ErrorLabel.text = message
            self.ErrorLabel.textColor = color
        })
    }
    
}