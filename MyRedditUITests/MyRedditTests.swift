//
//  MyRedditTests.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/7/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import XCTest

class MyRedditTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
       
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLoginLogout() {
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["List"].tap()
        toolbarsQuery.buttons["Male"].tap()
        toolbarsQuery.buttons["add account"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["enter username..."].typeText("budakikickflip")
        tablesQuery.secureTextFields["enter password..."].tap()
        tablesQuery.secureTextFields["enter password..."].typeText("773108blue")
        app.navigationBars["add account"].buttons["sign in"].tap()
        
        XCTAssertTrue(tablesQuery.cells.count > 0)

        app.tables.staticTexts["budakikickflip"].tap()
        toolbarsQuery.buttons["logout"].tap()
        
        XCTAssertTrue(app.tables.staticTexts["budakikickflip"].exists)
        
    }
    
    func testAddTwoAccounts() {
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["List"].tap()
        toolbarsQuery.buttons["Male"].tap()
        toolbarsQuery.buttons["add account"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["enter username..."].typeText("budakikickflip")
        tablesQuery.secureTextFields["enter password..."].tap()
        tablesQuery.secureTextFields["enter password..."].typeText("773108blue")
        app.navigationBars["add account"].buttons["sign in"].tap()

        toolbarsQuery.buttons["add account"].tap()
        
        tablesQuery.textFields["enter username..."].typeText("myredditapp")
        tablesQuery.secureTextFields["enter password..."].tap()
        tablesQuery.secureTextFields["enter password..."].typeText("773108blue")
        app.navigationBars["add account"].buttons["sign in"].tap()
        
        XCTAssertTrue(tablesQuery.cells.count > 1)
    }
    
    func testDeleteAccount() {
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["List"].tap()
        toolbarsQuery.buttons["Male"].tap()
        toolbarsQuery.buttons["add account"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["enter username..."].typeText("budakikickflip")
        tablesQuery.secureTextFields["enter password..."].tap()
        tablesQuery.secureTextFields["enter password..."].typeText("773108blue")
        app.navigationBars["add account"].buttons["sign in"].tap()
        
        tablesQuery.cells.staticTexts["budakikickflip"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        XCTAssertFalse(app.tables.staticTexts["budakikickflip"].exists)
        
    }

}
