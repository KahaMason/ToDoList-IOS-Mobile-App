//
//  MasterViewController.swift
//  GettingThingsDone
//
//  Created by KSM on 20/5/18.
//  Copyright © 2018 Kaha Mason (s2762038). All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var taskstodo = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        setupNavigation()
        loadsamples()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OBJC Functions
    
    // Add Button Function
    @objc func addTask() {
        print("Adding Task")
    }
    
    @objc func editTask() {
        print("Editing Task")
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    // MARK: - Table View
    
    // Number of Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of Rows in Each Section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskstodo.count
    }
    
    // Data for Each Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskstodo[indexPath.row]
        
        // Configure Cell
        cell.textLabel?.text = task.name
        cell.textLabel?.textColor = UIColor.lightGray
        cell.backgroundColor = UIColor.black
        
        return cell
    }
    
    // Enables Editing Mode
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Editing Functions
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Setup Functions
    
    // Setup Navigation - Edit Button | Title | Add Button
    func setupNavigation() {
        navigationItem.title = "Things to Do"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
    }
    
    // Loads Samples
    func loadsamples() {
        let task1 = Task(name: "New Task 1")
        let task2 = Task(name: "New Task 2")
        let task3 = Task(name: "New Task 3")
        
        taskstodo = [task3, task2, task1]
    }
}

