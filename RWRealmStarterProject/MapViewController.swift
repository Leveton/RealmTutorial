//
//  MapViewController.swift
//  RWRealmStarterProject
//
//  Created by Bill Kastanakis on 8/5/14.
//  Copyright (c) 2014 Bill Kastanakis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Realm

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let kDistanceMeters:CLLocationDistance = 500
    
    var locationManager = CLLocationManager()
    var userLocated:Bool = false
    var lastAnnotation: MKAnnotation!
    var specimens = Specimen.allObjects()
    
    //MARK: - Realm
    
    //MARK: - Helper Methods
    
    func centerToUsersLocation() {
        let center = mapView.userLocation.coordinate
        var zoomRegion : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(center, kDistanceMeters, kDistanceMeters)
        mapView.setRegion(zoomRegion, animated: true);
    }
    
    func addNewPin() {
        if lastAnnotation == nil {
            
            let specimen = SpecimenAnnotation(coordinate: mapView.centerCoordinate, title: "Empty", subtitle: "Uncategorized");
            
            mapView.addAnnotation(specimen)
            lastAnnotation = specimen
        } else {
            let alertController = UIAlertController(title: "Annotation already dropped", message: "There is an annoatation on screen. Try dragging it if you want to change its location!", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: {(alert : UIAlertAction!) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(alertAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - CLLocationManager Delegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status != .NotDetermined) {
            mapView.showsUserLocation = true
        } else {
            println("Authorization to use location data denied")
        }
    }
    
    //MARK: - MKMapview Delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is SpecimenAnnotation) {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotation.subtitle)
            
            if annotationView == nil {
                
                let currentAnnoatation = annotation as! SpecimenAnnotation
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.subtitle)
                
                switch currentAnnoatation.subtitle {
                case "Uncategorized":
                    annotationView.image = UIImage(named: "IconUncategorized")
                case "Arachnids":
                    annotationView.image = UIImage(named: "IconArachnid")
                case "Birds":
                    annotationView.image = UIImage(named: "IconBird")
                case "Mammals":
                    annotationView.image = UIImage(named: "IconMammal")
                case "Flora":
                    annotationView.image = UIImage(named: "IconFlora")
                case "Reptiles":
                    annotationView.image = UIImage(named: "IconReptile")
                default:
                    annotationView.image = UIImage(named: "IconUncategorized")
                }
                
                annotationView.enabled = true
                annotationView.canShowCallout = true
                var detailDisclosure = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
                annotationView.rightCalloutAccessoryView = detailDisclosure
                
                if currentAnnoatation.title == "Empty" {
                    annotationView.draggable = true
                }
                
            }
            return annotationView
        }
        
        return nil
        
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        
        for annotationView in views as! [MKAnnotationView] {
            if (annotationView.annotation is SpecimenAnnotation) {
                annotationView.transform = CGAffineTransformMakeTranslation(0, -500)
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {
                    annotationView.transform = CGAffineTransformMakeTranslation(0, 0)
                    }, completion: nil)
            }
        }
        
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (annotationView.annotation is SpecimenAnnotation) {
            performSegueWithIdentifier("NewEntry", sender: annotationView.annotation)
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            view.dragState = .None
        }
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Realm database path: \(RLMRealm.defaultRealm().path)")
        
        title = "Map"
        
        locationManager.delegate = self
        
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
            println("Requesting Authorization")
        } else {
            locationManager.startUpdatingLocation()
        }
        populateMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions & Segues
    
    @IBAction func centerToUserLocationTapped(sender: AnyObject) {
        centerToUsersLocation()
    }
    
    
    @IBAction func addNewEntryTapped(sender: AnyObject) {
        addNewPin()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "NewEntry") {
            let controller = segue.destinationViewController as! AddNewEntryController
            let specimenAnnotation = sender as! SpecimenAnnotation
            controller.selectedAnnotation = specimenAnnotation
        }
        else if (segue.identifier == "Log") {
            updateLocationDistance()
        }
    }
    
    @IBAction func unwindFromAddNewEntry(segue: UIStoryboardSegue) {
        
        let addNewEntryController = segue.sourceViewController as! AddNewEntryController
        let addedSpecimen = addNewEntryController.specimen as Specimen
        let addedSpecimenCoordinate = CLLocationCoordinate2D(latitude: addedSpecimen.latitude, longitude: addedSpecimen.longitude)
        
        if (lastAnnotation != nil) {
            mapView.removeAnnotation(lastAnnotation)
        } else {
            for annotation in mapView.annotations {
                let currentAnnotation = annotation as! SpecimenAnnotation
                if currentAnnotation.coordinate.latitude == addedSpecimenCoordinate.latitude && currentAnnotation.coordinate.longitude == addedSpecimenCoordinate.longitude {
                    mapView.removeAnnotation(currentAnnotation)
                    break
                }
            }
        }
        
        let annotation = SpecimenAnnotation(coordinate: addedSpecimenCoordinate, title: addedSpecimen.name, subtitle: addedSpecimen.category.name, specimen: addedSpecimen)
        
        mapView.addAnnotation(annotation)
        lastAnnotation = nil;
        
    }
    
    func populateMap() {
        
        mapView.removeAnnotations(mapView.annotations) // 1
        
        specimens = Specimen.allObjects()  // 2
        // Create annotations for each one
        for specimen in specimens {
            
            let aSpecimen = specimen as! Specimen
            
            let coord = CLLocationCoordinate2D(latitude: aSpecimen.latitude, longitude: aSpecimen.longitude);
            
            let specimenAnnotation = SpecimenAnnotation(coordinate: coord,
                title: aSpecimen.name,
                subtitle: aSpecimen.category.name,
                specimen: aSpecimen) // 3
            
            mapView.addAnnotation(specimenAnnotation) // 4
        }
    }
    
    func updateLocationDistance() {
        let realm = RLMRealm.defaultRealm()
        
        for specimen in specimens {
            let currentSpecimen = specimen as! Specimen
            let currentLocation = CLLocation(latitude: currentSpecimen.latitude, longitude: currentSpecimen.longitude)
            let distance = currentLocation.distanceFromLocation(mapView.userLocation.location)
            realm.beginWriteTransaction()
            currentSpecimen.distance = Double(distance)
            realm.commitWriteTransaction()
        }
    }
}
