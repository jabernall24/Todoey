//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jesus Andres Bernal Lopez on 12/21/18.
//  Copyright © 2018 Jesus Andres Bernal Lopez. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    private let cellID = "CategoryCell"
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: cellID)
        let rightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddItem))
        navigationItem.rightBarButtonItem = rightItem
        navigationItem.title = "Todoey"
        
        loadCategories()
    }
    
    func saveCategories(){
        do{
            try context.save()
        }catch{
            print("Error saving context: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do{
            categories = try context.fetch(request)
        }catch{
            print("Error fetch data from context: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    @objc func onAddItem(){
        let alert = UIAlertController(title: "Add a new category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (category) in
            let category = Category(context: self.context)
            category.name = textField.text!
            self.categories.append(category)
            self.saveCategories()
        }
        
        alert.addAction(action)

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        self.present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CategoryCell
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TodoListViewController()
        if let indexPath = tableView.indexPathForSelectedRow{
            vc.selectedCategory = categories[indexPath.row]
        }
        navigationController?.show(vc, sender: self)
    }

}
