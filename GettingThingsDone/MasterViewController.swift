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
    var taskstodo = [Task]()
    var completedtasks = [Task]()
    
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
        let tasknumber = (taskstodo.count + completedtasks.count) + 1
        let newtask = Task(name: "New Task \(tasknumber)", history:["\(creation) Task Created"], taskIdentifier: taskstodo.count)
        
        taskstodo.insert(newtask, at: 0) // Inserts task into first position of array
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
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
                    
                case 0: controller.taskItem = taskstodo[indexPath.row]
                case 1: controller.taskItem = completedtasks[indexPath.row]
                default: fatalError("Could not locate Task Details")
                    
                }
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
        
        case 0: return taskstodo.count
        case 1: return completedtasks.count
        default: fatalError("Could not find Number of Rows for Section")
        }
    }
    
    // Data for Each Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.section {
        
        case 0:
            let task = taskstodo[indexPath.row]
            cell.textLabel?.text = task.name
        
        case 1:
            let task = completedtasks[indexPath.row]
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
            taskstodo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
                task = taskstodo[sourceIndexPath.row]
                taskstodo.remove(at: sourceIndexPath.row)
                taskstodo.insert(task!, at: destinationIndexPath.row)
                
            case 1: // Yet to Do to Completed Tasks
                history = "\(date) Moved to Completed"
                taskstodo[sourceIndexPath.row].history.insert(history!, at: 0)
                
                task = taskstodo[sourceIndexPath.row]
                taskstodo.remove(at: sourceIndexPath.row)
                completedtasks.insert(task!, at: destinationIndexPath.row)
                
            default: fatalError("Task is not Designated")
            
            }
        
        case 1:
            switch destinationIndexPath.section {
                
            case 0: // Completed Task to Yet to Do
                history = ("\(date) Moved to Yet To Do")
                completedtasks[sourceIndexPath.row].history.insert(history!, at: 0)
                
                task = completedtasks[sourceIndexPath.row]
                completedtasks.remove(at: sourceIndexPath.row)
                taskstodo.insert(task!, at: destinationIndexPath.row)
                
            case 1: // Completed Task to Completed Task
                task = completedtasks[sourceIndexPath.row]
                completedtasks.remove(at: sourceIndexPath.row)
                completedtasks.insert(task!, at: destinationIndexPath.row)
                
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
        
        taskstodo = [task3, task2, task1]
    }
}

// Handles Peer-To-Peer Recieving Data
extension MasterViewController: PeerToPeerManagerDelegate {
    func manager(manager: PeerToPeerManager, didRecieve data: Data) {
        
        let task = try! JSONDecoder().decode(Task.self, from: data)
        
        dump(task)
        
        // Checks to see if the update matches Task in tasktodo array
        if taskstodo.count != 0 { // Not Empty
            for i in 0...(taskstodo.count - 1) {
                print("taskstodo[\(i)] ID: \(taskstodo[i].taskIdentifier)")
                if task.taskIdentifier == taskstodo[i].taskIdentifier {
                    taskstodo[i] = task
                    print("Task Found at taskstodo[\(i)]")
                }
            }
        }
        
        // Checks to see if the update matches Task in completedtasks array
        if completedtasks.count != 0 { // Not Empty
            for i in 0...(completedtasks.count - 1) {
                if task.taskIdentifier == completedtasks[i].taskIdentifier {
                    completedtasks[i] = task
                    print("Task found at completedtasks[\(i)]")
                }
                print("Checked at completedtasks[\(i)]")
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
