//
//  IngredientsTableViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/27/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class IngredientsTableViewController: UITableViewController {
    
    var recipe: Recipe?
    var ingredients: [[String]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the recipe ID
        let recipeId = recipe?.recipeId
        
        // get recipe Ingredients
        getRecipeIngredients(id: recipeId!, completion: { results in
            self.ingredients = [[String]]()
            
            for result in results {
                let ingredientText = result["raw_text"]! as! String
                self.ingredients?.append([ingredientText])
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        self.tableView.separatorColor = UIColor.clear
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = ingredients?.count ?? 0
        return count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "ingredientsHeaderCell", for: indexPath)
            
            return headerCell;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath) as! IngredientsTableViewCell
        
        let singleIngredient = ingredients?[row-1]
        cell.lblTitle?.text = singleIngredient?.first
        
        return cell
    }

}
