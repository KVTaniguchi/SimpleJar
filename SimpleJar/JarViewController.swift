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
    var jarSize : CGFloat = 100.0
    var amountInJar : CGFloat = 0.0
    let jarSizeKey = "jarSizeKey"
    let savedAmountInJarKey = "jarSavedAmountKey"
    
    var addButton = UIButton()
    var subtractButton = UIButton()
    
    var jarImageView = UIImageView()
    var jarAmountView = UIView()
    
    var currentAmount : Float = 0.0
    // jar values : 1) default jar size 2) current amount in jar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let banner = ADBannerView()
        banner.delegate = self
        view.addSubview(banner)
        
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
        // todo set to saved amount
        currentAmount = Float(jarSize)
        
        view.backgroundColor = UIColor.whiteColor()
        
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
        
        
        // TODO offet from the bottom by 50
        
        jarImageView = UIImageView(image: UIImage(named: "milkSolidClearHold"))
        jarImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        originalContentView.addSubview(jarImageView)
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jarImg]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jarImg":jarImageView]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[jarImg]-[add(sub)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jarImg":jarImageView, "add":addButton, "sub":subtractButton]))
        
        jarAmountView.backgroundColor = UIColor.greenColor()
        jarAmountView.setTranslatesAutoresizingMaskIntoConstraints(false)
        originalContentView.addSubview(jarAmountView)
        originalContentView.sendSubviewToBack(jarAmountView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jar]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jar":jarAmountView]))
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: jarImageView, attribute: .Height, multiplier: 0.75, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: jarAmountView, attribute: .Bottom, relatedBy: .Equal, toItem: jarImageView, attribute: .Bottom, multiplier: 1.0, constant: 0)])

//        UIImage *_maskingImage = [UIImage imageNamed:@"ipadmask.jpg"];
//        CALayer *_maskingLayer = [CALayer layer];
//        _maskingLayer.frame = vistafunda.bounds;
//        [_maskingLayer setContents:(id)[_maskingImage CGImage]];
//        [vistafunda.layer setMask:_maskingLayer];
//        vistafunda.layer.masksToBounds = YES;
        
//        let maskingImage = UIImage(named: "milkMaskSolid")
//        let maskingLayer = CALayer()
//        maskingLayer.frame = CGRectMake(0, 150, 200, 400)
//        maskingLayer.opacity = 1
//        maskingLayer.contents = maskingImage
//        jarAmountView.layer.mask = maskingLayer
    }
    
    override func viewDidLayoutSubviews() {
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
        

        // 306.5
        currentAmount -= 1.0
        println(currentAmount)
        let initialHeight = jarAmountView.frame.height
        let decrement = initialHeight/jarSize
        
        var frame = jarAmountView.frame
        frame.size.height -= decrement
        frame.origin.y += decrement
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

