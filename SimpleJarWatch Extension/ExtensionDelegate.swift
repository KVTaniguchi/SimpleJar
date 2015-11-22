//
//  ExtensionDelegate.swift
//  SimpleJarWatch Extension
//
//  Created by Kevin Taniguchi on 8/29/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import WatchKit
import ClockKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey", jarKey = "com.taniguchi.JarKey"
    var currentAmount : Float = 0.0, allowance : Float = 0.0
    var updateClosure : (() -> Void) = {}
    let session = WCSession.defaultSession()

    func applicationDidFinishLaunching() {
        if sharedDefaults.objectForKey(jarKey) != nil {
            jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
            
            if let defaultSize = jarData[jarSizeKey] {
                if let k = NSNumberFormatter().numberFromString(defaultSize) {
                    allowance = Float(k)
                }
            }
            if let savedAmount = jarData[savedAmountInJarKey] {
                if let n = NSNumberFormatter().numberFromString(savedAmount) {
                    currentAmount = Float(n)
                }
            }
        }
        
        updateComplication()
    }
    
    func updateComplication () {
        let clkServer = CLKComplicationServer.sharedInstance()
        if clkServer.activeComplications != nil {
            for comp in clkServer.activeComplications {
                clkServer.reloadTimelineForComplication(comp)
            }
        }
        else {
            clkServer.reloadTimelineForComplication(nil)
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        saveMessage(applicationContext)
        
        updateHelper()
        updateComplication()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        saveMessage(message)
        
        updateHelper()
        updateComplication()
        
        replyHandler(["reply":"GOT THE MESSAGE"])
    }

    func applicationDidBecomeActive() {
        updateHelper()
    }

    func applicationWillResignActive() {

        jarData[savedAmountInJarKey] = "\(currentAmount)"
        sharedDefaults.setObject(jarData, forKey: jarKey)
        if sharedDefaults.objectForKey(jarKey) != nil {
            
            if (WCSession.isSupported()) {
                session.delegate = self
                session.activateSession()
                
                do {
                    try session.updateApplicationContext(jarData)
                }
                catch {
                    print("wut")
                }
                
                if session.reachable {
                    session.sendMessage(jarData, replyHandler: nil, errorHandler: nil)
                }
            }
        }
        updateComplication()
        
        print("will resign active")
    }
    
    // MARK - helpers
    func saveMessage (message: [String : AnyObject]) {
        jarData = message as! [String: String]
        let defaultSize = jarData[jarSizeKey]
        let savedAmount = jarData[savedAmountInJarKey]
        if let n = NSNumberFormatter().numberFromString(savedAmount!) {
            currentAmount = Float(n)
        }
        if let k = NSNumberFormatter().numberFromString(defaultSize!) {
            allowance = Float(k)
        }
        NSUserDefaults.standardUserDefaults().setValue(jarData, forKey: jarKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func updateHelper () {
        NSUserDefaults.standardUserDefaults().setValue(jarData, forKey: jarKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        updateClosure()
        updateComplication()
    }
}
