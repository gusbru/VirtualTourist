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

class LocationsMapViewController: UIViewController {
    
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
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Error fetching Pin: \(error.localizedDescription)")
        }
        
    }
    
    func saveNewPin(latitude: Double, longitude: Double) {
        
        PhotoAlbumClient.getPhotos(latitude: latitude, longitude: longitude) { (data, error) in
            if let data = data {
                let pin = Pin(context: self.dataController.viewContext)
                pin.latitude = latitude
                pin.longitude = longitude
                pin.pinId = UUID()
                pin.numberOfPages = Int64(data.photos.pages)
                
                
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    // TODO: Show error
                    print("error saving pin")
                    print(error.localizedDescription)
                }
            }
        }
        
        
    }
    
    // ----------------------------------------------------------------------------
    // MARK:- Navigation
    
    

}


// ----------------------------------------------------------------------------
// MARK: - MapView
extension LocationsMapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
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
        let photoAlbumViewControl = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        
        photoAlbumViewControl.pinAnnotation = view.annotation
        photoAlbumViewControl.dataController = dataController
        
        
        let currentPin = view.annotation as! PinLocation
        
        
        for pin in fetchResultsController.fetchedObjects! {
            if (pin.pinId == currentPin.pinId) {
                photoAlbumViewControl.pin = pin
                navigationController?.pushViewController(photoAlbumViewControl, animated: true)
                return
            }
        }
        
        // TODO: error... pin not found on data store
        print("pin not found!!!!!!")
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
        // clean the map annotations (if any)
        mapView.addAnnotations(mapView.annotations)
        
        // load annotations saved on disk
        if let pinList = fetchResultsController.fetchedObjects {
            for pin in pinList {
                addNewAnnotation(pin: pin)
            }
        }
        
    }
    
    func addNewAnnotation(pin: Pin) {

        let latitude = CLLocationDegrees(exactly: pin.latitude)!
        let longitude = CLLocationDegrees(exactly: pin.longitude)!
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let annotation = PinLocation()
        annotation.coordinate = coordinate
        annotation.pinId = pin.pinId
    
        mapView.addAnnotation(annotation)
        
    }
    
    // MARK: - Gestures
        
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            // save to data persistence
            saveNewPin(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
        }
        
        
    }
}

// MARK: - Extension
extension LocationsMapViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("prepare for change")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let pin = anObject as? Pin {
                addNewAnnotation(pin: pin)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("a change was made")
    }
}
