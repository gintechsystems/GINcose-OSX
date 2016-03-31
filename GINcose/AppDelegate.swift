//
//  AppDelegate.swift
//  GINcose
//
//  Created by Joe Ginley on 3/20/16.
//  Copyright © 2016 Joe Ginley. All rights reserved.
//

import Cocoa

let appDel = NSApp.delegate! as! AppDelegate

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    let userDefaults = NSUserDefaults()
    
    let dexcomNetwork = DexcomNetwork()
    
    let defaultPopOver = NSPopover()

    var statusItem :NSStatusItem!
    
    var darkModeOn = false
    
    var dexcomPublisherAccount :PublisherAccountInfo! = nil
    
    var lastGlucoseInfo :LastGlucoseInfo! = nil
    
    var glucosePopOver :GlucosePopupViewController? = nil
    
    var glucoseTimer :NSTimer! = nil
    
    var isFirstReadingLaunch = true
    
    var eventMonitor: EventMonitor!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        let icon = NSImage(named: "statusIcon")!
        icon.template = true
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = icon
        statusItem.action = #selector(togglePopover)
        
        defaultPopOver.contentViewController = GlucosePopupViewController(nibName: "GlucosePopupViewController", bundle: nil)
        
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) { [unowned self] event in
            if self.defaultPopOver.shown {
                self.closePopover(event)
            }
        }
        
        // Seup the network manager
        dexcomNetwork.setupManager()
        
        if (userDefaults.stringForKey("user") != nil && userDefaults.stringForKey("pwd") != nil) {
            dexcomUsername = userDefaults.stringForKey("user")!
            dexcomPassword = userDefaults.stringForKey("pwd")!
        }
        
        if (dexcomUsername != "" && dexcomPassword != "") {
            // Start by getting the session id
            dexcomNetwork.getSessionId()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func showPopover(sender: AnyObject?) {
        if #available(OSX 10.10, *) {
            defaultPopOver.showRelativeToRect(statusItem.button!.bounds, ofView: statusItem.button!, preferredEdge: NSRectEdge.MinY)
        }
        else {
            defaultPopOver.showRelativeToRect(statusItem.view!.bounds, ofView: statusItem.view!, preferredEdge: NSRectEdge.MinY)
        }
        eventMonitor.start()
    }
    
    func closePopover(sender: AnyObject?) {
        defaultPopOver.performClose(sender)
        eventMonitor.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if defaultPopOver.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func setupImageLayer(imageview :NSImageView) {
        imageview.wantsLayer = true
        //imageview.layer!.borderColor = NSColor.whiteColor().CGColor
        //imageview.layer!.borderWidth = 2.0
        imageview.layer!.cornerRadius = 5.0
        imageview.layer!.masksToBounds = true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
}

