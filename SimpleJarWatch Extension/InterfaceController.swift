//
//  InterfaceController.swift
//  SimpleJarWatch Extension
//
//  Created by Kevin Taniguchi on 8/29/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import ClockKit

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var allowanceLabel: WKInterfaceLabel!
    
    @IBOutlet var previewLabel: WKInterfaceLabel!
    @IBOutlet var currentAmountPicker: WKInterfacePicker!
    
    @IBOutlet var afterLabel: WKInterfaceLabel!
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey", jarKey = "com.taniguchi.JarKey"
    let extensionDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
    var currentAmount : Float = 0.0, allowance : Float = 0.0, adjustedAmount : Float = 0.0
    let session = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
        
        var pickerItems = [WKPickerItem]()
        for index in -200...200 {
            let pickerItem = WKPickerItem()
            var sign = ""
            if index < 0 {
                sign = "-"
            }
            else {
                sign = "+"
            }
            pickerItem.title = "\(sign)$\(abs(index)).00"
            pickerItem.caption = index < 0 ? "Spent" : "Added"
            pickerItems.append(pickerItem)
        }
        
        currentAmountPicker.setItems(pickerItems)
        currentAmountPicker.setSelectedItemIndex(200)
        
        updateData()
        extensionDelegate.updateClosure = {
            self.updateData()
        }
    }
    
    @IBAction func pickerValueChanged(value: Int) {
        adjustedAmount = Float(value - 200)
        previewLabel.setAlpha(1.0)
        let previewAmount = currentAmount + adjustedAmount
        if previewAmount == 0.0 {
            previewLabel.setText("")
        }
        else {
            afterLabel.setText("After:")
            previewLabel.setText(String(format: "$%.2f", previewAmount))
        }
    }
    
    @IBAction func saveButtonPressed() {
        currentAmount += adjustedAmount
        allowanceLabel.setText(String(format: "$%.2f", currentAmount))
        currentAmountPicker.setSelectedItemIndex(200)
        previewLabel.setText("")
        afterLabel.setText("")
        adjustedAmount = 0.0
        saveData()
    }
    
    @IBAction func resetButtonPressed() {
        previewLabel.setText("")
    }
    
    func updateData () {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.valueForKey(jarKey) != nil {
            
            jarData = defaults.objectForKey(jarKey) as! [String:String]
            
            let defaultSize = jarData[jarSizeKey]
            let savedAmount = jarData[savedAmountInJarKey]
            
            if let k = defaultSize {
                allowance = Float(k as String)!
            }
            if let n = savedAmount {
                currentAmount = Float(n as String)!
            }
            
            allowanceLabel.setText(String(format: "$%.2f", currentAmount))
            previewLabel.setText(String(format: "$%.2f", currentAmount))
        }
    }

    override func willActivate() {
        updateData()
        
        super.willActivate()
    }
    
    override func willDisappear() {
        saveData()

        super.willDisappear()
    }

    override func didDeactivate() {
        saveData()
        
        super.didDeactivate()
    }
    
    func saveData () {
        adjustedAmount = 0.0
        previewLabel.setText("")
        jarData[savedAmountInJarKey] = "\(currentAmount)"
        NSUserDefaults.standardUserDefaults().setObject(jarData, forKey: jarKey)
        sharedDefaults.setObject(jarData, forKey: jarKey)
        do {
            try session.updateApplicationContext(jarData)
        }
        catch {
            print("Warning - Error sending to watch : \(error)")
        }
        
        session.sendMessage(jarData, replyHandler: nil, errorHandler: nil)
        extensionDelegate.jarData = jarData
        extensionDelegate.currentAmount = currentAmount
        extensionDelegate.updateComplication()
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
        
        
        replyHandler(["reply":"GOT THE MESSAGE xoxoxo \(message)"])
    }
    
    func updateComplication () {
        let clkServer = CLKComplicationServer.sharedInstance()
        if clkServer.activeComplications != nil {
            for comp in clkServer.activeComplications! {
                clkServer.reloadTimelineForComplication(comp)
            }
        }
    }
    
    func saveMessage (message: [String : AnyObject]) {
        let defaultSize = message[jarSizeKey] as? String
        let savedAmount = message[savedAmountInJarKey] as? String
        if let k = defaultSize {
            allowance = Float(k)!
        }
        if let n = savedAmount {
            currentAmount = Float(n)!
        }

        sharedDefaults.setObject(message, forKey: jarKey)
        updateComplication()
        updateData()
    }
}
