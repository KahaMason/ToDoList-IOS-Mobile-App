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
    var indexPath: IndexPath?
    
    var newID: Int?
    
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
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        if indexPath != nil { // Reloads Row after returning from editing in DetailView
            super.tableView.reloadRows(at: [self.indexPath!], with: .none)
        }
        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OBJC Functions
    
    @objc func addTask() {
        //print("Adding Task") //<- Debug For Add Button Tap
        let creation = currentdate() // Function Referenced in Task.swift
        let taskNumber = (TaskList.ToDoList.count) + 1
        let taskid = newID! + 1
        let newtask = Task(name: "New Task \(taskNumber)", history:["\(creation) Task Created"], taskIdentifier: taskid)
        
        TaskList.ToDoList.insert(newtask, at: 0) // Inserts task into first position of array
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        self.newID = taskid
        
        peerToPeer.send(data: TaskList.json)
    }
    
    @objc func editTask() {
        //print("Editing Task") //<- Debug For Test Button Tap
        
        self.tableView.isEditing = !self.tableView.isEditing
        navigationItem.leftBarButtonItem?.title = (self.tableView.isEditing) ? "Done" : "Edit"
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // DetailViewController Segue - Tap Cell Action
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                switch indexPath.section {
                    
                case 0: controller.taskItem = TaskList.ToDoList[indexPath.row]
                case 1: controller.taskItem = TaskList.CompletedList[indexPath.row]
                default: fatalError("Could not locate Task Details")
                    
                }
                
                controller.peerToPeer = peerToPeer
                controller.collaborators = collaborators
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                self.indexPath = indexPath  // Used to reference the indexPath of the target cell for reload on viewWillAppear
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
        case 1: return 0
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
            default: fatalError("Deleted Row Entry not found in TaskList")
            
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            peerToPeer.send(data: TaskList.json)
        }
    }
    
    // Enables Row Movement
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Controlls Row Movement and Updates the Array Containers
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //print("Moving Cell from: \(sourceIndexPath) to: \(destinationIndexPath)")
        
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
                
                peerToPeer.send(data: TaskList.json)
                
            case 1: // Yet to Do to Completed Tasks
                history = "\(date) Moved to Completed"
                TaskList.ToDoList[sourceIndexPath.row].history.insert(history!, at: 0)
                
                task = TaskList.ToDoList[sourceIndexPath.row]
                TaskList.ToDoList.remove(at: sourceIndexPath.row)
                TaskList.CompletedList.insert(task!, at: destinationIndexPath.row)
                
                self.indexPath = destinationIndexPath
                peerToPeer.send(data: TaskList.json)
                
            default: fatalError("Task is not Designated")
            
            }
        
        case 1:
            switch destinationIndexPath.section {
                
            case 0: // Completed Task to Yet to Do
                history = ("\(date) Moved to Yet To Do")
                TaskList.CompletedList[sourceIndexPath.row].history.insert(history!, at: 0)
                
                task = TaskList.CompletedList[sourceIndexPath.row]
                TaskList.CompletedList.remove(at: sourceIndexPath.row)
                TaskList.ToDoList.insert(task!, at: destinationIndexPath.row)
                
                self.indexPath = destinationIndexPath
                peerToPeer.send(data: TaskList.json)
                
            case 1: // Completed Task to Completed Task
                task = TaskList.CompletedList[sourceIndexPath.row]
                TaskList.CompletedList.remove(at: sourceIndexPath.row)
                TaskList.CompletedList.insert(task!, at: destinationIndexPath.row)
                
                peerToPeer.send(data: TaskList.json)
                
            default: fatalError("Task is not Designated")
                
            }
        
        default: fatalError("App did not find destination of cell")
        }
        
        // Debug - Shows the ordering of array entries after cell is moved
        //dump(taskstodo)
        //dump(completedtasks)
    }
    
    // MARK: - Setup Functions
    
    // Setup Navigation - Edit Button | Title | Add Button
    func setupNavigation() {
        navigationItem.title = "Things to Do"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTask))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
    }
    
    // Loads Samples
    func loadsamples() {
        let creation = currentdate() // Function Referenced in Task.swift
        
        let task1 = Task(name: "New Task 1", history: ["\(creation) Task Created"], taskIdentifier: 1)
        let task2 = Task(name: "New Task 2", history: ["\(creation) Task Created"], taskIdentifier: 2)
        let task3 = Task(name: "New Task 3", history: ["\(creation) Task Created"], taskIdentifier: 3)
        
        TaskList.ToDoList = [task3, task2, task1]
        
        self.newID = 3
    }
}

// Handles Peer-To-Peer Recieving Data
extension MasterViewController : PeerToPeerManagerDelegate {
    func collaboratorDevices(manager: PeerToPeerManager, connectedDevices: [String]) {
        print("Recieved New Collaborator on Master View")
        
        self.collaborators = connectedDevices
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func manager(manager: PeerToPeerManager, didRecieve data: Data) {
        
        let recievedArray = try? JSONDecoder().decode(MasterList.self, from: data) // Catches Array Data
        let recievedItem = try? JSONDecoder().decode(Task.self, from: data) // Catches Task Data
        
        // Catches data if the send data is an update to the array configuration
        if recievedArray != nil {
            self.TaskList = recievedArray!
        }
        
        // Catches data if the send data is an update to a specified task
        if recievedItem != nil {
            if self.indexPath?.section == 0 {
                TaskList.ToDoList[(indexPath?.row)!] = recievedItem!
            }
            
            else if self.indexPath?.section == 1 {
                TaskList.CompletedList[(indexPath?.row)!] = recievedItem!
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
