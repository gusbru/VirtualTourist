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

class PhotoAlbumViewController: UIViewController {
    
    private let reuseIdentifier = "Cell"
    var pinAnnotation: MKAnnotation?
    var dataController: NSPersistentContainer!
    var fetchResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin?
    
    // tmp
    var photosList: [FlickrPhoto?] = []
    
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
        
        if let photos = fetchResultsController.fetchedObjects {
            if photos.count == 0 {
                print("fetch from web!")
                fetchPhotosFromWeb()
            }
        }
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
//                print(response.photos.photo)
                
                self.photosList.append(contentsOf: response.photos.photo)
                print("my photos = \(self.photosList)")
                self.photosCollectionView.reloadData()
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

// MARK: - Collection View Delegate
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return fetchResultsController.sections?.count ?? 1
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
//        return fetchResultsController.sections?[section].numberOfObjects ?? 0
        print("number of photos = \(photosList.count)")
        return photosList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let farmId = photosList[indexPath.row]!.farm
        let serverId = photosList[indexPath.row]!.server
        let id = photosList[indexPath.row]!.id
        let secret = photosList[indexPath.row]!.secret
    
        // Configure the cell
//        cell.photoImageView.image = #imageLiteral(resourceName: "VirtualTourist_120")
        PhotoAlbumClient.downloadImage(farmId: farmId, serverId: serverId, id: id, secret: secret) { (data, error) in
            guard let data = data else { return }
            cell.photoImageView.image = UIImage(data: data)
            
            cell.setNeedsLayout()
        }
    
        return cell
    }
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("delete item at \(indexPath)")
        return true
    }
}


// MARK:- MapView
extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("map")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("map did finish load")
        if let pinAnnotation = pinAnnotation{
            mapView.addAnnotation(pinAnnotation)
            let coordinateRegion = MKCoordinateRegion(center: pinAnnotation.coordinate, latitudinalMeters: CLLocationDistance(exactly: 2000)!, longitudinalMeters: CLLocationDistance(exactly: 2000)!)
            mapView.setRegion(coordinateRegion, animated: false)
        }
    }
    
    
}


// MARK:- Fetch Result Controller
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            break
        case .update:
            break
        case .delete:
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
