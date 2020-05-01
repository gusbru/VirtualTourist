//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-04-29.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var dataController: NSPersistentContainer!
    var fetchResultsController: NSFetchedResultsController<Pin>!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // delegate
        mapView.delegate = self
        
        // tap map
        let singleTapRecognize = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(singleTapRecognize)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchResultsController()
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.toolbar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchResultsController = nil
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.toolbar.isHidden = false
    }
    
    
    
    // ----------------------------------------------------------------------------
    // MARK: - Fetch Results Controller
    
    fileprivate func setupFetchResultsController() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")

        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Error fetching Pin: \(error.localizedDescription)")
        }
        
    }
    
    func saveNewPin(latitude: Double, longitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        
        do {
            try dataController.viewContext.save()
        } catch {
            // TODO: Show error
            print(error.localizedDescription)
        }
    }

}

extension LocationsMapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    // MARK: - MapView
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumViewControll = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        navigationController?.pushViewController(photoAlbumViewControll, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("finish load map: \(fetchResultsController.fetchedObjects?.count ?? -1)")
        if let pinList = fetchResultsController.fetchedObjects {
            for pin in pinList {
                if let coordinate = generateCoordinate(latitude: pin.latitude, longitude: pin.longitude) {
                    addNewAnnotation(coordinate: coordinate)
                }
            }
        }
        
    }
    
    func addNewAnnotation(coordinate: CLLocationCoordinate2D) {

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
    
        mapView.addAnnotation(annotation)
        
    }
    
    func generateCoordinate(latitude: Double, longitude: Double) -> CLLocationCoordinate2D? {
        guard let latitude = CLLocationDegrees(exactly: latitude) else { return nil }
        guard let longitude = CLLocationDegrees(exactly: longitude) else { return nil }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Gestures
        
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            // Add annotation:
            addNewAnnotation(coordinate: coordinate)
            
            // save to data persistence
            saveNewPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            print("loooong tap")
            print(coordinate.latitude)
            print(coordinate.longitude)
            print(mapView.annotations.count)
            print("-----------")
        }
        
        
    }
}
