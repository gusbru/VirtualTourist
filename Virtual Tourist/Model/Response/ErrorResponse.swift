//
//  ErrorResponse.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-04-29.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    var stat: String
    var code: Int
    var message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

/*
 
 {
     "stat": "fail",
     "code": 112,
     "message": "Method \"search\" not found"
 }
 
 */
