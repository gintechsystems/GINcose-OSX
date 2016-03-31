//
//  DexcomNetwork.swift
//  GINcose
//
//  Created by Joe Ginley on 3/20/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation
import Cocoa
import AFNetworking
import Alamofire
import AlamofireImage

class DexcomNetwork :NSObject, NSXMLParserDelegate {
    
    let manager = AFHTTPSessionManager()
    
    let jsonResponseSerializer = AFJSONResponseSerializer(readingOptions: .AllowFragments)
    let xmlResponseSerializer = AFXMLParserResponseSerializer()
    
    var sessionId = ""
    
    var parserService :Int = 0
    
    func setupManager() {
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = jsonResponseSerializer
    }
    
    func getSessionId() {
        
        let dict = ["applicationId" : applicationId, "accountName" : dexcomUsername, "password" : dexcomPassword]
        
        manager.POST(String(format: "%@LoginPublisherAccountByName", DexcomShare2Services.General.rawValue), parameters: dict, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("SessionId Completed")
                
            //NSLog("\(responseObj!)")
            
            appDel.userDefaults.setObject(dexcomUsername, forKey: "user")
            appDel.userDefaults.setObject(dexcomPassword, forKey: "pwd")
            
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
            NSLog("Latest Glucose Completed")
            
            //NSLog("\(responseObj!)")
            
            let json :NSArray = responseObj as! NSArray
            
            appDel.lastGlucoseInfo = LastGlucoseInfo()
            appDel.lastGlucoseInfo.trend = json[0]["Trend"] as! Int
            appDel.lastGlucoseInfo.glucose = json[0]["Value"] as! Int
            
            var glucoseDate = json[0]["ST"] as! String
            glucoseDate = glucoseDate.stringByReplacingOccurrencesOfString("/Date(", withString: "")
            glucoseDate = glucoseDate.stringByReplacingOccurrencesOfString(")/", withString: "")
            
            let realTimeStamp = NSDate(timeIntervalSince1970: Double(glucoseDate)! / 1000)
            appDel.lastGlucoseInfo.timestamp = realTimeStamp
            
            appDel.lastGlucoseInfo.printGlucose()
            
            if (appDel.glucosePopOver != nil) {
                appDel.glucosePopOver!.latestGlucoseLevelField.hidden = false
                appDel.glucosePopOver!.latestGlucoseLevelField.stringValue = String(format: "Latest Glucose Level: %i", appDel.lastGlucoseInfo!.glucose)
            }
            
            let notification = NSUserNotification()
            notification.title = "Glucose Notification"
            if (appDel.isFirstReadingLaunch) {
                appDel.isFirstReadingLaunch = false
                
                notification.informativeText = String(format: "Your latest glucose level is %i.", appDel.lastGlucoseInfo.glucose)
            }
            else {
                notification.informativeText = String(format: "Your glucose level is now at %i.", appDel.lastGlucoseInfo.glucose)
            }
            notification.soundName = nil
            
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
            
            if (appDel.glucoseTimer == nil) {
                // 5 minutes and 10 seconds for an update.
                appDel.glucoseTimer = NSTimer.scheduledTimerWithTimeInterval(310, target: self, selector: #selector(self.getLatestGlucose), userInfo: nil, repeats: true)
            }
            }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
                NSLog("\(error)")
        }
        
        NSLog("Requesting Latest Glucose...")
    }
    
    func setupPublisher() {
        Alamofire.request(.GET, String(format: "%@ReadPublisherAccountImage?sessionId=%@", DexcomShare2Services.Publisher.rawValue, sessionId))
            .responseImage { response in
                if let image = response.result.value {
                    appDel.dexcomPublisherAccount = PublisherAccountInfo(image: image)
                    
                    if (appDel.glucosePopOver != nil) {
                        appDel.glucosePopOver!.publisherImageView.image = image
                    }
                    
                    NSLog("Publisher Image Completed")
                }
                
                self.getPublisherEmail()
        }
        
        NSLog("Requesting Publisher Image...")
    }
    
    func getPublisherEmail() {
        manager.responseSerializer = xmlResponseSerializer
        
        manager.POST(String(format: "%@ReadPublisherAccountEmail?sessionId=%@", DexcomShare2Services.Publisher.rawValue, sessionId), parameters: nil, progress: nil, success: { (task :NSURLSessionDataTask, responseObj :AnyObject?) -> Void in
            NSLog("Publisher Email Completed")
            
            //NSLog("\(responseObj!)")
            
            let parser = responseObj as! NSXMLParser
            parser.delegate = self
            parser.parse()
            
            self.manager.responseSerializer = self.jsonResponseSerializer
        }) { (task :NSURLSessionDataTask?, error :NSError) -> Void in
            NSLog("\(error)")
        }
        
        NSLog("Requesting Publisher Email...")
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        NSLog("\(string)")
        
        if (parserService == DexcomShare2ParseServices.PublisherEmail.rawValue) {
            if (appDel.dexcomPublisherAccount != nil) {
                appDel.dexcomPublisherAccount.email = string
                
                if (appDel.glucosePopOver != nil) {
                    appDel.glucosePopOver!.publisherEmailField.stringValue = string
                    appDel.glucosePopOver!.publisherEmailField.hidden = false
                }
            }
        }
    }
    
    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.systemTimeZone().secondsFromGMT)
        
        return dateFormatter
    }()
    
}