//
//  Specimen.swift
//  RWRealmStarterProject
//
//  Created by Mike Leveton on 4/25/15.
//  Copyright (c) 2015 Bill Kastanakis. All rights reserved.
//

import UIKit
import Realm

class Specimen: RLMObject {
    dynamic var name = ""
    dynamic var specimenDescription = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var created = NSDate()
    dynamic var distance: Double = 0
    dynamic var category = Category() //sets up a one-to-many relationship between the Specimen and the Category models.  Category can have many specimens.
    
    func ignoredProperties() -> NSArray {
        let propertiesToIgnore = [distance]
        return propertiesToIgnore
    }
}
