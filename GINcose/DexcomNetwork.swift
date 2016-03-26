//
//  DexcomNetwork.swift
//  GINcose
//
//  Created by Joe Ginley on 3/20/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire
import AlamofireImage

class DexcomNetwork :NSObject {
    
    let manager = AFHTTPSessionManager()
    
    var sessionId = ""
    
    func setupManager() {
        let requestSerializer = AFJSONRequestSerializer()
        let responseSerializer = AFJSONResponseSerializer(readingOptions: .AllowFragments)
        
        manager.requestSerializer = requestSerializer
        manager.responseSerializer = responseSerializer
    }
    
    func getSessionId() {
        
        let dict = ["applicationId" : applicationId, "accountName" : dexcomUsername, "password" : dexcomPassword]
        
        manager.POST(String(format: "%@LoginPublisherAccountByName", DexcomShare2Services.General.rawValue), parameters: dict, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("SessionId Completed")
                
            //NSLog("\(responseObj!)")
            
            self.sessionId = responseObj as! String
            
            self.setupPublisher()
            self.getLatestGlucose()
            }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
                NSLog("\(error)")
        }

        NSLog("Requesting SessionId...")
    }
    
    func getLatestGlucose() {
        manager.POST(String(format: "%@ReadPublisherLatestGlucoseValues?sessionId=%@&minutes=1440&maxCount=%i", DexcomShare2Services.Publisher.rawValue, sessionId, glucoseMaxCount), parameters: nil, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("LastGlucose Completed")
            
            //NSLog("\(responseObj!)")
            
            let json :NSArray = responseObj as! NSArray
            
            let lastGlucose = LastGlucoseInfo()
            lastGlucose.trend = json[0]["Trend"] as! Int
            lastGlucose.glucose = json[0]["Value"] as! Int
            
            var glucoseDate = json[0]["ST"] as! String
            glucoseDate = glucoseDate.stringByReplacingOccurrencesOfString("/Date(", withString: "")
            glucoseDate = glucoseDate.stringByReplacingOccurrencesOfString(")/", withString: "")
            
            let realTimeStamp = NSDate(timeIntervalSince1970: Double(glucoseDate)! / 1000)
            lastGlucose.timestamp = realTimeStamp
            
            lastGlucose.printGlucose()
            
            let notification = NSUserNotification()
            notification.title = "Glucose Notification"
            notification.informativeText = String(format: "Your glucose level is now at %i.", lastGlucose.glucose)
            notification.soundName = NSUserNotificationDefaultSoundName
            
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
            
            if (appDel.glucoseTimer == nil) {
                // 5 minutes and 10 seconds for an update.
                appDel.glucoseTimer = NSTimer.scheduledTimerWithTimeInterval(310, target: self, selector: #selector(self.getLatestGlucose), userInfo: nil, repeats: true)
            }
            }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
                NSLog("\(error)")
        }
        
        NSLog("Requesting LastGlucose...")
    }
    
    func setupPublisher() {
        Alamofire.request(.GET, String(format: "%@ReadPublisherAccountImage?sessionId=%@", DexcomShare2Services.Publisher.rawValue, sessionId))
            .responseImage { response in
                if let image = response.result.value {
                    appDel.dexcomPublisherAccount = PublisherAccountInfo(image: image)
                    
                    NSLog("Publisher Image Completed")
                }
        }
        
        NSLog("Requesting Publisher Image...")
    }
    
    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.systemTimeZone().secondsFromGMT)
        
        return dateFormatter
    }()
    
}