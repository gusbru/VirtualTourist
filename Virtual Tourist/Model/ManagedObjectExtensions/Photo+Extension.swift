//
//  Photo+Extension.swift
//  Virtual Tourist
//
//  Created by Gustavo Brunetto on 2020-05-01.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        dateAdded = Date()
    }
}
