//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jesus Andres Bernal Lopez on 12/21/18.
//  Copyright © 2018 Jesus Andres Bernal Lopez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController {
    private let cellID = "Cell"
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddCategory))
        navigationItem.rightBarButtonItem = rightItem
        navigationItem.title = "Todoey"
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        navBar.prefersLargeTitles = true
        navBar.barTintColor = #colorLiteral(red: 0.1137254902, green: 0.6078431373, blue: 0.9647058824, alpha: 1)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : FlatWhite()]
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: cellID)
        
        loadCategories()
    }
    
    
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving context: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    @objc func onAddCategory(){
        let alert = UIAlertController(title: "Add a new category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (category) in
            let category = Category()
            category.name = textField.text!
            category.color = UIColor.randomFlat.hexValue()
            self.save(category: category)
        }
        
        alert.addAction(action)

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        self.present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        

        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name ?? "No Categories added yet"
            if let color = UIColor(hexString: category.color) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TodoListViewController()
        if let indexPath = tableView.indexPathForSelectedRow{
            vc.selectedCategory = categories?[indexPath.row]
        }
        navigationController?.show(vc, sender: self)
    }

}

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            if let categoryForDeletion = self.categories?[indexPath.row]{
                do{
                    try self.realm.write {
                        self.realm.delete(categoryForDeletion)
                    }
                }catch{
                    print("Error deleting category: \(error.localizedDescription)")
                }
            }
        }
        
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
