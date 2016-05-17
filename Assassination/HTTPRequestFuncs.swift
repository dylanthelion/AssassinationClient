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
    var delegate : APIManager?
    
    init() {
    
    }
    
    class var RequestManager : HTTPRequests {
        return requests
    }
    
    func GetJSONResponse(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?, completion : (parsedResponse : Dictionary<String, AnyObject>) -> Void, errorHandler: (parsedResponse : [String]) -> Void) {
        //print("URL: \(url)")
        if let _ = url {
            
            let request = BuildURLRequest(url, requestType: requestType, requestBody: requestBody)
            /*print("URL: \(request?.URL!)")
             print("TYPE: \(request?.HTTPMethod)")
             print("Headers: \(request?.allHTTPHeaderFields!)")*/
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request!, completionHandler: {data, response, error -> Void in
                //print("Response: \(response)")
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                if let _ = data {
                    let checkData = self.JSONBuilder.jsonMessageStringToDictionary(data!)
                    if let _ = checkData {
                        //print("Decoded data: \(checkData!)")
                        completion(parsedResponse: checkData as! Dictionary<String, AnyObject>)
                    } else {
                        let checkDataForError = self.JSONBuilder.JSONMessageStringToArray(data!)
                        if let _ = checkDataForError {
                            errorHandler(parsedResponse: checkDataForError as! [String])
                        } else {
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("String data: \(jsonStr!)")
                        }
                    }
                }
            })
            
            task.resume()
        }
    }
    
    func GetJSONArrayResponse(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?, completion : (parsedResponse : [String]) -> Void) {
        print("URL: \(url)")
        if let _ = url {
            
            let request = BuildURLRequest(url, requestType: requestType, requestBody: requestBody)
            print("URL: \(request?.URL!)")
            print("TYPE: \(request?.HTTPMethod)")
            print("Headers: \(request?.allHTTPHeaderFields!)")
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request!, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                if let _ = data {
                    let checkData = self.JSONBuilder.JSONMessageStringToArray(data!)
                    if let _ = checkData {
                        print("Decoded data: \(checkData!)")
                        completion(parsedResponse: checkData as! [String])
                    } else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("String data: \(jsonStr!)")
                    }
                }
            })
            
            task.resume()
        }
    }
    
    func GetJSONArrayOfObjectsResponse(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?, completion : (parsedResponse : [AnyObject]) -> Void) {
        print("URL: \(url)")
        if let _ = url {
            
            let request = BuildURLRequest(url, requestType: requestType, requestBody: requestBody)
            print("URL: \(request?.URL!)")
            print("TYPE: \(request?.HTTPMethod)")
            print("Headers: \(request?.allHTTPHeaderFields!)")
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request!, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                if let _ = data {
                    let checkData = self.JSONBuilder.JSONMessageStringToArray(data!)
                    if let _ = checkData {
                        print("Decoded data: \(checkData!)")
                        completion(parsedResponse: checkData as! [AnyObject])
                    } else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("String data: \(jsonStr!)")
                    }
                }
            })
            
            task.resume()
        }
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
    
    func postImage(url: NSURL?, image: UIImage, completion : (parsedResponse : [String]) -> Void) {
        
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        /*print("URL: \(request.URL!)")
        print("TYPE: \(request.HTTPMethod)")
        print("Headers: \(request.allHTTPHeaderFields!)")*/
        let imageData = UIImageJPEGRepresentation(image, 0.9)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(base64String, options: NSJSONWritingOptions(rawValue: 0))
        } catch _ {
            return
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let _ = data {
                let checkData = self.JSONBuilder.JSONMessageStringToArray(data)
                if let _ = checkData {
                    print("Decoded data: \(checkData!)")
                    completion(parsedResponse: checkData as! [String])
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("String data: \(jsonStr!)")
                }
            }
        })
        
        task.resume()
    }
    
    private func BuildURLRequest(url : NSURL?, requestType : String, requestBody : Dictionary<String, AnyObject>?) -> NSMutableURLRequest? {
        
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = requestType
        
        if let _ = requestBody {
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBody!, options: [])
                //print("Set body to \(requestBody!)")
            } catch _ as NSError {
                print("Failed to encode")
                request.HTTPBody = nil
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    
}