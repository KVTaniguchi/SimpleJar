//
//  InterfaceController.swift
//  SimpleJarWatch Extension
//
//  Created by Kevin Taniguchi on 8/29/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var currentAmountLabel: WKInterfaceLabel!
    @IBOutlet var allowanceLabel: WKInterfaceLabel!
    @IBOutlet var addAmountButton: WKInterfaceButton!
    @IBOutlet var subtractAmountButton: WKInterfaceButton!
    
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey", savedJarHeightKey = "savedJarHeightKey" ,jarKey = "com.taniguchi.JarKey"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
    }

    override func willActivate() {

        super.willActivate()
    }

    override func didDeactivate() {

        super.didDeactivate()
    }

}
