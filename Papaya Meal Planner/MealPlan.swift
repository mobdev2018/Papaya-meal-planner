//
//  MealPlan.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/17/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation

class MealPlan {
    let user: Int
    let date: String?
    let id: Int
    var meals: [Meal]
    let name: String?
    let nutrients: [Nutrient]
    var nutritionLabel: NutritionLabel
    
    init(user: Int, id: Int, name: String?, nutrients: [Nutrient]) {
        self.user = user
        self.id = id
        self.meals = [Meal]()
        self.name = name
        self.nutrients = nutrients
        self.date = nil
        nutritionLabel = NutritionLabel()
    }

}
