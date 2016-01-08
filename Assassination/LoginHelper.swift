//
//  LoginHelper.swift
//  Assassination
//
//  Created by Dylan on 1/8/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let sharedHelper = LoginHelper()

class LoginHelper {
    
    let dataManager = DataManager.AppData
    
    class  var appLogin : LoginHelper {
        return sharedHelper
    }
    
    init() {
        
    }
}
