//
//  ComplicationController.swift
//  SimpleJarWatch Extension
//
//  Created by Kevin Taniguchi on 8/29/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var currentAmount : Float = 0.0, allowance : Float = 0.0
    var jarData = [String:String]()
    let moneyJarSizeKey = "moneyJarSizeKey", savedAmountInJarKey = "moneyJarSavedAmountKey" ,jarKey = "com.taniguchi.MoneyJarKey"
    
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
        handler([getTimelineEntryForFamily(complication.family)])
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler([getTimelineEntryForFamily(complication.family)])
    }
    
    // MARK : - Convenience
    
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
        let calendar = NSCalendar.currentCalendar()
        let newDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
        handler(newDate);
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
        placeHolder.line2TextProvider = CLKSimpleTextProvider(text: String(format: "%d", Int(10.0)))
        return placeHolder
    }
    
    func setData() {
        guard let defaults = sharedDefaults.objectForKey(jarKey), jarData = defaults.objectForKey(jarKey) as? [String:String] else { return }
        
        if let defaultSize = jarData[moneyJarSizeKey] {
            if defaultSize.isEmpty {
                allowance = Float(100.0)
                
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
