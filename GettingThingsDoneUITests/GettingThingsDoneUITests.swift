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
    
    // Tests Loading of Master and Detail Views
    func testTableViewLoads() {
        
        let app = XCUIApplication()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["New Task 3"]/*[[".cells.staticTexts[\"New Task 3\"]",".staticTexts[\"New Task 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Task"].buttons["Things to Do"].tap()
    }
    
    // Tests the Add Button for New Tasks
    func testAddButton() {
        
        let app = XCUIApplication()
        
        let addButton = XCUIApplication().navigationBars["Things to Do"].buttons["Add"]
        addButton.tap()
        addButton.tap()
        addButton.tap()
        
        XCTAssertEqual(app.tables.cells.count, 6)
    }
    
    // Tests the delete button for editing function
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
    
    // Tests the add history button function in Detail View for 2 different cells
    func testaddHistory() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let newTask3StaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["New Task 3"]/*[[".cells.staticTexts[\"New Task 3\"]",".staticTexts[\"New Task 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newTask3StaticText.tap()
        
        let taskNavigationBar = app.navigationBars["Task"]
        let addButton = taskNavigationBar.buttons["Add"]
        addButton.tap()
        addButton.tap()
        
        let thingsToDoButton = taskNavigationBar.buttons["Things to Do"]
        thingsToDoButton.tap()
        
        let newTask2StaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["New Task 2"]/*[[".cells.staticTexts[\"New Task 2\"]",".staticTexts[\"New Task 2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newTask2StaticText.tap()
        addButton.tap()
        thingsToDoButton.tap()
        newTask3StaticText.tap()
        thingsToDoButton.tap()
        newTask2StaticText.tap()
        thingsToDoButton.tap()
    }
    
    // Tests Adding history function when cells are moved between sections
    func testMoveCellHistory() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let newTask3StaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["New Task 3"]/*[[".cells.staticTexts[\"New Task 3\"]",".staticTexts[\"New Task 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newTask3StaticText.tap()
        app.navigationBars["Task"].buttons["Things to Do"].tap()
        
        let editButton = app.navigationBars["Things to Do"].buttons["Edit"]
        editButton.tap()
        
        let topButton = app.buttons["Reorder New Task 3"]
        let completedTable = app/*@START_MENU_TOKEN@*/.tables.containing(.staticText, identifier:"COMPLETED").element/*[[".tables.containing(.staticText, identifier:\"COMPLETED\").element",".tables.containing(.staticText, identifier:\"YET TO DO\").element"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        
        topButton.press(forDuration: 0.5, thenDragTo: completedTable)
        
        editButton.tap()
        app.tables.staticTexts["New Task 3"].tap()
    }
}
