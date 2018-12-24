//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jesus Andres Bernal Lopez on 12/21/18.
//  Copyright © 2018 Jesus Andres Bernal Lopez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private let cellID = "TodoCell"
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    lazy var tableView: UITableView = {
        var t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        t.separatorStyle = .none
        t.rowHeight = 80
        t.register(SwipeTableViewCell.self, forCellReuseIdentifier: cellID)
        return t
    }()
    
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.delegate = self
        if let color = selectedCategory?.color{
            s.barTintColor = UIColor(hexString: color)
        }
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightbutton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddItem))
        navigationItem.rightBarButtonItem = rightbutton
        navigationItem.title = "Todoey"
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let color = selectedCategory?.color else {fatalError()}
        title = selectedCategory!.name
        updateNavBar(withHexCode: color)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    func updateNavBar(withHexCode color: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        guard let navBarColor = UIColor(hexString: color) else{fatalError()}
        navBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    @objc func onAddItem(){
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let item = Item()
                        item.title = textField.text!
                        currentCategory.items.append(item)
                    }
                }catch{
                    print("Error saving new item: \(error.localizedDescription)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let colorHex = selectedCategory?.color
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: colorHex!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }else{
            cell.textLabel?.text = "No Items"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = todoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status: \(error.localizedDescription)")
            }
        }
        
        tableView.reloadData()
    }

    fileprivate func setUpView(){
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
}

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}

extension TodoListViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            print("Delete cell")
            
            if let itemForDeletion = self.todoItems?[indexPath.row]{
                do{
                    try self.realm.write {
                        self.realm.delete(itemForDeletion)
                    }
                }catch{
                    print("Error deleting item: \(error.localizedDescription)")
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
