//
//  StringExtensions.swift
//  Assassination
//
//  Created by Dylan on 1/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

extension String {
    
    func getNumericPostscript() -> Int? {
        print("String: \(self)")
        if(self.characters.count == 0) {
            print("Zero length")
            return nil
        }
        
        var end : String.Index = self.endIndex.predecessor()
        
        while (Int(String(self[end])) != nil) {
            end = end.predecessor()
        }
        
        end = end.successor()
        
        let stringRange : Range = end...self.endIndex.predecessor()
        print("Range: \(stringRange)")
        print("Substring: \(String(self[stringRange]))")
        return Int(String(self[stringRange]))
    }
}