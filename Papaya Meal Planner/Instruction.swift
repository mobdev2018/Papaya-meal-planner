//
//  Instructions.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/17/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Marshal

class Instruction: Unmarshaling {
    let id: Int
    let order: Int
    let description: String
    
    required init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        order = try object.value(for: "order")
        description = try object.value(for: "description")
    }
}
