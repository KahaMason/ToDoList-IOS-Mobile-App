//
//  Task.swift
//  GettingThingsDone
//
//  Created by KSM on 20/5/18.
//  Copyright © 2018 Kaha Mason (s2762038). All rights reserved.
//

import Foundation

class MasterList: Codable {
    var ToDoList = [Task]()
    var CompletedList = [Task]()
}

class Task: Codable {
    var name: String
    var history = [String]()
    var taskIdentifier: Int
    
    init(name: String, history: Array<String>, taskIdentifier: Int) {
        self.name = name
        self.history = history
        self.taskIdentifier = taskIdentifier
    }
}

// Global Function: Retrieves the Current Date for Task History Entry
func currentdate() -> String {
    let currentdate = Date()
    let formatter = DateFormatter()
    
    // Configure Date Formatter
    formatter.dateFormat = "MM/dd/yy hh:mm a"
    let date = formatter.string(from: currentdate)
    
    return date
}

extension MasterList {
    var json: Data {
        get { return try! JSONEncoder().encode(self) }
    }
}

extension Task {
    var json: Data {
        get { return try! JSONEncoder().encode(self) }
    }
}
