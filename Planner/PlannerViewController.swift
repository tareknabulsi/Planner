//
//  ViewController.swift
//  Planner
//
//  Created by Tarek Nabulsi on 1/4/19.
//  Copyright © 2019 Tarek Nabulsi. All rights reserved.
//

import UIKit

class PlannerViewController: UITableViewController {

    let itemArray = ["Task 1", "Task 2", "Task 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK - Tableview Datasoruce Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let accessoryType = tableView.cellForRow(at: indexPath)?.accessoryType
        
        //If checkmarked, set to checkmark, else set to none
        tableView.cellForRow(at: indexPath)?.accessoryType = accessoryType == .checkmark ? .none : .checkmark
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

