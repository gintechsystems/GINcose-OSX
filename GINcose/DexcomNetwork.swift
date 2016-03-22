//
//  DexcomNetwork.swift
//  GINcose
//
//  Created by Joe Ginley on 3/20/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation


class DexcomNetwork :NSObject {
    
    let manager = AFHTTPSessionManager()
    
    var sessionId = ""
    var subscriptionId = ""
    
    func setupManager() {
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let responseSerializer = AFJSONResponseSerializer(readingOptions: .AllowFragments)
        
        manager.requestSerializer = requestSerializer
        manager.responseSerializer = responseSerializer
    }
    
    func getSessionId() {
        
        let dict = ["applicationId" : applicationId, "accountId" : accountId, "password" : accountPassword]
        
        manager.POST(String(format: "%@LoginSubscriberAccount", DexcomShare1Services.General.rawValue), parameters: dict, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("SessionId Completed")
                
            //NSLog("\(responseObj!)")
            
            self.sessionId = responseObj as! String
            
            self.getSubscriptionId()
            }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
                NSLog("\(error)")
        }

        NSLog("Requesting SessionId...")
    }
    
    func getSubscriptionId() {
        manager.POST(String(format: "%@ListSubscriberAccountSubscriptions?sessionId=%@", DexcomShare1Services.Subscriber.rawValue, sessionId), parameters: nil, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("SubscriptionId Completed")
            
            //NSLog("\(responseObj!)")
            
            let json :NSArray = responseObj as! NSArray
            
            self.subscriptionId = json[0]["SubscriptionId"] as! String
            
            self.getLatestGlucose()
            }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
                NSLog("\(error)")
        }
        
        NSLog("Requesting SubscriptionId...")
    }
    
    func getLatestGlucose() {
        let dict = [subscriptionId]
        
        manager.POST(String(format: "%@ReadLastGlucoseFromSubscriptions?sessionId=%@", DexcomShare1Services.Subscriber.rawValue, sessionId), parameters: dict, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("LastGlucose Completed")
            
            //NSLog("\(responseObj!)")
            
            let json :NSArray = responseObj as! NSArray
            
            let lastGlucose = LastGlucoseInfo()
            lastGlucose.trend = json[0]["Egv"]!!["Trend"] as! Int
            lastGlucose.glucose = json[0]["Egv"]!!["Value"] as! Int
            
            var glucoseDate = json[0]["Egv"]!!["ST"] as! String
            glucoseDate = glucoseDate.stringByReplacingOccurrencesOfString("/Date(", withString: "")
            glucoseDate = glucoseDate.stringByReplacingOccurrencesOfString(")/", withString: "")
            
            let realTimeStamp = NSDate(timeIntervalSince1970: Double(glucoseDate)! / 1000)
            lastGlucose.timestamp = realTimeStamp
            
            lastGlucose.printGlucose()
            
            }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
                NSLog("\(error)")
        }
        
        NSLog("Requesting LastGlucose...")
    }
    
    let glucoseDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.systemTimeZone().secondsFromGMT)
        
        return dateFormatter
    }()
    
}