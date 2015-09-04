//
//  AppDelegate.swift
//  SimpleJar
//
//  Created by Kevin Taniguchi on 8/22/15.
//  Copyright (c) 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var mainNavController : UINavigationController?
    var jarViewController : JarViewController?
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey",jarKey = "com.taniguchi.JarKey"
    let session = WCSession.defaultSession()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainNavController = UINavigationController()
        jarViewController = JarViewController()
        mainNavController?.pushViewController(jarViewController!, animated: false)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = mainNavController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        sendDataToWatch()
        jarViewController?.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        sendDataToWatch()
        jarViewController?.save()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        session.delegate = self
        session.activateSession()
        
        jarViewController?.updateData()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        jarViewController?.updateJarView()
    }

    func applicationWillTerminate(application: UIApplication) {
        jarViewController?.save()
        sendDataToWatch()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let jarData = applicationContext as! [String:String]
        
        updateJarViewWithAmount(jarData)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let jarData = message as! [String:String]
        
        // call method to update the JARVC
        updateJarViewWithAmount(jarData)
    }
    
    func updateJarViewWithAmount (newJarData: [String:String]) {
        var oldJarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
        let newCurrentAmount = extractAmount(newJarData)
        oldJarData[savedAmountInJarKey] = "\(newCurrentAmount)"
        sharedDefaults.setObject(oldJarData, forKey: jarKey)
        sharedDefaults.synchronize()
        jarViewController?.jarData = oldJarData
        jarViewController?.updateData()
    }
    
    func extractAmount (jarData : [String:String]) -> CGFloat {
        let savedAmount = jarData[savedAmountInJarKey]
        if let n = NSNumberFormatter().numberFromString(savedAmount!) {
            return CGFloat(n)
        }
        return 0.0
    }
    
    func extractAllowance (jarData : [String:String]) -> Float {
        let savedAllowance = jarData[jarSizeKey]
        if let n = NSNumberFormatter().numberFromString(savedAllowance!) {
            return Float(n)
        }
        return 0.0
    }
    
    func sendDataToWatch () {
        if WCSession.isSupported() {
            if sharedDefaults.objectForKey(jarKey) != nil {
                if session.paired && session.watchAppInstalled {
                    let jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
                    do {
                        try session.updateApplicationContext(jarData)
                    }
                    catch {
                        print("wut")
                    }
                    
                    session.sendMessage(jarData, replyHandler: { reply in
                        print("RESPONSE : \(reply)")
                    }, errorHandler: { error in
                        print("ERROR : \(error)")
                    })
                }
            }
        }
    }
}

