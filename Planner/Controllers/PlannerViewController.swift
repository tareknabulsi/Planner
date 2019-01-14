//
//  ViewController.swift
//  Planner
//
//  Created by Tarek Nabulsi on 1/4/19.
//  Copyright © 2019 Tarek Nabulsi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class PlannerViewController: SwipeTableViewController {
    
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
        searchBar.delegate = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name //Nav Bar title gets category name
        guard let color = selectedCategory?.color else { fatalError() } //Save color of category
        updateNavBar(withHexCode: color)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
//MARK: – Nav Bar Setup Methods
    
    //Takes color and sets it as the Nav Bar color
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else
        {fatalError("Navigation controller does not exist.")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
            navBar.barTintColor    = navBarColor
            navBar.tintColor       = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            searchBar.barTintColor = navBarColor
    }
    
    
    
//MARK: - Tableview Datasoruce Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = items?[indexPath.row].title ?? "No Items Added Yet"
        if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        //If done, set to checkmark, else set to none
        cell.accessoryType = items?[indexPath.row].done == true ?  .checkmark : .none
        
        return cell
    }
    
    
    
    
//MARK: - Tableview Delegate Methods
    
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
    
    
    
    
//MARK: - Add New Items
    
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
                        newItem.color = UIColor.randomFlat.hexValue()
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
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    
    
    
//MARK: – Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let itemsForDeletion = items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemsForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadItems() //Refill the items array so we can sort through them again.
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        super.searchBarSearchButtonClicked(searchBar)
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //If text field is empty, load all the items.
            loadItems()
//            DispatchQueue.main.async { //Code gets run in the foreground
//                searchBar.resignFirstResponder()
//            }
        } else { //Otherwise reload the table view.
            super.searchBar(searchBar, textDidChange: searchText)
        }
    }
}
