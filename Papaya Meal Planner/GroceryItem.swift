//
//  GroceryItem.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/19/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Marshal

class GroceryItem: Unmarshaling {
    let id: Int
    let quantity: String
    let item: String
    
    required init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        quantity = try object.value(for: "quantity")
        item = try object.value(for: "item")
        
    }
}
