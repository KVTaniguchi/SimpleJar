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

    func applicationDidFinishLaunching() {
        let session = WCSession.defaultSession()
        
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
        
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
        
        print("EXT DID FINISH LAOUCN : \(jarData) CURRENT AMOUNT : \(currentAmount) ALLOW : \(allowance)")
        updateComplication()
    }
    
    func updateComplication () {
        let clkServer = CLKComplicationServer.sharedInstance()
        if clkServer.activeComplications != nil {
            let comp = clkServer.activeComplications.first
            if comp?.family == CLKComplicationFamily.ModularLarge {
                clkServer.reloadTimelineForComplication(comp)
            }
            if comp?.family == CLKComplicationFamily.ModularSmall {
                clkServer.reloadTimelineForComplication(comp)
            }
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("ON WATCH : \(applicationContext)")
        jarData = applicationContext as! [String:String]
        let defaultSize = jarData[jarSizeKey]
        let savedAmount = jarData[savedAmountInJarKey]
        if let n = NSNumberFormatter().numberFromString(savedAmount!) {
            currentAmount = Float(n)
        }
        if let k = NSNumberFormatter().numberFromString(defaultSize!) {
            allowance = Float(k)
        }
        
        NSUserDefaults.standardUserDefaults().setValue(jarData, forKey: jarKey)
        
        updateComplication()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
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
        
        updateComplication()
        
        if (updateClosure != nil) {
            updateClosure()
        }
        
        replyHandler(["reply":"GOT THE MESSAGE"])
    }

    func applicationDidBecomeActive() {
    }

    func applicationWillResignActive() {

        jarData[savedAmountInJarKey] = "\(currentAmount)"
        sharedDefaults.setObject(jarData, forKey: jarKey)
        if sharedDefaults.objectForKey(jarKey) != nil {
            let session = WCSession.defaultSession()
            do {
                try session.updateApplicationContext(jarData)
            }
            catch {
                print("wut")
            }
            
            session.sendMessage(jarData, replyHandler: nil, errorHandler: nil)
        }
        print("calling will resign active current amoutn \(currentAmount) jar dara \(jarData)")
        updateComplication()
    }
}


