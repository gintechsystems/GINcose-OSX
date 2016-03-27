//
//  GlucosePopupViewController.swift
//  GINcose
//
//  Created by Joe Ginley on 3/26/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Cocoa

class GlucosePopupViewController: NSViewController {
    
    @IBOutlet var usernameTextField :NSTextField!
    @IBOutlet var passwordSecureField :NSSecureTextField!
    
    @IBOutlet var loginButton :NSButton!
    
    @IBOutlet var publisherImageView :NSImageView!
    @IBOutlet var publisherEmailField :NSTextField!
    
    @IBOutlet var latestGlucoseLevelField :NSTextField!
    
    override func viewDidLoad() {
        appDel.glucosePopOver = self
        
        if (dexcomUsername != "" && dexcomPassword != "") {
            usernameTextField.stringValue = dexcomUsername
            passwordSecureField.stringValue = dexcomPassword
            
            usernameTextField.hidden = true
            passwordSecureField.hidden = true
            loginButton.hidden = true
            
            appDel.setupImageLayer(publisherImageView)
            publisherImageView.hidden = false
            
            if (appDel.dexcomPublisherAccount != nil) {
                publisherImageView.image = appDel.dexcomPublisherAccount.image
                
                if (appDel.dexcomPublisherAccount.email != "") {
                    publisherEmailField.stringValue = appDel.dexcomPublisherAccount.email
                    publisherEmailField.hidden = false
                }
            }
            
            if (appDel.lastGlucoseInfo != nil) {
                latestGlucoseLevelField.hidden = false
                latestGlucoseLevelField.stringValue = String(format: "Latest Glucose Level: %i", appDel.lastGlucoseInfo!.glucose)
            }
        }
    }
    
    @IBAction func onLoginClick(sender :NSObject) {
        // Check to make sure the fields are not empty & set the dexcom information up.
        if (usernameTextField.stringValue != "" && usernameTextField.stringValue != "") {
            dexcomUsername = usernameTextField.stringValue
            dexcomPassword = passwordSecureField.stringValue
            
            // Once the dexcom information has been set, attempt to authenticate and grab a session.
            appDel.dexcomNetwork.getSessionId()
        }
    }
}