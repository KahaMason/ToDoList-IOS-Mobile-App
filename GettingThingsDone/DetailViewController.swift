//
//  DetailViewController.swift
//  GettingThingsDone
//
//  Created by KSM on 20/5/18.
//  Copyright © 2018 Kaha Mason (s2762038). All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    func didFinishUpdating(_ detailViewController: DetailViewController, task: Task)
    func updateTaskList(_ detailViewController: DetailViewController, recievedList: MasterList)
    func updatingCollaborators(_ detailViewController: DetailViewController, collaborators: Array<String>)
}

class DetailViewController: UITableViewController {

    var sectionheaders = ["Task", "History", "Collaborators"]
    var taskItem: Task?
    var collaborators = [String]()
    var peerToPeer: PeerToPeerManager?
    
    var delegate: DetailViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerToPeer?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = UIColor.black
        navigationItem.title = "Task"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHistory))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        peerToPeer?.delegate = self // Return PeerToPeerManagerDelegate to Detail View when viewing Task Detail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OBJC Functions
    
    @objc func addHistory() {
        //print("Adding to History") // <- Debug for Add Hisotry Button
        
        // Construct Timestamp and Position in History Array and TableView
        let date = currentdate()
        let newhistory = "\(date) New History"
        let indexPath = IndexPath(row: 0, section: 1)
        
        taskItem?.history.insert(newhistory, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        self.delegate?.didFinishUpdating(self, task: taskItem!) // Send Task Update to Master View Task List
        peerToPeer?.send(data: (taskItem?.json)!) // Send Task Update to Peer Network
    }

    // MARK: - Table View

    // Number of Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionheaders.count
    }
    
    // View for Section Headers
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel()
        
        // Configure Header Label
        header.text = sectionheaders[section]
        header.textColor = UIColor.lightGray
        header.textAlignment = .center
        
        return header
    }
    
    // Height of Section Headers
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    // Number of Rows in each Section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        
        case 0: return 1
        case 1: return (taskItem?.history.count)!
        case 2: return collaborators.count
        default: fatalError("Could not determine Number of Rows per Section")
        }
    }

    // Data for each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailViewCell
        
        switch indexPath.section {
        
        case 0: cell.detailField.text = taskItem?.name
        case 1: cell.detailField.text = taskItem?.history[indexPath.row]
        case 2: cell.detailField.text = collaborators[indexPath.row]
        default: fatalError("Cannot Identify Section Destination of Cell")
        }
        
        cell.detailField.delegate = self
        cell.detailField.textColor = UIColor.lightGray
        cell.detailField.backgroundColor = UIColor.black
        cell.backgroundColor = UIColor.black

        return cell
    }
}

extension DetailViewController: UITextFieldDelegate { // MARK: - TextField Functions
    
    // Enables the return key to finish editing a TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.delegate?.didFinishUpdating(self, task: self.taskItem!) // Send Task Update to Master View Task List
        peerToPeer?.send(data: (taskItem?.json)!) // Send Task Update to Peer Network
        
        return true
    }
    
    // Updates the Task Item's information to the array when finished editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Finds and retrieves the position of the cell thats textfield is being edited
        let cell = textField.superview?.superview as! DetailViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        
        // Guard against returning empty textfield
        if textField.text?.isEmpty == false {
            switch indexPath?.section {
                
            case 0?: taskItem?.name = textField.text!
            case 1?: taskItem?.history[(indexPath?.row)!] = textField.text!
            case 2?: collaborators[(indexPath?.row)!] = textField.text!
            default: fatalError("No TextFields Selected")
                
            }
            
            tableView.reloadRows(at: [indexPath!], with: .none)
        }
    }
}

extension DetailViewController : PeerToPeerManagerDelegate { // MARK: - Peer To Peer Recieving Updates
    
    // Recieved Data from Peer Network
    func manager(manager: PeerToPeerManager, didRecieve data: Data) {
        
        // Catches information if the information sent is Task information of current task
        let recievedList = try? JSONDecoder().decode(MasterList.self, from: data)
        let recievedItem = try? JSONDecoder().decode(Task.self, from: data)
        
        if recievedList != nil {
            print("Recieved Task List Update, Sending to Master View")
            self.delegate?.updateTaskList(self, recievedList: recievedList!) // Send Recieved Task List Update to Master View DetailViewController Delegate
        }
        
        // If there is no information sent about current task, don't update
        if recievedItem != nil {
            print("Recieved a Task from Peer Network, Sending to Master View")
            self.delegate?.didFinishUpdating(self, task: recievedItem!) // Send Recieved Task to Master View DetailViewController Delegate
            
            if recievedItem?.taskIdentifier == taskItem?.taskIdentifier {
                print("Updating This Task")
                taskItem = recievedItem // Update Current Task Details
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData() // Reform tableView to display update
        }
    }
    
    // Recieved Collaborators update from Peer Network
    func collaboratorDevices(manager: PeerToPeerManager, connectedDevices: [String]) {
        print("Recieved a Collaborator Update")
        
        self.collaborators = connectedDevices // Fill Collaboraters array as devices connect
        self.delegate?.updatingCollaborators(self, collaborators: self.collaborators) // Send Update to Collaborators Array in Master View
        
        DispatchQueue.main.async {
            self.tableView.reloadData() // Reform tableView to display updates
        }
    }
}
