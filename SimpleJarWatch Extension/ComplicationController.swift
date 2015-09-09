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

        handler(getTimelineEntryForFamily(complication.family))
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
        switch family {
        case .ModularLarge :
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultModularLargeTemplate())
        case .ModularSmall :
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultModularSmallTemplate())
        case .UtilitarianLarge:
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultUtilLargeTemplate())
        case .UtilitarianSmall :
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultUtilSmallTemplate())
        case .CircularSmall:
            return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: defaultCircularSmallTemplate())
        }
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        setData()
        
        switch complication.family {
        case .ModularLarge :
            handler(defaultModularLargeTemplate())
        case .ModularSmall :
            handler(defaultModularSmallTemplate())
        case .UtilitarianLarge:
            handler(defaultUtilLargeTemplate())
        case .UtilitarianSmall :
            handler(defaultUtilSmallTemplate())
        case .CircularSmall:
            handler(defaultCircularSmallTemplate())
        }
        handler(nil)
    }

    func defaultModularLargeTemplate () -> CLKComplicationTemplateModularLargeTallBody {
        let placeHolder = CLKComplicationTemplateModularLargeTallBody()
        placeHolder.headerTextProvider = CLKSimpleTextProvider(text: "Remaining:")
        placeHolder.bodyTextProvider = CLKSimpleTextProvider(text: String(format: "$%.2f", currentAmount))
        return placeHolder
    }
    
    func defaultModularSmallTemplate () -> CLKComplicationTemplateModularSmallStackText {
        let placeHolder = CLKComplicationTemplateModularSmallStackText()
        placeHolder.line1TextProvider = CLKSimpleTextProvider(text: "$")
        placeHolder.line2TextProvider = CLKSimpleTextProvider(text: String(format: "%d", Int(currentAmount)))
        return placeHolder
    }
    
    func defaultUtilLargeTemplate () -> CLKComplicationTemplateUtilitarianLargeFlat {
        let placeHolder = CLKComplicationTemplateUtilitarianLargeFlat()
        placeHolder.textProvider = CLKSimpleTextProvider(text: String(format: "$%.2f", currentAmount))
        return placeHolder
    }
    
    func defaultUtilSmallTemplate () -> CLKComplicationTemplateUtilitarianSmallFlat {
        let placeHolder = CLKComplicationTemplateUtilitarianSmallFlat()
        placeHolder.textProvider = CLKSimpleTextProvider(text: String(format: "$%.2f", currentAmount))
        return placeHolder
    }
    
    func defaultCircularSmallTemplate () -> CLKComplicationTemplateCircularSmallStackText {
        let placeHolder = CLKComplicationTemplateCircularSmallStackText()
        placeHolder.line1TextProvider = CLKSimpleTextProvider(text: "$")
        placeHolder.line2TextProvider = CLKSimpleTextProvider(text: String(format: "%d", Int(currentAmount)))
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
