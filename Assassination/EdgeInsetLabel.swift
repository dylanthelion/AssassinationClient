//
//  EdgeInsetLabel.swift
//  Assassination
//
//  Created by Dylan on 5/21/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class EdgeInsetLabel: UILabel {
    
    var topInset : CGFloat?
    var leftInset : CGFloat?
    var bottomInset : CGFloat?
    var rightInset : CGFloat?
    
    func setInsets(top : CGFloat, left : CGFloat, bottom : CGFloat, right : CGFloat) {
        topInset = top
        leftInset = left
        bottomInset = bottom
        rightInset = right
    }
    
    override func drawTextInRect(rect: CGRect) {
        if let _ = topInset {
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(topInset!, leftInset!, bottomInset!, rightInset!)))
        }
    }
}