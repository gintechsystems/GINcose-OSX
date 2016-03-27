//
//  PublisherAccountInfo.swift
//  GINcose
//
//  Created by Joe Ginley on 3/26/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Foundation
import Cocoa

class PublisherAccountInfo: NSObject {
    var email = ""
    var image :NSImage
    
    init(image :NSImage) {
        self.image = image
    }
}