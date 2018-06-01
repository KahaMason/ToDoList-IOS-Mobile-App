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
    var sectionHeaders = ["YET TO DO", "COMPLETED"]
    var TaskList = MasterList()
    var collaborators = [String]()
    
    var peerToPeer = PeerToPeerManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        peerToPeer.delegate = self
        
        view.backgroundColor = UIColor.black
        
        setupNavigation()
        loadsamples()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        peerToPeer.delegate = self // Return PeerToPeerManagerDelegate Back to MasterViewController when viewing TaskList
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions

    // Setup Navigation - Edit Button | Title | Add Button
    func setupNavigation() {
        navigationItem.title = "Things to Do"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
    }
    
    // Add New Tasks
    @objc func addTask() {
        let creation = currentdate() // Function Referenced in Task.swift
        let taskNumber = TaskList.ToDoList.count + 1
        let taskID = generateID()
        
        let newtask = Task(name: "New Task \(taskNumber)", history:["\(creation) Task Created"], taskIdentifier: taskID)
        
        TaskList.ToDoList.insert(newtask, at: 0) // Inserts task into first position of array
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        peerToPeer.send(data: TaskList.json) // Sends updates when a new task is added
    }
    
    // Enable Task Editing
    @objc func editTask() {
        self.tableView.isEditing = !self.tableView.isEditing
        navigationItem.leftBarButtonItem?.title = (self.tableView.isEditing) ? "Done" : "Edit"
    }
    
    // Loads Samples
    func loadsamples() {
        let creation = currentdate() // Function Referenced in Task.swift
        
        let task1 = Task(name: "New Task 1", history: ["\(creation) Task Created"], taskIdentifier: 1)
        let task2 = Task(name: "New Task 2", history: ["\(creation) Task Created"], taskIdentifier: 2)
        let task3 = Task(name: "New Task 3", history: ["\(creation) Task Created"], taskIdentifier: 3)
        
        TaskList.ToDoList = [task3, task2, task1]
    }
    
    // Creates Unique ID
    func generateID() -> Int {
        var newID = arc4random_uniform(10000) // Generates random number between 0 - 10000 for a Unique Identifier
        
        // Checks ToDoList Tasks for any UniqueID Conflicts
        if TaskList.ToDoList.count != 0 {
            for i in 0...TaskList.ToDoList.count - 1 {
                if TaskList.ToDoList[i].taskIdentifier == newID { newID = UInt32(generateID()) }} // Re-generate new ID
        }
        
        // Checks CompletedList Task for any UniqueID Conflicts
        if TaskList.CompletedList.count != 0 {
            for i in 0...TaskList.CompletedList.count - 1 {
                if TaskList.CompletedList[i].taskIdentifier == newID { newID = UInt32(generateID()) }} // Re-generate new ID
        }
        return Int(newID)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // DetailViewController Segue - Tap Cell Action
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.delegate = self
                switch indexPath.section {
                    
                case 0: controller.taskItem = TaskList.ToDoList[indexPath.row]
                case 1: controller.taskItem = TaskList.CompletedList[indexPath.row]
                default: fatalError("Could not locate Task Details")
                    
                }
                
                controller.peerToPeer = peerToPeer
                controller.collaborators = collaborators
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    
    // Number of Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    // View for the Header Cell
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel()
        
        // Configure Header Label
        header.text = sectionHeaders[section]
        header.textColor = UIColor.lightGray
        header.textAlignment = .center
        
        return header
    }
    
    // Heigh for the Header Cell
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // Number of Rows in Each Section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        
        case 0: return (TaskList.ToDoList.count)
        case 1: return (TaskList.CompletedList.count)
        default: fatalError("Could not find Number of Rows for Section")
        }
    }
    
    // Data for Each Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.section {
        
        case 0:
            let task = TaskList.ToDoList[indexPath.row]
            cell.textLabel?.text = task.name
        
        case 1:
            let task = TaskList.CompletedList[indexPath.row]
            cell.textLabel?.text = task.name
            
        default: fatalError("Could not locate Cell Data")
        }
        
        // Configure Cell
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
        if editingStyle == .delete {
            switch indexPath.section {
            case 0: TaskList.ToDoList.remove(at: indexPath.row)
            case 1: TaskList.CompletedList.remove(at: indexPath.row)
            default: fatalError("Deleted Row Entry not found in TaskList")}
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            peerToPeer.send(data: TaskList.json) // Send update when deleted a task
        }
    }
    
    // Enables Row Movement
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Controlls Row Movement and Updates the Array Containers
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var task: Task?
        let date = currentdate()
        var history: String?
        
        switch sourceIndexPath.section {
        case 0:
            switch destinationIndexPath.section {
                
            case 0: // Yet to Do to Yet to Do
                task = TaskList.ToDoList[sourceIndexPath.row]
                TaskList.ToDoList.remove(at: sourceIndexPath.row)
                TaskList.ToDoList.insert(task!, at: destinationIndexPath.row)
                
                peerToPeer.send(data: TaskList.json) // Send Update When Moving a Task
                
            case 1: // Yet to Do to Completed Tasks
                history = "\(date) Moved to Completed"
                TaskList.ToDoList[sourceIndexPath.row].history.insert(history!, at: 0)
                
                task = TaskList.ToDoList[sourceIndexPath.row]
                TaskList.ToDoList.remove(at: sourceIndexPath.row)
                TaskList.CompletedList.insert(task!, at: destinationIndexPath.row)
                
                peerToPeer.send(data: TaskList.json) // Send Update When Moving a Task
                
            default: fatalError("Task is not Designated")}
            
        case 1:
            switch destinationIndexPath.section {
                
            case 0: // Completed Task to Yet to Do
                history = ("\(date) Moved to Yet To Do")
                TaskList.CompletedList[sourceIndexPath.row].history.insert(history!, at: 0)
                
                task = TaskList.CompletedList[sourceIndexPath.row]
                TaskList.CompletedList.remove(at: sourceIndexPath.row)
                TaskList.ToDoList.insert(task!, at: destinationIndexPath.row)
                
                peerToPeer.send(data: TaskList.json) // Send update when Moving a Task
                
            case 1: // Completed Task to Completed Task
                task = TaskList.CompletedList[sourceIndexPath.row]
                TaskList.CompletedList.remove(at: sourceIndexPath.row)
                TaskList.CompletedList.insert(task!, at: destinationIndexPath.row)
                
                peerToPeer.send(data: TaskList.json) // Send Update When Moving A Task
                
            default: fatalError("Task is not Designated")}
            
        default: fatalError("App did not find destination of cell")}
    }
}

