//
//  ExtensionDelegate.swift
//  SimpleJarWatch Extension
//
//  Created by Kevin Taniguchi on 8/29/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey" ,jarKey = "com.taniguchi.JarKey"
    let session = WCSession.defaultSession()
    var currentAmount : Float = 0.0, allowance : Float = 0.0

    func applicationDidFinishLaunching() {
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
            
            print("DID FINISH EXT : \(session)")
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

        sharedDefaults.setValue(applicationContext, forKey: jarKey)
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        if sharedDefaults.objectForKey(jarKey) != nil {
            do {
                try session.updateApplicationContext(jarData)
            }
            catch {
                print("wut")
            }
        }
    }
}


