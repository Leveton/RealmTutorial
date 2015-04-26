//
//  CategoriesTableViewController.swift
//  RWRealmStarterProject
//
//  Created by Bill Kastanakis on 8/6/14.
//  Copyright (c) 2014 Bill Kastanakis. All rights reserved.
//

import UIKit
import Realm

class CategoriesTableViewController: UITableViewController {
    
    var categories = Category.allObjects()
    var selectedCategory: Category!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        populateDefaultCategories()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(categories.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! UITableViewCell
        
        let category = categories.objectAtIndex(UInt(indexPath.row)) as! Category
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath {
        
        selectedCategory = categories[UInt(indexPath.row)] as! Category
        return indexPath
    }
    
    func populateDefaultCategories() {
        categories = Category.allObjects() //1
        
        if categories.count == 0 { //2
            let realm = RLMRealm.defaultRealm() //3
            realm.beginWriteTransaction() //4
            
            //5
            let defaultCategories = ["Birds", "Mammals", "Flora", "Reptiles", "Arachnids" ]
            for category in defaultCategories {
                //6
                let newCategory = Category()
                newCategory.name = category
                realm.addObject(newCategory)
            }
            
            realm.commitWriteTransaction() // 7
            categories = Category.allObjects() //8
        }
    }
    
}
