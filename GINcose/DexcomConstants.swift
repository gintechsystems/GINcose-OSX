//
//  DexcomConstants.swift
//  GINcose
//
//  Created by Joe Ginley on 3/20/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation

enum DexcomShare2Services: String {
    case General = "https://share2.dexcom.com/ShareWebServices/Services/General/"
    case Publisher = "https://share2.dexcom.com/ShareWebServices/Services/Publisher/"
}

enum DexcomShare2ParseServices: Int {
    case PublisherEmail = 0
}

// Not sure if this is required by each specific account or if you can use any account, seems that you cannot use all zeros.
var applicationId :String = "13A907FB-AC7E-4F90-B4EC-2F2B8BE1C607"

// These variables need to be replaced by your account login.
var dexcomUsername :String = ""
var dexcomPassword :String = ""

// The max amount of glucose levels that will be returned calling ReadPublisherLatestGlucoseValues.
var glucoseMaxCount = 1