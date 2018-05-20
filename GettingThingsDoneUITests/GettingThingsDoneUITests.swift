//
//  GettingThingsDoneUITests.swift
//  GettingThingsDoneUITests
//
//  Created by KSM on 20/5/18.
//  Copyright © 2018 Kaha Mason (s2762038). All rights reserved.
//

import XCTest

class GettingThingsDoneUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        XCUIApplication().launch()
        
        continueAfterFailure = false
    }

    func testTaskTableUILoad() {
        let app = XCUIApplication()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["New Task 3"]/*[[".cells.staticTexts[\"New Task 3\"]",".staticTexts[\"New Task 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Master"].buttons["Things to Do"].tap()
    }

    func testAddButton() {
        let app = XCUIApplication()
        
        let addButton = XCUIApplication().navigationBars["Things to Do"].buttons["Add"]
        addButton.tap()
        addButton.tap()
        addButton.tap()
        
        XCTAssertEqual(app.tables.cells.count, 6)
        
    }
}
