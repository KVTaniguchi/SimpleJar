//
//  SimpleJarUITests.swift
//  SimpleJarUITests
//
//  Created by Kevin Taniguchi on 9/4/15.
//  Copyright © 2015 KVTaniguchi. All rights reserved.
//

import XCTest

@available(iOS 9.0, *)
class SimpleJarUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddButtonSingle () {        
        let button = XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).elementBoundByIndex(3)
        button.tap()
    }
}
