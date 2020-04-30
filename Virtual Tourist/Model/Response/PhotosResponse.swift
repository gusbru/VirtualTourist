//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-04-29.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct FlickrPhoto: Codable {
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    var ispublic: Int
    var isfriend: Int
    var isfamily: Int
}

struct Photos: Codable {
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
    var photo: [FlickrPhoto?]
}

struct PhotoResponse: Codable {
    var photos: Photos
    var stat: String
}


/*
 
 {
     "photos": {
         "page": 2,
         "pages": 218984,
         "perpage": 5,
         "total": "1094920",
         "photo": [
             {
                 "id": "49835396712",
                 "owner": "40802917@N06",
                 "secret": "d8ff1d4000",
                 "server": "65535",
                 "farm": 66,
                 "title": "Swimming Upstream",
                 "ispublic": 1,
                 "isfriend": 0,
                 "isfamily": 0
             },
         ]
     },
     "stat": "ok"
 }
 
 */
