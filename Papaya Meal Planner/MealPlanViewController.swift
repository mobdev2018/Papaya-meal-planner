//
//  MealPlanViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/8/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import EZLoadingActivity
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON
import Marshal
import Kingfisher
import NVActivityIndicatorView

class MealPlanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var mealPlanTableView: UITableView!
    
    var activityIndicatorView : NVActivityIndicatorView?
    
    var mealPlan: MealPlan?
    var showMealTip = true
    var meals: [[Meal]] = [[Meal]]()
    var caloriesCellCount = 0
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // change controller background color
        mealPlanTableView.backgroundColor = UIColor(red: 254.0 / 255, green: 250.0 / 255, blue: 252.0 / 255, alpha: 1)
        
        // load meal plan
        loadMealPlan()
        
        // Listens to create a new meal plan
        NotificationCenter.default.addObserver(self, selector: #selector(MealPlanViewController.createNewMealPlan(_:)), name: NSNotification.Name(rawValue: "createNewMealPlan"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func loadMealPlan() {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        // show loading indicator
        if isLoading {
            let screenSize = UIScreen.main.bounds.size
            let originPoint = CGPoint(x: (screenSize.width-60) / 2, y: (screenSize.height-60) / 2)
            
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(origin: originPoint, size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE), type: NVActivityIndicatorType(rawValue: 1), color: UIColor(red: 203.0 / 255.0, green: 24.0/255.0, blue: 75.0 / 255.0, alpha: 1.0), padding: NVActivityIndicatorView.DEFAULT_PADDING)
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView!)
            
            activityIndicatorView?.startAnimating()
        }
        
        getMealPlan(headers: headers) { response in
            switch response.result {
            case .success:
                if self.isLoading {
                    self.activityIndicatorView?.stopAnimating()
                }
                
                self.caloriesCellCount = 1
                
                guard let data = response.data else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                let json = JSON(data: data),
                results = json["results"][0],
                mealIds = results["meal"].arrayObject,
                name = results["name"].string,
                id = results["id"].intValue,
                user = results["user"].intValue
                
                // Create Nutrient object list
                let nutrientArr:[[String: Any]] = results["nutrients"].arrayValue.map { $0.dictionaryObject!}
                let nutrientDict: [String: Any] = ["nutrients": nutrientArr]
                let nutrients: [Nutrient] = try! nutrientDict.value(for: "nutrients")
                
                self.mealPlan = MealPlan(user: user, id: id, name: name, nutrients: nutrients)
                
                self.getNutrion(id: id, type: "mealPlan") { result in
                    self.mealPlan?.nutritionLabel = result
                }
                
                if let userMeals = mealIds {
                    for mealId in userMeals {
                        self.getMeals(mealId: mealId as! Int)
                    }
                } else {
                    let alert = UIAlertController(title: "", message: "You currently don't have a any meals. Tap the refresh button to create a new meal plan.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure:
                if self.isLoading {
                    self.activityIndicatorView?.stopAnimating()
                }
                
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getMeals(mealId: Int) {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        getMealPlanMeals(headers: headers, id: mealId) { response in
            switch response.result {
            case .success:
                guard let data = response.result.value else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                let json = JSON(data: data),
                results = json["result"],
                name = results["name"].stringValue,
                user = results["user"].intValue,
                id = results["id"].intValue,
                saved = results["saved"].boolValue
                
                let recipeIds: [[String: Any]] = results["recipes"].arrayValue.map { $0.dictionaryObject!}
            
                // Create a meal object
                let meal = Meal(id: id, name: name, user: user, saved: saved)
                
                // Get meal nutrition Info
                self.getNutrion(id: mealId, type: "meal") { result in
                    meal.nutritionLabel = result
                }
                
                // Update meals when we get more meals
                self.meals.append([meal])
                
                // Get meal recipes
                for recipeId in recipeIds {
                    let recipe = recipeId["recipe"]
                    // Servings the user should eat
                    let servings = recipeId["servings"]
                    
                    self.getRecipes(recipeId: recipe as! Int){ result in
                        result.recommenderServing = servings as! Int
                        meal.recipes.append(result)
                        
                        if meal.recipes.count == recipeIds.count {
                            DispatchQueue.main.async {
                                self.mealPlanTableView.reloadData()
                            }
                        }

                    }
                }
                
            case .failure:
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func getRecipes(recipeId: Int, completion: @escaping (_ result: Recipe) -> Void) {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        getMealRecipes(headers: headers, id: recipeId) { response in
            switch response.result {
            case .success:
                guard let data = response.result.value else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                // Parse JSON
                let json = JSON(data: data),
                results = json["result"],
                url = results["url"].stringValue,
                name = results["name"].stringValue,
                imageAttribution = results["image_attribution"].stringValue,
                description = results["descriptions"].stringValue,
                prepTime = results["prep_time"].stringValue,
                id = results["id"].intValue,
                image = results["image"].stringValue,
                cookTime = results["cook_time"].stringValue,
                servings = results["servings"].intValue
                
                // Create Tag object list
                let tagArr:[[String: Any]] = results["tags"].arrayValue.map { $0.dictionaryObject!}
                let tagDict: [String: Any] = ["tags": tagArr]
                let tags: [Tag] = try! tagDict.value(for: "tags")
                
                // Create Instruction object list
                let instructionArr:[[String: Any]] = results["instructions"].arrayValue.map { $0.dictionaryObject!}
                let instructionDict: [String: Any] = ["instructions": instructionArr]
                let instructions: [Instruction] = try! instructionDict.value(for: "instructions")
                
                let recipe = Recipe(name: name, imageUrl: image, description: description, tags: tags, prepTime: prepTime, cookTime: cookTime, recipeId: id, servings: servings, url: url, instructions: instructions, imageAttribution: imageAttribution)
                
                completion(recipe)
                
            case .failure:
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getNutrion(id: Int, type: String, completion: @escaping (_ result: NutritionLabel) -> Void) {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        getNutritionInfo(headers: headers, id: id, type: type) { response in
            switch response.result {
            case .success:
                guard let data = response.result.value else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                // Parse JSON
                let json = JSON(data: data)
                let nutrientArr = json["result"].dictionaryObject!
                let nutrientDict: [String: Any] = ["nutrients": nutrientArr]
                let nutritionLabel: NutritionLabel = try! nutrientDict.value(for: "nutrients")
                completion(nutritionLabel)
                
            case .failure:
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createNewMealPlan(_ sender: Any) {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        let parameters: Parameters = ["action_type": "create_meal_plan"]
        
        EZLoadingActivity.show("Cheffin' a new meal plan...", disableUI: true)
        
        generateMealPlan(parameters: parameters, headers: headers) { response in
            switch response.result {
                case .success:
                    self.caloriesCellCount = 1
                    self.meals.removeAll()
                    self.mealPlan = nil
                    self.loadMealPlan()
                    
                    EZLoadingActivity.hide()
                    
                    // Sends notification to grocery page to update
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadGroceryNotification"), object: nil)
                    
                case .failure:
                    EZLoadingActivity.hide()
                    
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func createNewMeal(id: Int) {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        let parameters: Parameters = ["action_type": "create_meal", "id": "\(id)"]
        
        EZLoadingActivity.show("Cheffin' a new meal...", disableUI: true)
        
        generateMealPlan(parameters: parameters, headers: headers) { response in
            switch response.result {
            case .success:
                self.meals.removeAll()
                self.mealPlan = nil
                self.loadMealPlan()
                
                EZLoadingActivity.hide()
                
                // Sends notification to grocery page to update
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadGroceryNotification"), object: nil)
                
            case .failure:
                EZLoadingActivity.hide()
                
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func imageFromServerURL(urlString: String, completion: @escaping (_ data: Data) -> Void) {
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            
            completion(data!)
            
        }).resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Adds calories section
        return meals.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return one cell for the first section
        if section == 0 {
            return caloriesCellCount
        } else {
            return meals[section-1].first!.recipes.count
        }
    }
    
    func onNutritionButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MealPlanNutritionTableViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let screenSize = UIScreen.main.bounds.size
        
        if meals.count != 0 {
            isLoading = false
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CaloriesCell", for: indexPath) as! CaloriesTableViewCell
            
            let borderColor = UIColor(red: 1, green: 245/255, blue: 248/255.0, alpha: 1)
            cell.view.layer.borderColor = borderColor.cgColor
            cell.view.layer.borderWidth = 2
            cell.view.layer.cornerRadius = 5
            UIViewShadow(view: cell.view)
            
            cell.lblTitle.font = UIFont(name: cell.lblTitle.font.fontName, size: 18 * screenSize.width / 375)
            cell.lblCurrentPlan.font = UIFont(name: cell.lblCurrentPlan.font.fontName, size: 14 * screenSize.width / 375)
            cell.lblTarget.font = UIFont(name: cell.lblTarget.font.fontName, size: 14 * screenSize.width / 375)
            if let plan = mealPlan {
                let targetCalorieNutrient = plan.nutrients.first(where:{$0.name == "target_energy_kcal"})
                cell.targetCaloriesLabel.text = "\(Int(round(Double(targetCalorieNutrient!.quantity)!)))"
                cell.currentCaloriesLabel.text = "\(Int(round(plan.nutritionLabel.energyKcal)))"
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! mealTableViewCell
            
            let numberofrows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == (numberofrows - 1) {
                let rectShape = CAShapeLayer()
                var frame = CGRect(x: 0, y: 0, width: screenSize.width - 20, height: 108)
                rectShape.bounds = frame
                rectShape.position = CGPoint(x: (screenSize.width - 20) / 2, y: 54)
                rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
                cell.view.layer.mask = rectShape
                
                let rectShape1 = CAShapeLayer()
                frame = CGRect(x: 0, y: 0, width: screenSize.width - 16, height: 110)
                rectShape1.bounds = frame
                rectShape1.position = CGPoint(x: (screenSize.width - 16) / 2, y: 55)
                rectShape1.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
                cell.borderView.layer.mask = rectShape1
            }
            
            cell.recipeName.text = meals[indexPath.section-1].first!.recipes[indexPath.row].name
            let numServings = meals[indexPath.section-1].first!.recipes[indexPath.row].recommenderServing
            
            if (numServings == 1) {
                cell.recipeServing.text = "\(numServings) Serving"
            } else {
                cell.recipeServing.text = "\(numServings) Servings"
            }
            
            UIViewShadow(view: cell.recipeBorder)
            
            let imageUrl = meals[indexPath.section-1].first!.recipes[indexPath.row].imageUrl
            
            if (imageUrl != ""){
                // Get recipe image
                let url = URL(string: imageUrl)
                
                if url != nil {
                    cell.recipeImage.kf.setImage(with: url)
                }
            }
            
            if cell.recipeImage.image == nil {
                cell.recipeImage.image = UIImage(named: "dish")
            }
            
            // Remove selection highlight
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func UIViewShadow(view: UIView) {
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! MealTableViewHeaderCell
            
            let screenSize = UIScreen.main.bounds.size
            
            let rectShape = CAShapeLayer()
            var frame = CGRect(x: 0, y: 0, width: screenSize.width - 20, height: 48)
            rectShape.bounds = frame
            rectShape.position = CGPoint(x: (screenSize.width - 20) / 2, y: 24)
            rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
            cell.view.layer.mask = rectShape
            
            let rectShape1 = CAShapeLayer()
            frame = CGRect(x: 0, y: 0, width: screenSize.width - 16, height: 50.0)
            rectShape1.bounds = frame
            rectShape1.position = CGPoint(x: (screenSize.width - 16) / 2, y: 25)
            rectShape1.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
            cell.borderView.layer.mask = rectShape1
        
            
            // Label for the meal name
            let meal = meals[section-1].first!
            let mealText = meal.name.uppercased()
            cell.mealName.text = mealText
            cell.mealName.textColor = UIColor(red: 203.0 / 255.0, green: 24.0/255.0, blue: 75.0 / 255.0, alpha: 1.0)
            
            //label for the meal calories
            cell.numCalories.text = "\(Int(round(meal.nutritionLabel.energyKcal)))"
            
            cell.regenerateButton.tag = section
            cell.regenerateButton.addTarget(self, action: #selector(self.regenerateMeal), for: .touchUpInside)
            
            cell.checkButton.tag = section
            cell.checkButton.addTarget(self, action: #selector(self.onCheck), for: .touchUpInside)
            
            return cell
        }
    }
    
    func regenerateMeal(sender:UIButton) {
        let section = sender.tag - 1
        let mealId = meals[section].first!.id
        createNewMeal(id: mealId)
    }
    
    func onCheck(sender:UIButton) {
        let section = sender.tag - 1
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 110.0
        if indexPath.section == 0 {
            height = 179
        }
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 50.0
        if section == 0 {
            height = 0
        }
        return CGFloat(height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "mealplanToRecipe":
                    let recipeVC = segue.destination as! RecipeViewController
                    if let indexPath = self.mealPlanTableView.indexPath(for: sender as! UITableViewCell) {
                        recipeVC.recipe = getRecipeAtIndexPath(indexPath: indexPath)
                    }
                case "caloriesToNutrition":
                    let mealPlanNutritionVC = segue.destination as! MealPlanNutritionTableViewController
                    mealPlanNutritionVC.mealPlan = mealPlan
                default: break
            }
        }
    }
    
    func getRecipeAtIndexPath(indexPath: IndexPath) -> Recipe {
        let meal = meals[indexPath.section-1].first!
        return meal.recipes[indexPath.row]
    }

}
