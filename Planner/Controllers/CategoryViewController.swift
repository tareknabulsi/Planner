//
//  CategoryViewController.swift
//  Planner
//
//  Created by Tarek Nabulsi on 1/10/19.
//  Copyright © 2019 Tarek Nabulsi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categories: Results<Category>?
    private var action: UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadCategories() //Initially load all categories.
        tableView.separatorStyle = .none //Eliminate the lines in the table view cells.
        searchBar.barTintColor = UIColor(hexString: "1D9BF6") //Standard nav Bar color.
    }
    
    
    
    
//MARK: – TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    //Customize the cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] { //Try taking a category from categories array.
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet" //Get name property.
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}    //Get color property.
            cell.backgroundColor = categoryColor //Set background color to the object's saved color
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true) //Create contrast between text and background color
        }
        return cell
    }
    
    
    
    
//MARK: – TableView Delegate Methods
    //Go to Items page when cell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PlannerViewController //Destination is PlannerViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            //Set the destination controller's property to the category in the selected cell.
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    
    
//MARK: – Add new Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //Create alert to display to user.
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        //Add action creates new category and saves it using Realm.
        action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            self.saveCategories(category: newCategory)
            }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in //Simple cancel method.
            print("Cancelled")
        }
        //Create text field for alert.
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new category"
            //Uses textFieldDidChange function to see if action should be enabled
            alertTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            textField = alertTextField
        }
        
        action.isEnabled = false //Default is disabled because there is no text there. Text must be added for "Add" to work.
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //Used to check if the user text field is empty.
    @objc private func textFieldDidChange(_ field: UITextField) {
        action.isEnabled = field.text?.count ?? 0 > 0
    }
    
    //Save to Realm database.
    func saveCategories(category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    //Read from Realm database.
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    
    
//MARK: – Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        //Erase from Realm database.
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //Filter the categories and reload the table view.
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadCategories() //Refill the categories array so we can sort through them again.
        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        super.searchBarSearchButtonClicked(searchBar)
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //If text field is empty, load all the categories.
            loadCategories()
//            DispatchQueue.main.async { //Code gets run in the foreground
//                searchBar.resignFirstResponder()
//            }
        } else {
            super.searchBar(searchBar, textDidChange: searchText)
        }
    }
}
