//
//  ViewController.swift
//  Planner
//
//  Created by Tarek Nabulsi on 1/4/19.
//  Copyright © 2019 Tarek Nabulsi. All rights reserved.
//

import UIKit
import RealmSwift

class PlannerViewController: UITableViewController {
    
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet{ //If the var is set, call this function
            loadItems()
        }
    }
    
    private var action: UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //searchBar.delegate = self
    }

    //MARK - Tableview Datasoruce Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = items?[indexPath.row].title ?? "No Items Added Yet"
        
        //If done, set to checkmark, else set to none
        cell.accessoryType = items?[indexPath.row].done == true ?  .checkmark : .none
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancelled")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            //Uses textFieldDidChange function to see if action should be enabled
            alertTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            textField = alertTextField
        }
        
        action.isEnabled = false //Default is false since text field starts empty
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //Used to check if the user text field is empty
    @objc private func textFieldDidChange(_ field: UITextField) {
        action.isEnabled = field.text?.count ?? 0 > 0
    }

    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK - Search bar methods
extension PlannerViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    //Show all of the items if the search text is empty
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async { //Code gets run in the foreground
                searchBar.resignFirstResponder()
            }
        }
    }
}
