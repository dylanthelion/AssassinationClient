//
//  MainRallyViewController.swift
//  Assassination
//
//  Created by Dylan on 5/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class MainRallyViewController: UIViewController, DataStoreDelegate {
    
    let dataStore = DataManager.AppData
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.dataStore.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dataStore.delegate = self
    }
    
    func ModelDidUpdate(message: String?) {
        
    }
}