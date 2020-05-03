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
//    var numberOfPages: Int?
    
    
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
            } else {
                print("using data store")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultsController = nil
    }
    
    fileprivate func fetchPhotosFromWeb() {
        
        
        getImages()
    }
    
    fileprivate func downloadImage(url: URL) {
        PhotoAlbumClient.downloadImage(url: url) { (imgData, error) in
            if let imgData = imgData {
                let newPhoto = Photo(context: self.dataController.viewContext)
                newPhoto.url = url
                newPhoto.imageSrc = imgData
                newPhoto.pin = self.pin
                
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    print("error saving image")
                }
            }
        }
    }
    
    fileprivate func getImages(page: Int = 1) {
        guard let latitude = pinAnnotation?.coordinate.latitude else { return }
        guard let longitude = pinAnnotation?.coordinate.longitude else { return }
        
        
        PhotoAlbumClient.getPhotos(latitude: latitude, longitude: longitude, page: page) { (response, error) in
            if let response = response {
                
                let photosArray = response.photos.photo
//                self.numberOfPages = response.photos.pages
                
                print("get page \(page) of \(response.photos.pages) number of photos = \(response.photos.perpage)")
                
                for p in photosArray {
                    guard let p = p else { return }
                    let farmId = p.farm
                    let id = p.id
                    let serverId = p.server
                    let secret = p.secret
                    let url = PhotoAlbumClient.Endpoints.downloadImage(farmId: farmId, serverId: serverId, id: id, secret: secret).url
                    
                    self.downloadImage(url: url)
                }
                
            }
            
            if let error = error {
                print(error)
            }
        }
    }
    
    func clearFetchedImages() {
        for _ in 1..<(fetchResultsController.sections?[0].numberOfObjects)! {
            
            dataController.viewContext.delete(fetchResultsController.object(at: IndexPath(row: 0, section: 0)))

        }
    }
    
    fileprivate func setupDelegate() {
        // Do any additional setup after loading the view.
        photosCollectionView.delegate = self
        mapView.delegate = self
        
        photosCollectionView.dataSource = self
    }
    
    fileprivate func setupToolBar() {
        let button = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        button.action = #selector(testFetchData)
        
        setToolbarItems([flexibleSpace, button, flexibleSpace], animated: true)
    }
    
    @objc func testFetchData() {
        
        guard let numberOfPages = pin?.numberOfPages else { return }
        
        
        print("numberOfPages = \(numberOfPages)")
        
        if numberOfPages == 0 {
            print("no photos")
            return
        }
        
        let newPage = Int.random(in: 1...Int(numberOfPages))
        
        print("click \(newPage)")
        
        clearFetchedImages()
        
        getImages(page: newPage)
        
        
        
//        let p = Photo(context: dataController.viewContext)
//        p.url = URL(string: "http://www.example.com")
//        p.pin = pin
//
//        do {
//
//            try dataController.viewContext.save()
//        } catch {
//            print("error saving \(error.localizedDescription)")
//        }
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
        return fetchResultsController.sections?.count ?? 1
//        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        if let data = fetchResultsController.object(at: indexPath).imageSrc {
            cell.photoImageView.image = UIImage(data: data)
//            cell.setNeedsLayout()
        }
    
        return cell
    }
    
    
    
    
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("delete item at \(indexPath)")
        let photoToDelete = fetchResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        do {
            try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContent")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert")
            photosCollectionView.insertItems(at: [newIndexPath!])
            break
        case .update:
            print("update")
            photosCollectionView.reloadItems(at: [indexPath!])
            break
        case .delete:
            print("delete")
            photosCollectionView.deleteItems(at: [indexPath!])
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerDidChangeContent")
    }
}
