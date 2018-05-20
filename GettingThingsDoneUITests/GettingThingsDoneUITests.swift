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

    func testTableViewLoads() {
        
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
    
    func testEditButtonDelete() {
        
        let app = XCUIApplication()
        let editButton = app.navigationBars["Things to Do"].buttons["Edit"]
        editButton.tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Delete New Task 3"]/*[[".cells.buttons[\"Delete New Task 3\"]",".buttons[\"Delete New Task 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.buttons["Delete"].tap()
        editButton.tap()
        
        XCTAssertEqual(app.tables.cells.count, 2)
    }
}
