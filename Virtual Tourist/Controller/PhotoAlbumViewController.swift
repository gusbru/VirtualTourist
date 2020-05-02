//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-04-29.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    private let reuseIdentifier = "Cell"
    var pinAnnotation: MKAnnotation?
    var dataController: NSPersistentContainer!
    var fetchResultsController: NSFetchedResultsController<Photo>?
    var pin: Pin?
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDelegate()
        setupToolBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultsController = nil
    }
    
    fileprivate func fetchPhotosFromWeb() {
        guard let latitude = pinAnnotation?.coordinate.latitude else { return }
        guard let longitude = pinAnnotation?.coordinate.longitude else { return }
        
        PhotoAlbumClient.getPhotos(latitude: latitude, longitude: longitude) { (response, error) in
            if let response = response {
                print(response)
            }
            
            if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func setupDelegate() {
        // Do any additional setup after loading the view.
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        mapView.delegate = self
    }
    
    fileprivate func setupToolBar() {
        let button = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        setToolbarItems([flexibleSpace, button, flexibleSpace], animated: true)
    }
    
    // -------------------------------------------
    // MARK: - Fetch
    private func setupFetchResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        guard let pin = pin else { return }
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController?.delegate = self
        
        do {
            try fetchResultsController?.performFetch()
        } catch {
            fatalError("Error fetching photos: \(error.localizedDescription)")
        }
        
    }
    

}

// MARK: - Collection View
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
//        cell.photoImageView.image = #imageLiteral(resourceName: "VirtualTourist_120")
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}


// MARK:- MapView
extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("map")
    }
}
