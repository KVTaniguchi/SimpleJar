//
//  AppDelegate.swift
//  SimpleJar
//
//  Created by Kevin Taniguchi on 8/22/15.
//  Copyright (c) 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var mainNavController : UINavigationController?
    var jarViewController : JarViewController?
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey",jarKey = "com.taniguchi.JarKey"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainNavController = UINavigationController()
        jarViewController = JarViewController()
        mainNavController?.pushViewController(jarViewController!, animated: false)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = mainNavController
        window?.makeKeyAndVisible()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cloudKitNotif", name:  NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        
        return true
    }
    
    func cloudKitNotif() {
        print("asfasdfsdfq2341234234lasdflsdfjljlk")
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
        WCSession.defaultSession().delegate = self
        WCSession.defaultSession().activateSession()

        jarViewController?.updateData()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        jarViewController?.updateJarView()
    }

    func applicationWillTerminate(application: UIApplication) {
        jarViewController?.save()
        sendDataToWatch()
    }
    
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let jarData = applicationContext as! [String:String]
        
        updateJarViewWithAmount(jarData)
    }
    
    @available(iOS 9.0, *)
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
        jarViewController?.jarData = oldJarData
        jarViewController?.updateData()
        jarViewController?.updateJarView()
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
                
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
                
                if session.paired && session.watchAppInstalled {
                    let jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
                    do {
                        try session.updateApplicationContext(jarData)
                    }
                    catch {
                        print("Error updating context: \(error)")
                    }
                    
                    if session.reachable {
                        session.sendMessage(jarData, replyHandler: { reply in
                            print("RESPONSE : \(reply)")
                            }, errorHandler: { error in
                                print("Error sending message : \(error)")
                        })
                    }
                }
            }
        }
    }
    
    // Mark Core Data Stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Taniguchi.CoreDataTests" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("TransactionModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."

        
//        -(NSURL *)cloudDirectory
//            {
//                NSFileManager *fileManager=[NSFileManager defaultManager];
//                NSString *teamID=@"iCloud";
//                NSString *bundleID=[[NSBundle mainBundle]bundleIdentifier];
//                NSString *cloudRoot=[NSString stringWithFormat:@"%@.%@",teamID,bundleID];
//                NSURL *cloudRootURL=[fileManager URLForUbiquityContainerIdentifier:cloudRoot];
//                NSLog (@"cloudRootURL=%@",cloudRootURL);
//                return cloudRootURL;
//        }
        
//        NSDictionary *storeOptions =@{NSPersistentStoreUbiquitousContentNameKey: @"iCloud",
//            NSPersistentStoreUbiquitousContentURLKey:[self cloudDirectory],
//        };
        
        let fileManager = NSFileManager.defaultManager()
        let teamID = "3B3FT42G96"
        guard let bundleID = NSBundle.mainBundle().bundleIdentifier else  { return coordinator }
        let cloudRoot = "\(teamID).\(bundleID)"
        // TODO find out why this is failing
        if let cloudRootURL = fileManager.URLForUbiquityContainerIdentifier(cloudRoot) {
            print("CLOUD ROOT URL \(cloudRootURL.absoluteString)")
        }
        
        let options = [NSPersistentStoreUbiquitousContentNameKey:"iCloud", NSMigratePersistentStoresAutomaticallyOption:NSNumber(bool: true), NSInferMappingModelAutomaticallyOption:NSNumber(bool: true), NSPersistentStoreUbiquitousContentURLKey:"iCloud.com.Taniguchi.MoneyJar"]
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
            
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}
