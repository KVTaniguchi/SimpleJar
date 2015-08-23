//
//  JarViewController.swift
//  SimpleJar
//
//  Created by Kevin Taniguchi on 8/22/15.
//  Copyright (c) 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import CoreData
import iAd

class JarViewController: UIViewController, ADBannerViewDelegate {
    
    var entries = [NSManagedObject]()
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    let jarKey = "com.taniguchi.JarKey"
    var jarData = [String:String]()
    var jarSize : CGFloat = 0.0
    var amountInJar : CGFloat = 0.0
    let jarSizeKey = "jarSizeKey"
    let savedAmountInJarKey = "jarSavedAmountKey"
    
    var addButton = UIButton()
    var subtractButton = UIButton()
    
    
    var jarAmountView = UIView()
    // jar values : 1) default jar size 2) current amount in jar
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canDisplayBannerAds = true
     
        var entry = ENTRY()
        
        navigationController?.navigationBarHidden = true
        
        if sharedDefaults.objectForKey(jarKey) != nil {
            jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
            let defaultSize = jarData[jarSizeKey]
            let savedAmount = jarData[savedAmountInJarKey]
            if let n = NSNumberFormatter().numberFromString(savedAmount!) {
                amountInJar = CGFloat(n)
            }
            if let k = NSNumberFormatter().numberFromString(defaultSize!) {
                jarSize = CGFloat(k)
            }
        }
        
        view.backgroundColor = UIColor.redColor()
        
        addButton.setImage(UIImage(named: "plus-100"), forState: .Normal)
        addButton.addTarget(self, action: "addButtonPressed", forControlEvents: .TouchUpInside)
//        addButton.addTarget(self, action: "addButtonHeld", forControlEvents: UIControlEvents.to)
        addButton.backgroundColor = UIColor.blueColor()
        subtractButton.setImage(UIImage(named: "minus-100"), forState: .Normal)
        subtractButton.backgroundColor = UIColor.purpleColor()
        subtractButton.addTarget(self, action: "subtractButtonPressed", forControlEvents: .TouchUpInside)
        [addButton,subtractButton].map { button -> UIButton in
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.originalContentView.addSubview(button)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.blackColor().CGColor
            NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self.originalContentView, attribute: .Bottom, multiplier: 1.0, constant: 0)])
            return button
        }
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[addBtn][subBtn(addBtn)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["addBtn":addButton, "subBtn":subtractButton]))
        
        jarAmountView.backgroundColor = UIColor.greenColor()
        jarAmountView.setTranslatesAutoresizingMaskIntoConstraints(false)
        originalContentView.addSubview(jarAmountView)
        
    
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jar]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jar":jarAmountView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[jar]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jar":jarAmountView]))
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: jarAmountView, attribute: .Bottom, relatedBy: .Equal, toItem: addButton, attribute: .Top, multiplier: 1.0, constant: 10)])
        
        let jarImageView = UIImageView(image: UIImage(named: "milkMaskSolid"))
//        jarImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        jarImageView.sizeToFit()
        originalContentView.addSubview(jarImageView)
        
        jarAmountView.maskView = jarImageView

    }
    
    func addButtonPressed () {
        var frame = jarAmountView.frame
        frame.size.height += 1.0
        frame.origin.y -= 1.0
        UIView.animateWithDuration(0.01, animations: {
            self.jarAmountView.frame = frame
        })
    }
    
    func subtractButtonPressed () {
        var frame = jarAmountView.frame
        frame.size.height -= 1.0
        frame.origin.y += 1.0
        UIView.animateWithDuration(0.01, animations: {
            self.jarAmountView.frame = frame
        })
    }
    
    func addButtonHeld () {
        println("add held")
    }
    
    func saveEntry (entry : ENTRY) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: managedContext)
        
        let newEntry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        // set values here
        // maybe can just instantiate the entry when adding / subtracting ?
//        newEntry.setValue(<#value: AnyObject?#>, forKey: <#String#>)
    }
}

