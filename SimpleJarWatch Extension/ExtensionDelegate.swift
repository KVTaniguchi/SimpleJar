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
        guard let data = sharedDefaults.objectForKey(jarKey) as? [String:String]  else { return }
        jarData = data
        updateComplication()
    }
    
    func updateComplication () {
        let clkServer = CLKComplicationServer.sharedInstance()
        if clkServer.activeComplications != nil {
            for comp in clkServer.activeComplications! {
                clkServer.reloadTimelineForComplication(comp)
            }
        }
    }
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        
    }
    
    
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        saveMessage(applicationContext)
        
        updateComplication()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        saveMessage(message)
        
        updateComplication()
        updateClosure()
        
        replyHandler(["reply":"GOT THE MESSAGE xoxoxo \(message)"])
    }

    func applicationDidBecomeActive() {
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
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
                    print("ERROR \(error)")
                }
                
                if session.reachable {
                    session.sendMessage(jarData, replyHandler: nil, errorHandler: nil)
                }
            }
        }
        updateComplication()
    }
    
    // MARK - helpers
    func saveMessage (message: [String : AnyObject]) {
        guard let data = message as? [String:Float] else { return }
        let defaultSize = data[jarSizeKey]
        let savedAmount = data[savedAmountInJarKey]
        if let k = defaultSize {
            allowance = k
        }
        if let n = savedAmount {
            currentAmount = n
        }

        sharedDefaults.setObject(data, forKey: jarKey)
        updateComplication()
    }
}
