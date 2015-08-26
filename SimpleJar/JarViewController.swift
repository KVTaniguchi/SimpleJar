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
import URBNAlert

class JarViewController: UIViewController, ADBannerViewDelegate, UITextFieldDelegate {
    
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey", savedJarHeightKey = "savedJarHeightKey" ,jarKey = "com.taniguchi.JarKey"
    var addButton = UIButton(), subtractButton = UIButton(), changeAllowanceButton = UIButton(), addAllowanceButton = UIButton(), enterAddAmountButton = UIButton(), enterSubAmountButton = UIButton()
    var jarImageView = UIImageView(image: UIImage(named: "milkSolidClearHold"))
    var jarAmountView = UIView(), levelView = UIView()
    var currentAmount : Float = 0.0
    var currentJarFrameHeight : CGFloat = 0.0, amountInJar : CGFloat = 0.0, allowance : CGFloat = 0.00
    var jarHeightConstraint : NSLayoutConstraint?
    var levelLabel = UILabel()
    var changeAllowanceView : URBNAlertViewController!, enterAmountView : URBNAlertViewController!

    var currentAmountString : String {
        get {
            let formattedAmountString = String(format: "%.2f", currentAmount)
            return "You have $\(formattedAmountString) left"
        }
    }
    var allowanceString : String {
        get {
            return String(format: "$%.2f", allowance)
        }
    }
    
