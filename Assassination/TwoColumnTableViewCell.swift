//
//  TwoColumnTableViewCell.swift
//  Assassination
//
//  Created by Dylan on 5/21/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import UIKit

class TwoColumnTableViewCell: UITableViewCell {
    
    var LabelLeft: EdgeInsetLabel?
    var LabelRight: EdgeInsetLabel?
    
    override func awakeFromNib() {
        self.addLabels("", textRight: "")
    }
    
    func addLabels(textLeft : String, textRight: String) {
        if self.LabelLeft == nil {
            self.LabelLeft = EdgeInsetLabel(frame: CGRectMake(0, 0, self.frame.width / 2.0, self.frame.height))
            self.LabelLeft?.setInsets(0, left: 0, bottom: 0, right: 0)
            self.LabelRight = EdgeInsetLabel(frame: CGRectMake(self.frame.width / 2.0, 0, self.frame.width / 2.0, self.frame.height))
            self.LabelRight?.setInsets(0, left: 0, bottom: 0, right: 0)
            dispatch_async(dispatch_get_main_queue(), {
                self.LabelLeft!.text = textLeft
                self.LabelRight!.text = textRight
                self.addSubview(self.LabelLeft!)
                self.addSubview(self.LabelRight!)
                self.bringSubviewToFront(self.LabelLeft!)
                self.bringSubviewToFront(self.LabelRight!)
            })
        }
        
         else {
            dispatch_async(dispatch_get_main_queue(), {
                self.LabelLeft!.text = textLeft
                self.LabelRight!.text = textRight
                self.LabelLeft!.setNeedsDisplay()
                self.LabelRight!.setNeedsDisplay()
            })
        }
        
        print("Frame: \(self.LabelRight?.frame)")
        
    }
}