//
//  TransactionHistoryViewController.swift
//  SimpleJar
//
//  Created by Kevin Taniguchi on 9/9/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import CoreData

class TransactionHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let fetchRequest = NSFetchRequest(entityName:"Transaction")
    var fetchResults : [NSManagedObject]? {
        get {
            do {
                guard let managedObjectContext = moc else { return nil }
                let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest)
                return (fetchResults as! [NSManagedObject]).reverse()
            }
            catch let error as NSError {
                print(error)
                return []
            }
        }
    }
    var moc : NSManagedObjectContext? {
        guard let appDel = UIApplication.sharedApplication().delegate as? AppDelegate else { return nil }
        return appDel.managedObjectContext }
    
    private static var formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy   HH:mm"
        return formatter
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        title = "History"
        navigationController?.navigationBarHidden = false
        view.backgroundColor = UIColor.orangeColor()
        
        let tableView = UITableView(frame: view.frame, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(TransactionCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = fetchResults else { return 0 }
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let results = fetchResults else { return UITableViewCell() }
        let transaction = results[indexPath.row]
        let value = transaction.valueForKey("amount") as! Float
        let date = transaction.valueForKey("date") as! NSDate
        let dateString = TransactionHistoryViewController.formatter.stringFromDate(date)
        let signString = value < 0 ? "-" : "+"
        let amountString = String(format: "\(signString) $%.2f", abs(value))
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TransactionCell
        cell.dateLabel.text = dateString
        cell.amountLabel.text = amountString
        return cell
    }
}

class TransactionCell: UITableViewCell {
    
    let dateLabel = UILabel(), amountLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userInteractionEnabled = false
        for label in [dateLabel, amountLabel] {
            label.textColor = UIColor.darkGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
        dateLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        amountLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        amountLabel.textAlignment = .Right
        dateLabel.textAlignment = .Left
        let views = ["dateLabel":dateLabel, "amountLabel":amountLabel]
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dateLabel]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[dateLabel][amountLabel]-15-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
