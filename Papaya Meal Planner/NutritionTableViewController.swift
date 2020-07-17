//
//  NutritionTableViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/27/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class NutritionTableViewController: UITableViewController {

    var recipe: Recipe?
    var nutritionInfo: [String : [String: Any]]?
    
    let labelOrder = ["Servings", "Calories", "Total Fat", "Cholesterol", "Sodium", "Total Carbohydrate", "Dietary Fiber", "Protein"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the recipe ID
        let recipeId = recipe?.recipeId
        
        getRecipeNutritionInfo(id: recipeId!, completion: { results in
            self.nutritionInfo = [String : [String: Any]]()
            
            let nutrition: [String: [String: Any]] = ["Calories": ["measure": results["energy_kcal"]!, "unit": ""], "Total Fat": ["measure": results["total_fat"]!, "unit": "g"], "Cholesterol": ["measure": results["cholesterol"]!, "unit": "mg"], "Sodium": ["measure": results["sodium"]!, "unit": "mg"], "Total Carbohydrate": ["measure": results["total_carbohydrate"]!, "unit": "g"], "Dietary Fiber": ["measure": results["dietary_fiber"]!, "unit": "g"], "Protein": ["measure": results["protein"]!, "unit": "g"]]
            
            
            self.nutritionInfo = nutrition
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = nutritionInfo?.count ?? 0
        return count + 2
    }
    
    func changeUnitColor(unit: String) -> NSMutableAttributedString {
        let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
        let unitString = NSMutableAttributedString(string: " \(unit)", attributes: [NSForegroundColorAttributeName: pinkColor])
        
        return unitString
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "nutritionFactsHeaderCell", for: indexPath)
            
            return headerCell;
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "nutritionFactsCell", for: indexPath) as! NutritionTableViewCell
        
        if row == 1 {
            let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
            cell.imgPoint.image = UIImage(named: "point_green")
            cell.lblTitle.textColor = pinkColor
            cell.lblDetail.textColor = pinkColor
            cell.lblTitle.text = labelOrder[indexPath.row - 1]
            cell.lblDetail.text = "\(recipe!.recommenderServing)"
            
            return cell
        }

        let nutrient = labelOrder[indexPath.row - 1]
        cell.lblTitle?.text = nutrient
        let detail = String(describing: Int(round(nutritionInfo?[nutrient]?["measure"] as! Double)) * recipe!.recommenderServing)
        let measure = NSMutableAttributedString(string: detail, attributes: [NSForegroundColorAttributeName: UIColor.black])
        
        if row != 2 {
            let unit = changeUnitColor(unit: nutritionInfo?[nutrient]?["unit"] as! String)
            
            let combination = NSMutableAttributedString()
            
            combination.append(measure)
            combination.append(unit)
            cell.lblDetail.attributedText = combination
        } else {
            cell.lblDetail.attributedText = measure
        }
        
        
        return cell
    }

}
