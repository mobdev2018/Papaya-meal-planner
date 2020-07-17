//
//  Tag.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/17/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Marshal

class Tag: Unmarshaling {
    let id: Int
    let name: String
    
    required init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        
    }
}
