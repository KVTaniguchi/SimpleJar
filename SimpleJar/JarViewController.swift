//
//  JarViewController.swift
//  SimpleJar
//
//  Created by Kevin Taniguchi on 8/22/15.
//  Copyright (c) 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import iAd
import URBNAlert
import QuartzCore
import CoreData

class JarViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let instructionLabel = UILabel()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var sharedDefaults = NSUserDefaults.standardUserDefaults()
    var jarData = [String:String]()
    let jarSizeKey = "jarSizeKey", savedAmountInJarKey = "jarSavedAmountKey", jarKey = "com.taniguchi.JarKey"
    var addButton = UIButton(), subtractButton = UIButton(), changeAllowanceButton = UIButton(), addAllowanceButton = UIButton(), enterAddAmountButton = UIButton(), enterSubAmountButton = UIButton(), transactionHistoryButton = UIButton()
    var jarImageView = UIImageView(image: UIImage(named: "milkSolidClearHold"))
    var jarAmountView = UIView(), levelView = UIView()
    var currentJarFrameHeight : CGFloat = 0.0, amountInJar : CGFloat = 0.0, allowance : CGFloat = 0.00,  startingY : CGFloat = 0.0
    var jarHeightConstraint : NSLayoutConstraint?
    var levelLabel = UILabel(), flashLabel = UILabel(), changeLabel = UILabel()
    var changeAllowanceView : URBNAlertViewController!, enterAmountView : URBNAlertViewController!
    let emitterLayer = CAEmitterLayer()
    var timerIsUp = true
    var timer : NSTimer!
    var currentAmount : Float = 0.0, oldValue : Float = 0.0
    var currentAmountString : String {
        let formattedAmountString = String(format: "%.2f", currentAmount)
        return "You have $\(formattedAmountString) left"
    }
    var jarViewDrawn = false
    var allowanceString : String { return String(format: "$%.2f", allowance) }
    var delta : Float {
        let initialHeight = Float(jarImageView.frame.height * 0.8)
        if currentAmount > Float(allowance) {
            return 0.0
        }
        return initialHeight/Float(allowance)
    }
    var moc : NSManagedObjectContext { return appDelegate.managedObjectContext }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
        updateData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
         updateJarView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        save()
    }
    
    func updateData () {
        if sharedDefaults.objectForKey(jarKey) != nil {
            jarData = sharedDefaults.objectForKey(jarKey) as! [String:String]
            let defaultSize = jarData[jarSizeKey]
            let savedAmount = jarData[savedAmountInJarKey]
            if let n = NSNumberFormatter().numberFromString(savedAmount!) {
                currentAmount = Float(n)
            }
            if let k = NSNumberFormatter().numberFromString(defaultSize!) {
                allowance = CGFloat(k)
            }
        }
        else {
            currentAmount = Float(allowance)
            changeAllowanceButtonPressed()
        }
    }
    
    func updateJarView () {
        if !jarData.isEmpty {
            levelLabel.text = currentAmountString
            addAllowanceButton.setTitle("Add \(allowanceString)", forState: .Normal)
            changeAllowanceButton.setTitle("Allowance \(allowanceString)", forState: .Normal)
            
            if currentAmount < Float(allowance) {
                let ratio = CGFloat(currentAmount)/allowance
                currentJarFrameHeight = ratio * jarImageView.frame.height * 0.8
            }
            else if currentJarFrameHeight == 0 || currentAmount >= Float(allowance) {
                currentJarFrameHeight = jarImageView.frame.height * 0.8
            }

            drawJarAmountViewWithHeight(currentJarFrameHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "save", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "save", name: UIApplicationWillResignActiveNotification, object: nil)
        view.backgroundColor = UIColor.whiteColor()
        
        levelLabel.font = UIFont(name: "Avenir", size: 25.0)
        levelLabel.textAlignment = .Center
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = currentAmountString
        view.addSubview(levelLabel)
        
        for imageView in [jarImageView] {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
        }

        jarAmountView.backgroundColor = UIColor(red: 22/255.0, green: 210/255.0, blue: 75/255.0, alpha: 1.0)
        jarAmountView.alpha = 0.8
        jarAmountView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(jarAmountView)
        view.sendSubviewToBack(jarAmountView)
        
        instructionLabel.font = UIFont(name: "Avenir", size: 14)
        instructionLabel.text = "Swipe up or down to change amounts."
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.textAlignment = .Center
        instructionLabel.numberOfLines = 0
        instructionLabel.lineBreakMode = .ByWordWrapping
        instructionLabel.textColor = UIColor.darkGrayColor()
        view.addSubview(instructionLabel)
        
        for label in [flashLabel, changeLabel] {
            label.textAlignment = .Center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.clearColor()
            label.alpha = 0.0
            label.font = UIFont(name: "AvenirNext-Bold", size: 80)
            view.addSubview(label)
        }
        
        changeAllowanceButton.setTitle("Allowance \(allowanceString)", forState: .Normal)
        changeAllowanceButton.backgroundColor = UIColor.darkGrayColor()
        changeAllowanceButton.addTarget(self, action: "changeAllowanceButtonPressed", forControlEvents: .TouchUpInside)
        addAllowanceButton.setTitle("Add \(allowanceString)", forState: .Normal)
        addAllowanceButton.backgroundColor = UIColor.darkGrayColor()
        addAllowanceButton.addTarget(self, action: "addAllowanceButtonPressed", forControlEvents: .TouchUpInside)
        
        transactionHistoryButton.setImage(UIImage(named: "history-128"), forState: .Normal)
        transactionHistoryButton.addTarget(self, action: "transactionHistoryButtonPressed", forControlEvents: .TouchUpInside)
        transactionHistoryButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        transactionHistoryButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        transactionHistoryButton.layer.borderWidth = 0.5
        transactionHistoryButton.layer.cornerRadius = transactionHistoryButton.frame.height/2
        
        for button in [addButton, subtractButton, changeAllowanceButton, addAllowanceButton, transactionHistoryButton] {
            button.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
            button.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(button)
        }
        
        enterAddAmountButton.setImage(offWhiteImage("plus-100"), forState: .Normal)
        enterSubAmountButton.setImage(offWhiteImage("minus-100"), forState: .Normal)
        
        for button in [enterSubAmountButton, enterAddAmountButton] {
            button.backgroundColor = UIColor.grayColor()
            button.addTarget(self, action: "enterAmountButtonPressed:", forControlEvents: .TouchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 5
        }
        
        view.addSubview(enterAddAmountButton)
        view.addSubview(enterSubAmountButton)

        let views = ["addBtn":addButton, "subBtn":subtractButton, "jarAmount":jarAmountView, "jarImg":jarImageView, "changeAllowance":changeAllowanceButton, "addAllowance":addAllowanceButton, "levelLbl":levelLabel, "enterAddBtn":enterAddAmountButton, "enterSubBtn":enterSubAmountButton, "flashLbl":flashLabel, "transBtn":transactionHistoryButton, "changeLbl":changeLabel, "enterAdd":enterAddAmountButton, "enterSub":enterSubAmountButton, "instructionLabel":instructionLabel]
        let metrics = ["statusBarH":UIApplication.sharedApplication().statusBarFrame.height + 5]
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[enterAdd][enterSub(enterAdd)]|", options: [.AlignAllBottom, .AlignAllTop], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[addBtn]-1-[subBtn(addBtn)]|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[changeAllowance]-1-[addAllowance(changeAllowance)]|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jarImg]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[levelLbl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[flashLbl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[changeLbl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-statusBarH-[changeAllowance(44)]-12-[levelLbl(20)]-12-[jarImg]-[enterSub(100)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[jarAmount]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[transBtn(44)]-30-[enterSub]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[transBtn(44)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[instructionLabel(60)]", options: [], metrics: metrics, views: views))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[instructionLabel]-30-[enterAdd]", options: [], metrics: metrics, views: views))
        jarHeightConstraint = NSLayoutConstraint(item: jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: jarImageView, attribute: .Height, multiplier: 0.8, constant: 0)
        NSLayoutConstraint.activateConstraints([jarHeightConstraint!])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: jarAmountView, attribute: .Bottom, relatedBy: .Equal, toItem: jarImageView, attribute: .Bottom, multiplier: 1.0, constant: -17)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: levelLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: changeLabel, attribute: .Top, relatedBy: .Equal, toItem: jarImageView, attribute: .Top, multiplier: 1.0, constant: 110)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: flashLabel, attribute: .Top, relatedBy: .Equal, toItem: changeLabel, attribute: .Bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: transactionHistoryButton, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: -20)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint(item: transactionHistoryButton, attribute: .Bottom, relatedBy: .Equal, toItem: subtractButton, attribute: .Top, multiplier: 1.0, constant: -30)])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        view.addGestureRecognizer(panGesture)
    }
    
    func handleGesture (gesture : UIPanGestureRecognizer) {
        guard currentAmount > -1 else { return }
        
        if gesture.state == .Began {
            startingY = gesture.translationInView(view).y as CGFloat
            
            for label in [flashLabel, changeLabel] {
                label.alpha = 1.0
            }

            flashLabel.text = String(format: "$%.2f", currentAmount)
            flashLabel.textColor = UIColor.darkGrayColor()
            
            if timerIsUp {
                oldValue = currentAmount
            }
            
            invalidateTimer()
        }
        let yPos = gesture.translationInView(view).y as CGFloat
        let changeInY = floor((startingY - yPos)/10)
        let adjustedAmount = currentAmount + Float(changeInY)
        flashLabel.text = String(format: "$%.2f", adjustedAmount)
        changeLabel.text = String(format: "$%.2f", (adjustedAmount - currentAmount))
        changeLabel.textColor = (adjustedAmount - currentAmount) > 0 ? UIColor.greenColor() : UIColor.redColor()
        
        invalidateTimer()
        
        if gesture.state == .Ended {
            for label in [flashLabel, changeLabel] {
                label.alpha = 0.0
            }
            
            if currentAmount + Float(changeInY) < 1 {
                currentAmount = 0
            }
            else {
                currentAmount = currentAmount + Float(changeInY)
            }
            startTimer()
            
            let ratio = CGFloat(currentAmount)/allowance
            currentJarFrameHeight = ratio * jarImageView.frame.height * 0.8
            drawJarAmountViewWithHeight(currentJarFrameHeight)
        }
    }
    
    func drawJarAmountViewWithHeight (height : CGFloat) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSLayoutConstraint.deactivateConstraints([self.jarHeightConstraint!])
            self.jarHeightConstraint = NSLayoutConstraint(item: self.jarAmountView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
            NSLayoutConstraint.activateConstraints([self.jarHeightConstraint!])
        }
    }
    
    // MARK ANIMATIONSs
    func animateWithDirection (up : Bool) {
        emitterLayer.emitterPosition = CGPointMake(view.center.x, CGRectGetMinY(jarAmountView.frame))
        emitterLayer.zPosition = 10
        emitterLayer.emitterSize = CGSizeMake(10, 0)
        emitterLayer.emitterShape = kCAEmitterLayerSphere
        
        let emitterCell = CAEmitterCell()
        emitterCell.scale = 0.1
        emitterCell.scaleRange = 0.2
        emitterCell.emissionRange = CGFloat(2*M_PI_2)
        emitterCell.lifetime = 5.0
        emitterCell.birthRate = 10
        emitterCell.velocity = 200
        emitterCell.velocityRange = 50
        emitterCell.yAcceleration = 250
        emitterCell.contents = UIImage(named: "greenDollarSign")?.CGImage
        emitterLayer.emitterCells = [emitterCell]
        
        // TODO remove this animation and just make it fade in
        
        flashLabel.text = String(format: "$%.2f", currentAmount)
        changeLabel.text = String(format: "$%.2f", currentAmount - oldValue)
        UIView.animateWithDuration(0.1, animations: {
            if !up {
                self.jarImageView.layer.addSublayer(self.emitterLayer)
            }
            self.flashLabel.alpha = 1.0
            self.flashLabel.textColor = UIColor.darkGrayColor()
            self.changeLabel.alpha = 1.0
            self.changeLabel.textColor = (self.currentAmount - self.oldValue) > 0 ? UIColor.greenColor() : UIColor.redColor()
        }) { complete in
            if complete {
                UIView.animateWithDuration(2.5, animations: {
                    if !up {
                        self.emitterLayer.removeFromSuperlayer()
                    }
                    
                    for label in [self.flashLabel, self.changeLabel] {
                        label.alpha = 0.0
                    }
                })
            }
        }
    }
    
    // MARK ACTIONS
    func enterAmountButtonPressed (sender : UIButton) {
        enterAmountView = URBNAlertViewController(title: sender == enterAddAmountButton ? "Add Amount" : "SubtractAmount", message: sender == enterAddAmountButton ? "+" : "-")
        let style = URBNAlertStyle()
        style.messageAlignment = .Center
        style.messageFont = UIFont(name: "Avenir-Heavy", size: 40.0)
        style.titleFont = UIFont(name: "Avenir-Medium", size: 20.0)
        enterAmountView.alertStyler = style
        enterAmountView.addAction(URBNAlertAction(title: "Done", actionType: .Normal, actionCompleted: { action in
            
            if let n = NSNumberFormatter().numberFromString(self.processAllowanceString(self.enterAmountView.textField().text!)) {
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
                    
                    self.saveTransaction(adjustedAmount)
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
                    self.invalidateTimer()
                    self.startTimer()
                    self.animateWithDirection(sender == self.enterAddAmountButton)
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
            if let n = NSNumberFormatter().numberFromString(self.processAllowanceString(self.changeAllowanceView.textField().text!)) {
                self.allowance = CGFloat(n)
                self.changeAllowanceButton.setTitle("Allowance \(self.allowanceString)", forState: .Normal)
                self.addAllowanceButton.setTitle("Add \(self.allowanceString)", forState: .Normal)
                if self.sharedDefaults.objectForKey(self.jarKey) == nil {
                    self.currentAmount = Float(self.allowance)
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
    
    func transactionHistoryButtonPressed () {
        let historyVC = TransactionHistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    func save () {
        jarData[jarSizeKey] = "\(allowance)"
        jarData[savedAmountInJarKey] = "\(currentAmount)"
        sharedDefaults.setObject(jarData, forKey: jarKey)
    }
    
    // MARK HELPERS
    func invalidateTimer () {
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
        timerIsUp = false
    }
    
    func startTimer () {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateLevelLabelAndCreateTransaction", userInfo: nil, repeats: false)
        }
    }
    
    func updateLevelLabelAndCreateTransaction () {
        levelLabel.text = currentAmountString
        timerIsUp = true
        saveTransaction(currentAmount - oldValue)
    }
    
    func saveTransaction (amount : Float) {
        let entity = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: moc)
        let transaction = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        transaction.setValue(amount, forKey: "amount")
        transaction.setValue(NSDate(), forKey: "date")
        do {
            try moc.save()
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    func offWhiteImage (name:String) -> UIImage {
        let image: UIImage = UIImage(named: name)!
        let rect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextClipToMask(context, rect, image.CGImage)
        CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextFillRect(context, rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func textFieldChanged (notif: NSNotification!) {
        let notifTextField = notif.object as! UITextField
        if notifTextField.tag == 1 {
            changeAllowanceView.textField().text = "$\(processAllowanceString(changeAllowanceView.textField().text!))"
        }
        else {
            enterAmountView.textField().text = "$\(processAllowanceString(enterAmountView.textField().text!))"
        }
    }
    
    func processAllowanceString (text:String) -> String {
        var newText = text
        newText = text.stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        newText = newText.stringByReplacingOccurrencesOfString(".00", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return newText
    }
}
