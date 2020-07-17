//
//  Meal.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/18/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation

class Meal {
    let id: Int
    var nutritionLabel: NutritionLabel
    var recipes: [Recipe]
    let name: String
    let user: Int
    let saved: Bool
    
    init(id: Int, name: String, user: Int, saved: Bool) {
        self.id = id
        self.nutritionLabel = NutritionLabel()
        self.recipes = [Recipe]()
        self.name = name
        self.user = user
        self.saved = saved
    }
}
