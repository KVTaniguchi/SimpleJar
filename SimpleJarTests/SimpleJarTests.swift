//
//  SimpleJarTests.swift
//  SimpleJarTests
//
//  Created by Kevin Taniguchi on 8/22/15.
//  Copyright (c) 2015 KVTaniguchi. All rights reserved.
//

import UIKit
import XCTest

class SimpleJarTests: XCTestCase {
    
    func testJarViewController() {
        let jvc = JarViewController()
        if let jarData = NSUserDefaults.standardUserDefaults().objectForKey(jvc.jarKey) {
            XCTAssertNotNil(jarData, "If the app is installed, should get jar Data")
        }
    }
    
    func testTransactionHistoryViewController() {
        let thvc = TransactionHistoryViewController()
        XCTAssertNotNil(thvc.fetchResults)
    }
}
