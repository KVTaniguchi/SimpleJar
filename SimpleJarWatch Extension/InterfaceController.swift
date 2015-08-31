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


class InterfaceController: WKInterfaceController {
    @IBOutlet var allowanceLabel: WKInterfaceLabel!
    @IBOutlet var addAmountButton: WKInterfaceButton!
    @IBOutlet var subtractAmountButton: WKInterfaceButton!
    
    @IBOutlet var currentAmountPicker: WKInterfacePicker!
    
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey" ,jarKey = "com.taniguchi.JarKey"
    let extensionDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
    var currentAmount : Float = 0.0, allowance : Float = 0.0
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateData()
        
        var pickerItems = [WKPickerItem]()
        let intAmount = Int(currentAmount) + 1000
        for index in 0...intAmount {
            let pickerItem = WKPickerItem()
            pickerItem.title = "$\(index).00"
            pickerItem.caption = "Remaining:"
            pickerItems.append(pickerItem)
        }
        
        currentAmountPicker.setItems(pickerItems)
        currentAmountPicker.setSelectedItemIndex(Int(currentAmount))
    }
    
    @IBAction func pickerChangedValue(value: Int) {
        currentAmount = Float(value)
        extensionDelegate.currentAmount = currentAmount
    }
    
    @IBAction func addButtonPress() {
        currentAmount += 1.0
        currentAmountPicker.setSelectedItemIndex(Int(currentAmount))
        extensionDelegate.currentAmount = currentAmount
    }
    
    @IBAction func subtractButtonPress() {
        currentAmount -= 1.0
        currentAmountPicker.setSelectedItemIndex(Int(currentAmount))
        extensionDelegate.currentAmount = currentAmount
    }
    
    func updateData () {
        if sharedDefaults.objectForKey(jarKey) != nil {
            jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
            
            let defaultSize = jarData[jarSizeKey]
            let savedAmount = jarData[savedAmountInJarKey]
            if let n = NSNumberFormatter().numberFromString(savedAmount!) {
                currentAmount = Float(n)
            }
            if let k = NSNumberFormatter().numberFromString(defaultSize!) {
                allowance = Float(k)
            }
        }
        
        print("WATCH CURRENT AMOUNT \(currentAmount) ALLOWANCE \(allowance)")

        allowanceLabel.setText(String(format: "$%.2f", allowance))
    }

    override func willActivate() {
        updateData()

        super.willActivate()
    }

    override func didDeactivate() {
        print("IF: didDeactivate")
        jarData[jarSizeKey] = "\(allowance)"
        jarData[savedAmountInJarKey] = "\(currentAmount)"
        sharedDefaults.setValue(jarData, forKey: jarKey)
        
        do {
            try WCSession.defaultSession().updateApplicationContext(jarData)
        }
        catch {
            print("wut")
        }

        super.didDeactivate()
    }

}
