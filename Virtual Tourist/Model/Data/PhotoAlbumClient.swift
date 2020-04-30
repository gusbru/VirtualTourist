//
//  PhotoAlbumClient.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-04-29.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

class PhotoAlbumClient {
    
    enum Endpoints {
        static let flickrAPIKey = "fe5c1bd8595cebc4d37f47186ff818cf"
        static let flickrSecret = "953e0475ac3379f8&"
        static let base = "https://www.flickr.com/services/rest/"
        enum FlickrMethods: String {
            case search = "flickr.photos.search"
        }
        
        case getPhotoByGeo(latitude: Double, longitude: Double, numberOfPhotos: Int)
        
        var stringVaue: String {
        switch self {
        case .getPhotoByGeo(latitude: let latitude, longitude: let longitude, numberOfPhotos: let numberOfPhotos):
            return "\(Endpoints.base)?method=\(FlickrMethods.search.rawValue)&api_key=\(Endpoints.flickrAPIKey)&lat=\(latitude)&lon=\(longitude)&per_page=\(numberOfPhotos)&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringVaue)!
        }
        
    }
    
    // MARK: - GET METHODS
    class func getPhotos(latitude: Double, longitude: Double, completion: @escaping (PhotoResponse?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getPhotoByGeo(latitude: latitude, longitude: longitude, numberOfPhotos: 10).url, ResponseType: PhotoResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            }
            
            if let error = error {
                completion(nil, error)
            }
        }
    }
    
    
    
    // MARK:- GET Request
    private class func taskForGETRequest<ResponseType: Decodable>(url: URL, ResponseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            
            do {
                
                let responseObject = try decoder.decode(ResponseType.self, from: data)

                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    
                    let errorObject = try decoder.decode(ErrorResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil, errorObject)
                    }
                } catch {
                    
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        
        task.resume()
    }
    
}
