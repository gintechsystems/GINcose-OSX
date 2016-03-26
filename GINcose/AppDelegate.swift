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

    var statusItem :NSStatusItem!
    
    var darkModeOn = false
    
    let dexcomNetwork = DexcomNetwork()
    
    let defaultPopOver = NSPopover()
    
    var dexcomPublisherAccount :PublisherAccountInfo! = nil
    
    var glucoseTimer :NSTimer! = nil

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        let icon = NSImage(named: "statusIcon")!
        icon.template = true
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        statusItem.image = icon
        statusItem.action = #selector(togglePopover)
        
        defaultPopOver.contentViewController = GlucosePopupViewController(nibName: "GlucosePopupViewController", bundle: nil)
        
        // Seup the network manager
        dexcomNetwork.setupManager()
        
        // Start by getting the session id
        dexcomNetwork.getSessionId()
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
    }
    
    func closePopover(sender: AnyObject?) {
        defaultPopOver.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if defaultPopOver.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
}

