//
//  DetailViewController.swift
//  GettingThingsDone
//
//  Created by KSM on 20/5/18.
//  Copyright © 2018 Kaha Mason (s2762038). All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, UITextFieldDelegate {

    var sectionheaders = ["Task", "History", "Collaborators"]
    var taskItem: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = UIColor.black
        navigationItem.title = "Task"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHistory))
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
        
        //dump(taskItem?.history) // <- Debug for Task History Array
    }
    
    // MARK: - TextField Functions
    
    // Enables the return key to finish editing a TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Updates the Task Item's information to the array when finished editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("Finished Editing TextField") // Debug: For Finished Editing
        
        // Finds and retrieves the position of the cell thats textfield is being edited
        let cell = textField.superview?.superview as! DetailViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        
        // Guard against returning empty textfield
        if textField.text?.isEmpty == false {
            switch indexPath?.section {
            
            case 0?: taskItem?.name = textField.text!
            case 1?: taskItem?.history[(indexPath?.row)!] = textField.text!
            default: fatalError("No TextFields Selected")
            
            }
            
            tableView.reloadRows(at: [indexPath!], with: .none)
        }
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
        case 2: return 0
        default: fatalError("Could not determine Number of Rows per Section")
        }
    }

    // Data for each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailViewCell
        
        switch indexPath.section {
        
        case 0: cell.detailField.text = taskItem?.name
        case 1: cell.detailField.text = taskItem?.history[indexPath.row]
        case 2: cell.detailField.text = nil
        default: fatalError("Cannot Identify Section Destination of Cell")
        }
        
        cell.detailField.delegate = self
        cell.detailField.textColor = UIColor.lightGray
        cell.detailField.backgroundColor = UIColor.black
        cell.backgroundColor = UIColor.black

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
