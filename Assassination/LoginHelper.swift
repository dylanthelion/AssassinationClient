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
    
    var userID : Int?
    var userName : String?
    
    class  var appLogin : LoginHelper {
        return sharedHelper
    }
    
    init() {
        
    }
}
