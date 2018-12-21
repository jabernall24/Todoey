//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jesus Andres Bernal Lopez on 12/21/18.
//  Copyright © 2018 Jesus Andres Bernal Lopez. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    private let cellID = "TodoCell"
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TodoCell.self, forCellReuseIdentifier: cellID)
        
        loadItems()

        let rightbutton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddItem))
        navigationItem.rightBarButtonItem = rightbutton
        navigationItem.title = "Todoey"
    }
    
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("Error decoding itemArray, \(error.localizedDescription)")
            }
        }
    }
    
    @objc func onAddItem(){
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            let item = Item()
            item.title = textField.text!
            self.itemArray.append(item)
            self.saveItems()
            
            self.tableView.reloadData()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TodoCell
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()

        do{
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        }catch{
            print("Error encoding itemArray, \(error.localizedDescription)")
        }
        tableView.reloadData()
    }

}
