//
//  MealPlanNutritionTableViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/14/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit
import Charts

class MealPlanNutritionTableViewController: UITableViewController, ChartViewDelegate {
    
    var mealPlan: MealPlan?
    
    var macroValues: [String: Int] = [String: Int]()
    var targetMacroValues: [String: Int] = [String: Int]()
    var nutritionInfo: [String : [String: Any]]?
    
    let labelOrder = ["Calories", "Total Fat", "Cholesterol", "Sodium", "Total Carbohydrate", "Dietary Fiber", "Protein"]
    
    let chartColors = [UIColor(red: 232/255, green: 63/255, blue: 111/255, alpha: 1), UIColor(red: 236/255, green: 93/255, blue: 134/255, alpha: 1), UIColor(red: 239/255, green: 124/255, blue: 156/255, alpha: 1)]
    
    fileprivate var macros = ["Protein", "Carbohydrates", "Fat"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // change controller background color
        tableView.backgroundColor = UIColor(red: 254.0 / 255, green: 250.0 / 255, blue: 252.0 / 255, alpha: 1)
        
        // set the target macro values
        setTargetMacroValues()
        
        // set the current macro values
        setCurrentMacroValues()
        
        // initialize the nutrition label
        nutritionInfo = ["Calories": ["measure": mealPlan?.nutritionLabel.energyKcal ?? 0, "unit": ""], "Total Fat": ["measure": mealPlan?.nutritionLabel.totalFat ?? 0, "unit": "g"], "Cholesterol": ["measure": mealPlan?.nutritionLabel.cholesterol ?? 0, "unit": "mg"], "Sodium": ["measure": mealPlan?.nutritionLabel.sodium ?? 0, "unit": "mg"], "Total Carbohydrate": ["measure": mealPlan?.nutritionLabel.totalCarbohydrate ?? 0, "unit": "g"], "Dietary Fiber": ["measure": mealPlan?.nutritionLabel.dietaryFiber ?? 0, "unit": "g"], "Protein": ["measure": mealPlan?.nutritionLabel.protein ?? 0, "unit": "g"]]
        
        self.title = "Meal Plan Nutrition"
    }
    
    func setTargetMacroValues() {
        guard let nutrients = mealPlan?.nutrients else {
            return
        }
        
        for nutrient in nutrients {
            switch nutrient.name {
            case "target_total_carbohydrate_percentage":
                if let quantity = Double(nutrient.quantity) {
                    targetMacroValues["carbohydrates"] = Int(quantity)
                }
            case "target_total_fat_percentage":
                if let quantity = Double(nutrient.quantity) {
                    targetMacroValues["fat"] = Int(quantity)
                }
            case "target_protein_percentage":
                if let quantity = Double(nutrient.quantity) {
                    targetMacroValues["protein"] = Int(quantity)
                }
            default:
                ()
            }
        }
    }
    
    func setCurrentMacroValues() {
        guard let calories = mealPlan?.nutritionLabel.energyKcal else {
            return
        }
        
        guard let carbohydrates = mealPlan?.nutritionLabel.totalCarbohydrate else {
            return
        }
        
        guard let fat = mealPlan?.nutritionLabel.totalFat else {
            return
        }
        
        guard let protein = mealPlan?.nutritionLabel.protein else {
            return
        }
        
        let carbsPercent = (Double(carbohydrates * 4) / Double(calories)) * 100.0
        let fatPercent = (Double(fat * 9) / Double(calories)) * 100.0
        let proteinPercent = (Double(protein * 4) / Double(calories)) * 100.0
        
        macroValues["carbohydrates"] = Int(round(carbsPercent))
        macroValues["fat"] = Int(round(fatPercent))
        macroValues["protein"] = Int(round(proteinPercent))
    }

    func setDataCount(pieChart: PieChartView, count: Int, range: Double) {
        var vals: [ChartDataEntry] = [ChartDataEntry]()
        
        let values = [macroValues["carbohydrates"], macroValues["fat"], macroValues["protein"]]
        
        for i in values {
            if let nutrientVal = i {
                vals.append(PieChartDataEntry(value: Double(nutrientVal)))
            }
        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: vals, label: "Macros")
        let data: PieChartData = PieChartData(dataSet: dataSet)
        dataSet.sliceSpace = 2.0
        // add colors to the chart
        var colors: [NSUIColor] = [NSUIColor]()
        colors.append(chartColors[0])
        colors.append(chartColors[1])
        colors.append(chartColors[2])
        dataSet.colors = colors
        data.setValueFont(UIFont(name: "Avenir-Medium", size: 12.0))
        data.setValueTextColor(UIColor.white)
        pieChart.data = data
        pieChart.highlightValues(nil)
    }
    
    func changeUnitColor(unit: String) -> NSMutableAttributedString {
        let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
        let unitString = NSMutableAttributedString(string: " \(unit)", attributes: [NSForegroundColorAttributeName: pinkColor])
        
        return unitString
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let count = nutritionInfo?.count {
                return count
            } else {
                return 0
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "macrosCell", for: indexPath) as! MacrosTableViewCell
            // Set the background colors for the legend
            cell.carbsColorView.backgroundColor = chartColors[0]
            cell.fatColorView.backgroundColor = chartColors[1]
            cell.proteinColorView.backgroundColor = chartColors[2]
            
            // Set target macro values
            if let targetCarbohydrates = targetMacroValues["carbohydrates"] {
                cell.carbsTargetPercentLabel.text = "\(targetCarbohydrates)%"
            }
            
            if let targetFat = targetMacroValues["fat"] {
                cell.fatTargetPercentLabel.text = "\(targetFat)%"
            }
            
            if let targetProtein = targetMacroValues["protein"] {
                cell.proteinTargetPercentLabel.text = "\(targetProtein)%"
            }
            
            // Set total macro values
            if macroValues.count != 0 {
                if let carbs = macroValues["carbohydrates"] {
                    cell.carbsTotalPercentLabel.text = "\(carbs)%"
                }
                
                if let fat = macroValues["fat"] {
                    cell.fatTotalPercentLabel.text = "\(fat)%"
                }
                
                if let protein = macroValues["protein"] {
                    cell.proteinTotalPercentLabel.text = "\(protein)%"
                }
            }
            
            let pieChart = cell.pieChartView
            pieChart?.delegate = self
            pieChart?.legend.enabled = false
            pieChart?.chartDescription?.text = ""
            pieChart?.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInCubic)
            
            if let macroPieChart = pieChart {
                setDataCount(pieChart: macroPieChart, count: macros.count, range: 4.0)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nutritionFactsCell", for: indexPath) as! NutritionTableViewCell
            
            if indexPath.row == 0 {
                cell.topLine.isHidden = true
            }
            
            let nutrient = labelOrder[indexPath.row]
            cell.lblTitle?.text = nutrient
            
            let detail = String(describing: Int(round(nutritionInfo?[nutrient]?["measure"] as! Double)))
            let measure = NSMutableAttributedString(string: detail , attributes: [NSForegroundColorAttributeName: UIColor.black])
            
            if indexPath.row != 0 {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 320.0
        
        if indexPath.section == 1 {
            height = 55
        }
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! MealNutritionHeaderTableViewCell
            
            cell.headerNameLabel.text = "Macros"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! MealNutritionHeaderTableViewCell
            
            cell.headerNameLabel.text = "Nutrition Information"
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = 50.0
        
        return CGFloat(height)
    }
 
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 0.01
        } else {
            return 20
        }
        
    }

}
