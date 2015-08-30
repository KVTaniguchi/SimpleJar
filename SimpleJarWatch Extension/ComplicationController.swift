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

//        var entry = CLKComplicationTimelineEntry()
        
        switch complication.family {
        case .ModularLarge :
            print("mod large")
//            entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: getDeviceInfoForModularLargeTemplate(extensionDelegate.items))
//            handler(entry)
            break
        case .ModularSmall :
            print("mod small")
        case .UtilitarianLarge:
            print("util large")
        case .UtilitarianSmall :
            print("util small")
        case .CircularSmall:
            print("circ small")
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
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .ModularLarge :
            print("mod large")
            handler(defaultModularLargeTemplate())
            break
        case .ModularSmall :
            print("mod small")
//            handler(defaultModularSmallTemplate())
        case .UtilitarianLarge:
            print("util large")
        case .UtilitarianSmall :
            print("util small")
        case .CircularSmall:
            print("circ small")
        }
        handler(nil)
    }

    func defaultModularLargeTemplate () -> CLKComplicationTemplateModularLargeTallBody {
        let placeHolder = CLKComplicationTemplateModularLargeTallBody()
        placeHolder.headerTextProvider = CLKSimpleTextProvider(text: "Remaining:")
        placeHolder.bodyTextProvider = CLKSimpleTextProvider(text: String(format: "$0.00"))
        return placeHolder
    }
    
    func defaultModularSmallTemplate () -> CLKComplicationTemplateModularSmallRingText {
        let placeHolder = CLKComplicationTemplateModularSmallRingText()
        placeHolder.textProvider = CLKSimpleTextProvider(text: String(format: "$0.00"))
        placeHolder.fillFraction = extensionDelegate.currentAmount / extensionDelegate.allowance
        placeHolder.ringStyle = .Closed
        return placeHolder
    }
    
}
