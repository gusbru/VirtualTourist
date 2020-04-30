//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-04-29.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit
import MapKit

class LocationsMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        PhotoAlbumClient.getPhotos(latitude: 0, longitude: 0) { (response, error) in
            if let response = response {
                print(response)
            }
            
            if let error = error {
                print(error)
            }
        }
    }
    
    

}

