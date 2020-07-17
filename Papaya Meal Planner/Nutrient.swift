//
//  Nutrient.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/17/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Marshal

class Nutrient: Unmarshaling {
 
    let quantity: String
    let id: Int
    let measure: String
    let name: String
    
    required init(object: MarshaledObject) throws {
        quantity = try object.value(for: "quantity")
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        measure = try object.value(for: "measure")
        
    }
    
}
