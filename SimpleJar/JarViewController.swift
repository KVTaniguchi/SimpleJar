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
    
    var delta :Float = 0.0
    var currentJarFrameHeight : CGFloat = 0.0
    
    var jarHeightConstraint : NSLayoutConstraint?
    
//    var center: Point {
//        get {
//            let centerX = origin.x + (size.width / 2)
//            let centerY = origin.y + (size.height / 2)
//            return Point(x: centerX, y: centerY)
//        }
//        set(newCenter) {
//            origin.x = newCenter.x - (size.width / 2)
//            origin.y = newCenter.y - (size.height / 2)
//        }
//    }
    
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
            self.view.addSubview(button)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.blackColor().CGColor
            return button
        }
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[addBtn][subBtn(addBtn)]|", options: .AlignAllCenterY, metrics: nil, views: ["addBtn":addButton, "subBtn":subtractButton]))
        
        // TODO offet from the bottom by 50
        
        jarImageView = UIImageView(image: UIImage(named: "milkSolidClearHold"))
        jarImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(jarImageView)
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jarImg]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jarImg":jarImageView]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[jarImg]-[add(sub)]-50-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jarImg":jarImageView, "add":addButton, "sub":subtractButton]))
        
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
        
        jarAmountView.backgroundColor = UIColor.greenColor()
        jarAmountView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(jarAmountView)
        view.sendSubviewToBack(jarAmountView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jar]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["jar":jarAmountView]))
        
        jarHeightConstraint = NSLayoutConstraint(item: jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: jarImageView, attribute: .Height, multiplier: 0.8, constant: 0)
        
        NSLayoutConstraint.activateConstraints([jarHeightConstraint!])
        
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: jarAmountView, attribute: .Bottom, relatedBy: .Equal, toItem: jarImageView, attribute: .Bottom, multiplier: 1.0, constant: -17)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let initialHeight = Float(jarImageView.frame.height * 0.8)
        delta = initialHeight/Float(jarSize)
        
        if currentJarFrameHeight == 0 {
            currentJarFrameHeight = jarImageView.frame.height * 0.8
        }
        
        println("did layout subviews current amount : \(currentAmount) currentJarFrameHeight \(currentJarFrameHeight)")
        
        drawJarAmountViewWithHeight(currentJarFrameHeight)
        
    }
    
    func drawJarAmountViewWithHeight (height : CGFloat) {
        NSLayoutConstraint.deactivateConstraints([jarHeightConstraint!])
        jarHeightConstraint = NSLayoutConstraint(item: jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
        NSLayoutConstraint.activateConstraints([jarHeightConstraint!])
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


        
        var frame = jarAmountView.frame
        frame.size.height -= CGFloat(delta)
        frame.origin.y += CGFloat(delta)
        currentJarFrameHeight = frame.size.height
        UIView.animateWithDuration(0.01, animations: {
            self.jarAmountView.frame = frame
        })
        
                println("Current amount : \(currentAmount) DECREMENT: \(delta) currentJarFramehight : \(currentJarFrameHeight)")
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

