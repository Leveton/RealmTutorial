//
//  AddNewEntryController.swift
//  RWRealmStarterProject
//
//  Created by Bill Kastanakis on 8/6/14.
//  Copyright (c) 2014 Bill Kastanakis. All rights reserved.
//

import UIKit
import Realm

class AddNewEntryController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    var selectedAnnotation: SpecimenAnnotation!
    var selectedCategory: Category!
    var specimen: Specimen!
    
    //MARK: - Validation
    
    func validateFields() -> Bool {
        
        if (nameTextField.text.isEmpty || descriptionTextField.text.isEmpty || selectedCategory == nil) {
            
            let alertController = UIAlertController(title: "Validation Error", message: "All fields must be filled", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: {(alert : UIAlertAction!) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(alertAction)
            presentViewController(alertController, animated: true, completion: nil)
            
            return false
            
        } else {
            return true
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        performSegueWithIdentifier("Categories", sender: self)
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (specimen == nil) {
            title = "Add New Specimen"
        } else {
            title = "Edit \(specimen.name)"
            fillTextFields()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func unwindFromCategories(segue: UIStoryboardSegue) {
        let categoriesController = segue.sourceViewController as! CategoriesTableViewController
        selectedCategory = categoriesController.selectedCategory
        categoryTextField.text = selectedCategory.name
        
    }
    
    func addNewSpecimen() {
        let realm = RLMRealm.defaultRealm() //1
        
        realm.beginWriteTransaction() //2
        let newSpecimen = Specimen() //3
        //4
        newSpecimen.name = nameTextField.text
        newSpecimen.category = selectedCategory
        newSpecimen.specimenDescription =  descriptionTextField.text
        newSpecimen.latitude = selectedAnnotation.coordinate.latitude
        newSpecimen.longitude = selectedAnnotation.coordinate.longitude
        
        realm.addObject(newSpecimen) //9
        realm.commitWriteTransaction() //10
        
        specimen = newSpecimen
    }
    
    //MARK: - Actions
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if validateFields() {
            
            if specimen == nil {
                addNewSpecimen()
            }
            
            updateSpecimen()
            return true
        } else {
            
            
            return false
        }
    }
    
    func fillTextFields() {
        nameTextField.text = specimen.name
        categoryTextField.text = specimen.category.name
        descriptionTextField.text = specimen.specimenDescription
        
        selectedCategory = specimen.category
    }
    
    func updateSpecimen() {
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        
        specimen.name = nameTextField.text
        specimen.category = selectedCategory
        specimen.specimenDescription = descriptionTextField.text
        
        realm.commitWriteTransaction()
    }
}
