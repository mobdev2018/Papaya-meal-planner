//
//  Recipe.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/15/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation

class Recipe {
    let name: String
    var imageUrl: String
    var description: String
    let tag: [Tag]
    let prepTime: String
    let cookTime: String
    let recipeId: Int
    var recommenderServing: Int
    let servings: Int
    var url: String
    let instructions: [Instruction]
    var imageAttribution: String
    var favoriteId: Int?
    
    init(name: String, imageUrl: String?, description: String?, tags: [Tag], prepTime: String, cookTime: String, recipeId: Int, servings: Int, url: String?, instructions: [Instruction], imageAttribution: String?) {
        self.name = name
        self.tag = tags
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.recipeId = recipeId
        self.servings = servings
        self.instructions = instructions
        self.recommenderServing = 0
        self.imageUrl = ""
        self.description = ""
        self.url = ""
        self.imageAttribution = ""
        
        if let recipeImage = imageUrl{
            self.imageUrl = "https://data.mypapaya.io\(recipeImage)"
        }
        
        if let recipeDescription = description{
            self.description = recipeDescription
        }
        
        if let recipeURL = url{
            self.url = recipeURL
        }
        
        if let recipeImageAtrribution = imageAttribution{
            self.imageAttribution = recipeImageAtrribution
        }
    }
}
