//
//  LogViewController.swift
//  RWRealmStarterProject
//
//  Created by Bill Kastanakis on 8/7/14.
//  Copyright (c) 2014 Bill Kastanakis. All rights reserved.
//

import UIKit
import Realm
import MapKit

class LogViewController: UITableViewController, UISearchResultsUpdating, UITextFieldDelegate {
    
    var specimens = Specimen.allObjects()
    var searchResults = Specimen.allObjects()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchField:UITextField!
    // You can use objectsWhere but let's introduce predicates! :]
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        let searchResultsController = searchController.searchResultsController as! UITableViewController
        searchResultsController.tableView.reloadData()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        specimens = Specimen.allObjects().sortedResultsUsingProperty("name", ascending: true)
        
        definesPresentationContext = true;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchField.isFirstResponder()) {
            return Int(searchResults.count)
        } else {
            return Int(specimens.count)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("LogCell") as! LogCell
        var specimen: Specimen!
        
        if (searchField.isFirstResponder()) {
            specimen = searchResults[UInt(indexPath.row)] as! Specimen
        } else {
            specimen = specimens[UInt(indexPath.row)] as! Specimen
        }
       
        cell.titleLabel.text = specimen.name
        cell.subtitleLabel.text = specimen.category.name
        
        switch specimen.category.name {
        case "Uncategorized":
            cell.iconImageView.image = UIImage(named: "IconUncategorized")
        case "Reptiles":
            cell.iconImageView.image = UIImage(named: "IconReptile")
        case "Flora":
            cell.iconImageView.image = UIImage(named: "IconFlora")
        case "Birds":
            cell.iconImageView.image = UIImage(named: "IconBird")
        case "Arachnid":
            cell.iconImageView.image = UIImage(named: "IconArachnid")
        case "Mammals":
            cell.iconImageView.image = UIImage(named: "IconMammal")
        default:
            cell.iconImageView.image = UIImage(named: "IconUncategorized")
        }
        
        if specimen.distance < 0 {
            cell.distanceLabel.text = "N/A"
        } else {
            cell.distanceLabel.text = String(format: "%.2fkm", specimen.distance / 1000)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            deleteRowAtIndexPath(indexPath)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Edit") {
            let controller = segue.destinationViewController as! AddNewEntryController
            var selectedSpecimen : Specimen!
            let indexPath = tableView.indexPathForSelectedRow()
            
            if searchField.isFirstResponder() {
//                let searchResultsController = searchController.searchResultsController as UITableViewController
                let indexPathSearch = tableView.indexPathForSelectedRow()
                selectedSpecimen = searchResults[UInt(indexPathSearch!.row)] as! Specimen
            } else {
                selectedSpecimen = specimens[UInt(indexPath!.row)] as! Specimen
            }
            
            controller.specimen = selectedSpecimen
        }
    }
    
    //MARK: - Actions
    
    @IBAction func scopeChanged(sender: AnyObject) {
        
        let scopeBar = sender as! UISegmentedControl
        
        switch scopeBar.selectedSegmentIndex {
        case 0:
            specimens = Specimen.allObjects().sortedResultsUsingProperty("name", ascending: true)
        case 1:
            specimens = Specimen.allObjects().sortedResultsUsingProperty("distance", ascending: true)
        case 2:
            specimens = Specimen.allObjects().sortedResultsUsingProperty("created", ascending: true)
        default:
            specimens = Specimen.allObjects().sortedResultsUsingProperty("name", ascending: true)
        }
        tableView.reloadData()
    }
    
    
    func deleteRowAtIndexPath(indexPath: NSIndexPath) {
        
        let realm = RLMRealm.defaultRealm() //1
        let objectToDelete = specimens[UInt(indexPath.row)] as! Specimen //2
        realm.beginWriteTransaction() //3
        realm.deleteObject(objectToDelete) //4
        realm.commitWriteTransaction() //5
        
        specimens = Specimen.allObjects().sortedResultsUsingProperty("name", ascending: true)
        
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade) //7
    }
    
    func filterResultsWithSearchString(searchString: String) {
        
        
        let predicate = NSPredicate(format: "name BEGINSWITH [c]%@", searchString) // 1
        searchResults = Specimen.objectsWithPredicate(predicate)
        tableView.reloadData()
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.text.isEmpty){
            searchField.resignFirstResponder()
            tableView.reloadData()
            return false
        }
        filterResultsWithSearchString(textField.text)
        return true
    }
}
