//
//  Task.swift
//  GettingThingsDone
//
//  Created by KSM on 20/5/18.
//  Copyright © 2018 Kaha Mason (s2762038). All rights reserved.
//

import Foundation

class Task {
    var name: String
    var history = [String]()
    
    init(name: String, history: Array<String>) {
        self.name = name
        self.history = history
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