extension MasterViewController: DetailViewControllerDelegate { // MARK: - Recieves Updates from DetailViewController
    func didFinishUpdating(_ detailViewController: DetailViewController, task: Task) {
        var indexPath: IndexPath?
        
        // Update Task if Task found in Yet to Do
        if TaskList.ToDoList.count != 0 {
            print("Checking ToDoList")
            for i in 0...TaskList.ToDoList.count - 1 {
                if TaskList.ToDoList[i].taskIdentifier == task.taskIdentifier {
                    print("Updated Task At ToDoList \(i)")
                    TaskList.ToDoList[i] = task
                    indexPath = IndexPath(row: i, section: 0)
                }
            }
        }
        
        // Update Task if Task found in Completed
        if TaskList.CompletedList.count != 0 {
            print("Checking Completed List")
            for i in 0...TaskList.CompletedList.count - 1 {
                if TaskList.CompletedList[i].taskIdentifier == task.taskIdentifier {
                    print("Updated Task at CompletedList \(i)")
                    TaskList.CompletedList[i] = task
                    indexPath = IndexPath(row: i, section: 1)
                }
            }
        }
        
        DispatchQueue.main.async {
            if indexPath != nil {
                print("Reloading Row at \(indexPath!)")
                self.tableView.reloadRows(at: [indexPath!], with: .none)
            }
        }
    }
    
    func updateTaskList(_ detailViewController: DetailViewController, recievedList: MasterList) {
        print("Recieved Task List Update from Detail View")
        let recievedListCount = recievedList.ToDoList.count + recievedList.CompletedList.count
        let TaskListCount = TaskList.ToDoList.count + TaskList.CompletedList.count
        
        if recievedListCount >= TaskListCount { // Compares Task List sizes and override with the larger listing
            print ("Task List Override: Updating Current List")
            self.TaskList = recievedList
        }
        
        else { print("Current Task List Larger, Maintaining Current Task List") }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updatingCollaborators(_ detailViewController: DetailViewController, collaborators: Array<String>) {
        print("Updated Collaborators List")
        self.collaborators = collaborators // Update Collaborators
    }
}

extension MasterViewController : PeerToPeerManagerDelegate { // MARK: - Peer to Peer Recieving Updates
    
    // Recieved Update to Collaborators from Peer Network
    func collaboratorDevices(manager: PeerToPeerManager, connectedDevices: [String]) {
        print("Updated Collaborators List")
        
        self.collaborators = connectedDevices
    }
    
    // Recieved Data from Peer Network
    func manager(manager: PeerToPeerManager, didRecieve data: Data) {
        print("Recieved Data")
        let recievedArray = try? JSONDecoder().decode(MasterList.self, from: data) // Catches Array Data
        let recievedItem = try? JSONDecoder().decode(Task.self, from: data) // Catches Task Data
        
        // Catches data if the send data is an update to the array configuration
        if recievedArray != nil {
            print("Data Recieved is Array Update")
            let ListCount = TaskList.ToDoList.count + TaskList.CompletedList.count
            let RecievedCount = (recievedArray?.ToDoList.count)! + (recievedArray?.CompletedList.count)!
            if RecievedCount >= ListCount { // Compares Task List Size and Overrides with larger listing
                print("Task List Override: Updating Task List")
                self.TaskList = recievedArray!
            }
            
            else { print("Current Task List Larger, Maintaining Current Task List") }
        }
        
        // Catches data if the send data is an update to a specified task
        if recievedItem != nil {
            print("Data Recieved is Task Update")
            // Updates item if item is located in the Yet to Do section
            if TaskList.ToDoList.count != 0 {
                print("Checking ToDoList")
                for i in 0...TaskList.ToDoList.count - 1 {
                    if TaskList.ToDoList[i].taskIdentifier == recievedItem?.taskIdentifier {
                        print("Recieved Update to Task \(i) in ToDoList")
                        TaskList.ToDoList[i] = recievedItem!
                    }
                }
            }
            
            // Updates item if item is located in the Completed Section
            if TaskList.CompletedList.count != 0 {
                print("Checking Completed List")
                for i in 0...TaskList.CompletedList.count - 1 {
                    if TaskList.CompletedList[i].taskIdentifier == recievedItem?.taskIdentifier {
                        print("Recieved Update to Task \(i) in Completed List")
                        TaskList.CompletedList[i] = recievedItem!
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData() // Reforms TableView to display update changes
        }
    }
}