    var delta : Float {
        get {
            let initialHeight = Float(jarImageView.frame.height * 0.8)
            if currentAmount > Float(allowance) {
                return 0.0
            }
            return initialHeight/Float(allowance)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canDisplayBannerAds = true
        navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        
        if sharedDefaults.objectForKey(jarKey) != nil {
            jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
            let defaultSize = jarData[jarSizeKey]
            let savedAmount = jarData[savedAmountInJarKey]
            let savedAmountHeight = jarData[savedJarHeightKey]
            if let n = NSNumberFormatter().numberFromString(savedAmount!) {
                currentAmount = Float(n)
            }
            if let k = NSNumberFormatter().numberFromString(defaultSize!) {
                allowance = CGFloat(k)
            }
            if let j = NSNumberFormatter().numberFromString(savedAmountHeight!) {
                currentJarFrameHeight = CGFloat(j)
            }
        }
        else {
            currentAmount = Float(allowance)
            changeAllowanceButtonPressed()
        }
        
        view.backgroundColor = UIColor.whiteColor()
        levelLabel.font = UIFont(name: "Avenir", size: 25.0)
        levelLabel.textAlignment = .Center
        levelLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        levelLabel.text = currentAmountString
        view.addSubview(levelLabel)
        
        jarImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(jarImageView)
        jarAmountView.backgroundColor = UIColor(red: 22/255.0, green: 210/255.0, blue: 75/255.0, alpha: 1.0)
        jarAmountView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(jarAmountView)
        view.sendSubviewToBack(jarAmountView)
        
        addButton.setImage(UIImage(named: "plus-100"), forState: .Highlighted)
        addButton.setImage(offWhiteImage("plus-100"), forState: .Normal)
        addButton.addTarget(self, action: "addButtonPressed", forControlEvents: .TouchUpInside)
        addButton.backgroundColor = UIColor.darkGrayColor()
        subtractButton.setImage(UIImage(named: "minus-100"), forState: .Highlighted)
        subtractButton.setImage(offWhiteImage("minus-100"), forState: .Normal)
        subtractButton.backgroundColor = UIColor.darkGrayColor()
        subtractButton.addTarget(self, action: "subtractButtonPressed", forControlEvents: .TouchUpInside)
        
        changeAllowanceButton.setTitle("Allowance \(allowanceString)", forState: .Normal)
        changeAllowanceButton.backgroundColor = UIColor.darkGrayColor()
        changeAllowanceButton.addTarget(self, action: "changeAllowanceButtonPressed", forControlEvents: .TouchUpInside)
        addAllowanceButton.setTitle("Add \(allowanceString)", forState: .Normal)
        addAllowanceButton.backgroundColor = UIColor.darkGrayColor()
        addAllowanceButton.addTarget(self, action: "addAllowanceButtonPressed", forControlEvents: .TouchUpInside)
        [addButton, subtractButton, changeAllowanceButton, addAllowanceButton].map { button -> UIButton in
            button.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(button)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.blackColor().CGColor
            return button
        }
        
        enterAddAmountButton.setImage(offWhiteImage("plus-100"), forState: .Normal)
        enterSubAmountButton.setImage(offWhiteImage("minus-100"), forState: .Normal)
        
        [enterSubAmountButton, enterAddAmountButton].map{ button -> UIButton in
            button.backgroundColor = UIColor.grayColor()
            button.addTarget(self, action: "enterAmountButtonPressed:", forControlEvents: .TouchUpInside)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.cornerRadius = 5
            return button
        }
        
        addButton.addSubview(enterAddAmountButton)
        subtractButton.addSubview(enterSubAmountButton)
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[enterAdd(44)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["enterAdd":enterAddAmountButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[enterSub(44)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["enterSub":enterSubAmountButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[enterAdd(44)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["enterAdd":enterAddAmountButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[enterSub(44)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["enterSub":enterSubAmountButton]))
        
        let views = ["addBtn":addButton, "subBtn":subtractButton, "jarAmount":jarAmountView, "jarImg":jarImageView, "changeAllowance":changeAllowanceButton, "addAllowance":addAllowanceButton, "levelLbl":levelLabel, "enterAddBtn":enterAddAmountButton, "enterSubBtn":enterSubAmountButton]
        let metrics = ["statusBarH":UIApplication.sharedApplication().statusBarFrame.height + 5]
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[addBtn][subBtn(addBtn)]|", options: .AlignAllTop | .AlignAllBottom, metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[changeAllowance][addAllowance(changeAllowance)]|", options: .AlignAllTop | .AlignAllBottom, metrics: nil, views: views))

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jarImg]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[levelLbl]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-statusBarH-[changeAllowance(44)]-12-[levelLbl(20)]-12-[jarImg]-[addBtn(subBtn)]-50-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jarAmount]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        jarHeightConstraint = NSLayoutConstraint(item: jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: jarImageView, attribute: .Height, multiplier: 0.8, constant: 0)
        NSLayoutConstraint.activateConstraints([jarHeightConstraint!])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: jarAmountView, attribute: .Bottom, relatedBy: .Equal, toItem: jarImageView, attribute: .Bottom, multiplier: 1.0, constant: -17)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: levelLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if currentJarFrameHeight == 0 {
            currentJarFrameHeight = jarImageView.frame.height * 0.8
        }
        
        drawJarAmountViewWithHeight(currentJarFrameHeight)
    }
    
    func drawJarAmountViewWithHeight (height : CGFloat) {
        NSLayoutConstraint.deactivateConstraints([jarHeightConstraint!])
        jarHeightConstraint = NSLayoutConstraint(item: jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
        NSLayoutConstraint.activateConstraints([jarHeightConstraint!])
    }
    
    // PRAGMA MARK ACTIONS
    func enterAmountButtonPressed (sender : UIButton) {
        var title = ""
        var message = ""
        if sender == enterAddAmountButton {
            title = "Add Amount"
        }
        else {
            title = "Subtract Amount"
        }
        
        enterAmountView = URBNAlertViewController(title: title, message: sender == enterAddAmountButton ? "+" : "-")
        let style = URBNAlertStyle()
        style.messageAlignment = .Center
        style.messageFont = UIFont(name: "Avenir-Heavy", size: 40.0)
        style.titleFont = UIFont(name: "Avenir-Medium", size: 20.0)
        enterAmountView.alertStyler = style
        enterAmountView.addAction(URBNAlertAction(title: "Done", actionType: .Normal, actionCompleted: { action in
            if let n = NSNumberFormatter().numberFromString(self.processAllowanceString(self.enterAmountView.textField().text)) {
                if Float(n) > self.currentAmount && sender == self.enterSubAmountButton {
                    let alert = URBNAlertViewController(title: "Exceeding allowance!", message: "That amount is more than your allowance")
                    alert.alertStyler.blurTintColor = UIColor.redColor().colorWithAlphaComponent(0.4)
                    alert.addAction(URBNAlertAction(title: "Ok", actionType: .Normal, actionCompleted: { action in
                        return
                    }))
                    alert.show()
                }
                else {
                    let adjustedAmount = sender == self.enterAddAmountButton ? self.currentAmount + Float(n) : self.currentAmount - Float(n)
                    self.levelLabel.text = self.currentAmountString
                    
                    var frame = self.jarAmountView.frame
                    if sender == self.enterAddAmountButton {
                        if CGFloat(n) > self.allowance || adjustedAmount > Float(self.allowance) {
                            frame.size.height = self.jarImageView.frame.height * 0.8
                        }
                        else {
                            frame.size.height += CGFloat(self.delta * Float(n))
                            frame.origin.y -= CGFloat(self.delta * Float(n))
                        }
                    }
                    else {
                        if self.currentAmount > Float(self.allowance) {
                            let realN = Float(self.allowance) - adjustedAmount
                            self.currentAmount = adjustedAmount
                            frame.size.height -= CGFloat(self.delta * realN)
                            frame.origin.y += CGFloat(self.delta * realN)
                        }
                        else {
                            frame.size.height -= CGFloat(self.delta * Float(n))
                            frame.origin.y += CGFloat(self.delta * Float(n))
                        }
                    }
                    
                    self.currentAmount = adjustedAmount
                    self.currentJarFrameHeight = frame.size.height
                    self.drawJarAmountViewWithHeight(frame.size.height)
                    self.levelLabel.text = self.currentAmountString
                }
            }
        }))
        
        enterAmountView.addTextFieldWithConfigurationHandler { textField in
            textField.tag = sender == self.enterAddAmountButton ? 2 : 3
            textField.textAlignment = .Center
            textField.placeholder = "$0.00"
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.returnKeyType = .Done
        }
        
        enterAmountView.show()
    }
    
    func changeAllowanceButtonPressed () {
        var messageText = ""
        var titleText = ""
        if sharedDefaults.objectForKey(jarKey) == nil {
            titleText = "Welcome!"
            messageText = "Enter your allowance below"
        }
        else {
            titleText = "Allowance \(allowanceString)"
            messageText = "Change your allowance"
        }
        
        changeAllowanceView = URBNAlertViewController(title: titleText, message: messageText)
        let style = URBNAlertStyle()
        style.messageAlignment = .Center
        style.messageFont = UIFont(name: "Avenir-Light", size: 18.0)
        style.titleFont = UIFont(name: "Avenir-Medium", size: 20.0)
        changeAllowanceView.alertStyler = style
        changeAllowanceView.addAction(URBNAlertAction(title: "Done", actionType: .Normal, actionCompleted: { action in
            if let n = NSNumberFormatter().numberFromString(self.processAllowanceString(self.changeAllowanceView.textField().text)) {
                self.allowance = CGFloat(n)

                self.changeAllowanceButton.setTitle("Allowance \(self.allowanceString)", forState: .Normal)
                self.addAllowanceButton.setTitle("Add \(self.allowanceString)", forState: .Normal)
                if self.sharedDefaults.objectForKey(self.jarKey) == nil {
                    self.currentAmount = Float(self.allowance)
                    let formattedAmountString = String(format: "%.2f", self.allowance)
                    self.levelLabel.text = self.currentAmountString
                }
            }
        }))
        
        changeAllowanceView.addTextFieldWithConfigurationHandler { textField in
            textField.textAlignment = .Center
            textField.tag = 1
            textField.placeholder = "\(self.allowanceString)"
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.returnKeyType = .Done
        }
        
        changeAllowanceView.show()
    }
    
    func addAllowanceButtonPressed () {
        currentAmount += Float(allowance)
        levelLabel.text = currentAmountString
        currentJarFrameHeight = jarImageView.frame.height * 0.8
        drawJarAmountViewWithHeight(jarImageView.frame.height * 0.8)
    }
    
    func addButtonPressed () {
        currentAmount += 1.0
        
        var frame = jarAmountView.frame
        frame.size.height += CGFloat(delta)
        frame.origin.y -= CGFloat(delta)
        currentJarFrameHeight = frame.size.height
        UIView.animateWithDuration(0.1, animations: {
            self.jarAmountView.frame = frame
        })
        levelLabel.text = currentAmountString
    }
    
    func subtractButtonPressed () {
        // 306.5
        currentAmount -= 1.0
        var frame = jarAmountView.frame
        frame.size.height -= CGFloat(delta)
        frame.origin.y += CGFloat(delta)
        currentJarFrameHeight = frame.size.height
        UIView.animateWithDuration(0.1, animations: {
            self.jarAmountView.frame = frame
        })
        
        levelLabel.text = currentAmountString
    }
    
    func addButtonHeld () {
    }
    
    func save () {
        jarData[jarSizeKey] = "\(allowance)"
        jarData[savedAmountInJarKey] = "\(currentAmount)"
        jarData[savedJarHeightKey] = "\(currentJarFrameHeight)"
        sharedDefaults.setValue(jarData, forKey: jarKey)
    }
    
    // MARK HELPERS
    func offWhiteImage (name:String) -> UIImage {
        var image: UIImage = UIImage(named: name)!
        var rect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        UIGraphicsBeginImageContext(rect.size)
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextClipToMask(context, rect, image.CGImage)
        CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextFillRect(context, rect)
        var img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func textFieldChanged (notif: NSNotification!) {
        let notifTextField = notif.object as! UITextField
        if notifTextField.tag == 1 {
            changeAllowanceView.textField().text = "$\(processAllowanceString(changeAllowanceView.textField().text))"
        }
        else {
            enterAmountView.textField().text = "$\(processAllowanceString(enterAmountView.textField().text))"
        }
    }
    
    func processAllowanceString (text:String) -> String {
        var newText = text
        newText = text.stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString(".00", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return newText
    }
}

