//
//  DexcomConstants.swift
//  GINcose
//
//  Created by Joe Ginley on 3/20/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation


enum DexcomShare1Services: String {
    case General = "https://share1.dexcom.com/ShareWebServices/Services/General/"
    case Subscriber = "https://share1.dexcom.com/ShareWebServices/Services/Subscriber/"
}

enum DexcomShare2Services: String {
    case General = "https://share2.dexcom.com/ShareWebServices/Services/General/"
    case Publisher = "https://share2.dexcom.com/ShareWebServices/Services/Publisher/"
}

var applicationId :String = "d89443d2-327c-4a6f-89e5-496bbb0317db"

// These variables need to be replaced by a follower with your account!
var accountId :String = "ad529418-1be5-4379-8c79-39d4c922607f"
var accountPassword :String = "0BDCE33F-5B01-4C85-A2A7-B552B67B72C0"