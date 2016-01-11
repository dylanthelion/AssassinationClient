//
//  HTTPRequestFuncs.swift
//  Assassination
//
//  Created by Dylan on 1/10/16.
//  Copyright © 2016 Dylan. All rights reserved.
//

import Foundation

private let requests = HTTPRequests()

class HTTPRequests {
    
    let JSONBuilder = JSONObjectBuilder.JSONBuilder
    
    init() {
    
    }
    
    class var RequestManager : HTTPRequests {
        return requests
    }
    
    func GetJSONResponse(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?) -> Dictionary<String, AnyObject>? {
        
        var returnObject : Dictionary<String, AnyObject>?
        
        if let _ = url {
            
            let request = BuildURLRequest(url, requestType: requestType, requestBody: requestBody)
            
            let session = NSURLSession.sharedSession()
            
            _ = session.dataTaskWithRequest(request!, completionHandler: {data, response, error -> Void in
                if let _ = data {
                    let checkData = self.JSONBuilder.jsonMessageStringToDictionary(data)
                    if let _ = checkData {
                        returnObject = checkData as? Dictionary<String, AnyObject>
                    } else {
                        returnObject = nil
                    }
                }
            })
        } else {
            returnObject = nil
        }
        
        return returnObject
    }
    
    func GetJSONArrayResponse(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?) -> [String]? {
        
        var returnObject : [String]?
        
        if let _ = url {
            
            let request = BuildURLRequest(url, requestType: requestType, requestBody: requestBody)
            
            let session = NSURLSession.sharedSession()
            
            _ = session.dataTaskWithRequest(request!, completionHandler: {data, response, error -> Void in
                if let _ = data {
                    let checkData = self.JSONBuilder.JSONMessageStringToArray(data)
                    if let _ = checkData {
                        returnObject = checkData as? [String]
                    } else {
                        returnObject = nil
                    }
                }
            })
        } else {
            returnObject = nil
        }
        
        return returnObject
    }
    
    func GetImageResponse(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?) -> UIImage? {
        
        var returnObject : UIImage?
        
        if let _ = url {
            
            let request = BuildURLRequest(url, requestType: requestType, requestBody: requestBody)
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request!, completionHandler: {data, response, error -> Void in
                if let _ = data {
                    returnObject = UIImage(data: data!)
                } else {
                    returnObject = nil
                }
            })
            
            task.resume()
        } else {
            returnObject = nil
        }
        
        return returnObject
    }
    
    func postImage(url: NSURL?, image: UIImage) -> (Bool, [String]) {
        
        var returnObject : (Bool, [String]) = (false, ["Something went wrong"])
        
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let imageData = UIImageJPEGRepresentation(image, 0.9)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(base64String, options: NSJSONWritingOptions(rawValue: 0))
        } catch _ {
            print("Failed to encode image")
            returnObject = (false, ["Failed to encode image"])
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let _ = data {
                let checkData = self.JSONBuilder.JSONMessageStringToArray(data)
                if let checkCheck = checkData {
                    returnObject = (true, checkCheck as! [String])
                } else {
                    returnObject = (false, ["Failed to process response"])
                }
            }
        })
        
        task.resume()
        
        return returnObject
    }
    
    private func BuildURLRequest(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?) -> NSURLRequest? {
        
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = requestType
        
        if let _ = requestBody {
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBody!, options: [])
            } catch _ as NSError {
                request.HTTPBody = nil
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    
}