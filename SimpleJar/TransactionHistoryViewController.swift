//
//  TransactionHistoryViewController.swift
//  SimpleJar
//
//  Created by Kevin Taniguchi on 9/9/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import CoreData

class TransactionHistoryViewController: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let fetchRequest = NSFetchRequest(entityName:"Transaction")
    
    var fetchResults : [NSManagedObject] {
        get {
            do {
                let fetchResults = try moc.executeFetchRequest(fetchRequest)
                return fetchResults as! [NSManagedObject]
            }
            catch let error as NSError {
                print(error)
                return []
            }
        }
    }
    
    var moc : NSManagedObjectContext {
        get {
            return appDelegate.managedObjectContext
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = false
        view.backgroundColor = UIColor.orangeColor()
    
        for transaction in fetchResults {
            let value = transaction.valueForKey("amount")
            let date = transaction.valueForKey("date")
            print("value \(value) date \(date)")
        }
    }
}
//do {
//    try moc.save()
//}
//catch let error as NSError {
//    print(error)
//}

////1
//let appDelegate =
//UIApplication.sharedApplication().delegate as! AppDelegate
//
//let managedContext = appDelegate.managedObjectContext!
//
////2
//let fetchRequest = NSFetchRequest(entityName:"Person")
//
////3
//var error: NSError?
//
//let fetchedResults =
//managedContext.executeFetchRequest(fetchRequest,
//    error: &error) as? [NSManagedObject]
//
//if let results = fetchedResults {
//    people = results
//} else {
//    println("Could not fetch \(error), \(error!.userInfo)")
//}