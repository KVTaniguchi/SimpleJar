//
//  ComplicationController.swift
//  SimpleJarWatch Extension
//
//  Created by Kevin Taniguchi on 8/29/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource, WKExtensionDelegate {
    
    let extensionDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var currentAmount : Float = 0.0, allowance : Float = 0.0
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey" ,jarKey = "com.taniguchi.JarKey"
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward, .Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        setData()
        
        print("CC get current tieline, CURRENT: \(currentAmount) ALLOWANCE : \(allowance)")
        
        switch complication.family {
        case .ModularLarge :
            print("00 mod large")
            let largeMod = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultModularLargeTemplate())
            handler(largeMod)
            break
        case .ModularSmall :
            print("00 mod small")
            let smallMod = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultModularSmallTemplate())
            handler(smallMod)
            break
        case .UtilitarianLarge:
            print("00 util large")
        case .UtilitarianSmall :
            print("00 util small")
        case .CircularSmall:
            print("00 circ small")
        }
        
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    func getTimelineEntryForFamily (family : CLKComplicationFamily) -> CLKComplicationTimelineEntry {
        setData()
        let entry = CLKComplicationTimelineEntry()
        switch family {
        case .ModularLarge :
            print("mod large")
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultModularLargeTemplate())
        case .ModularSmall :
            print("mod small")
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultModularSmallTemplate())
        case .UtilitarianLarge:
            print("util large")
        case .UtilitarianSmall :
            print("util small")
        case .CircularSmall:
            print("circ small")
        }
        
        return entry
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        setData()
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        setData()
        
        switch complication.family {
        case .ModularLarge :
            print("11 mod large")
            handler(defaultModularLargeTemplate())
            break
        case .ModularSmall :
            print("11 mod small")
            handler(defaultModularSmallTemplate())
        case .UtilitarianLarge:
            print("11 util large")
        case .UtilitarianSmall :
            print("11 util small")
        case .CircularSmall:
            print("11 circ small")
        }
        handler(nil)
    }

    func defaultModularLargeTemplate () -> CLKComplicationTemplateModularLargeTallBody {
        setData()
        let placeHolder = CLKComplicationTemplateModularLargeTallBody()
        placeHolder.headerTextProvider = CLKSimpleTextProvider(text: "Remaining:")
        placeHolder.bodyTextProvider = CLKSimpleTextProvider(text: String(format: "$%.2f", currentAmount))
        return placeHolder
    }
    
    func defaultModularSmallTemplate () -> CLKComplicationTemplateModularSmallSimpleText {
        setData()
        let placeHolder = CLKComplicationTemplateModularSmallSimpleText()
        placeHolder.textProvider = CLKSimpleTextProvider(text: String(format: "$%f", currentAmount))
        return placeHolder
    }
    
    func setData () {
        if sharedDefaults.objectForKey(jarKey) != nil {
            jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
            
            if var defaultSize = jarData[jarSizeKey] {
                if defaultSize.isEmpty {
                    defaultSize = "100"
                }
                else {
                    if let k = NSNumberFormatter().numberFromString(defaultSize) {
                        allowance = Float(k)
                    }
                }
            }
            if let savedAmount = jarData[savedAmountInJarKey] {
                if let n = NSNumberFormatter().numberFromString(savedAmount) {
                    currentAmount = Float(n)
                }
            }
        }
    }
    
}
