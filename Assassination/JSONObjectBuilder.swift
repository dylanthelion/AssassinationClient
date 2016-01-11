//
//  JSONObjectBuilder.swift
//  Assassination
//
//  Created by Dylan on 1/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let builder = JSONObjectBuilder()

class JSONObjectBuilder {
    
    init() {
        
    }
    
    class var JSONBuilder : JSONObjectBuilder {
        return builder
    }
    
    func jsonMessageStringToDictionary(data: NSData!) -> NSDictionary? {
        
        var returnObject : NSMutableDictionary?
        var responseString : NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let stringLength : Int = responseString!.length
        responseString = responseString?.substringToIndex(stringLength - 1)
        responseString = responseString?.substringFromIndex(1)
        let backToData = responseString?.dataUsingEncoding(NSUTF8StringEncoding)
        do
        {
            returnObject = try NSJSONSerialization.JSONObjectWithData(backToData!, options: .AllowFragments) as? NSMutableDictionary
        } catch _ as NSError {
            returnObject = nil
        } catch {
            returnObject = nil
        }
        
        
        return returnObject
    }
    
    func JSONMessageStringToArray(data: NSData!) -> NSArray? {
        
        var returnObject : NSArray?
        var responseString : NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let stringLength : Int = responseString!.length
        responseString = responseString?.substringToIndex(stringLength - 1)
        responseString = responseString?.substringFromIndex(1)
        let backToData = responseString?.dataUsingEncoding(NSUTF8StringEncoding)
        do
        {
            returnObject = try NSJSONSerialization.JSONObjectWithData(backToData!, options: .AllowFragments) as? NSMutableArray
        } catch _ as NSError {
            returnObject = nil
        } catch {
            returnObject = nil
        }
        
        
        return returnObject
    }
}