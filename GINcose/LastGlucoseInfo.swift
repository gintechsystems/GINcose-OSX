//
//  LastGlucoseInfo.swift
//  GINcose
//
//  Created by Joe Ginley on 3/21/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation


class LastGlucoseInfo: NSObject {
    var trend = 0
    var glucose = 0
    var timestamp :NSDate!
    
    func printGlucose() {
        NSLog("LatestGlucose")
        NSLog("-------------")
        NSLog("Trend: \(trend)")
        NSLog("Glucose: \(glucose)")
        NSLog("Timestamp: \(timestamp)")
        NSLog("-------------")
    }
}