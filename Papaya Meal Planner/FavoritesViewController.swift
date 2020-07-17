//
//  FavoritesViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/19/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON
import Kingfisher

class FavoritesViewController: UITableViewController {

    var favoriteRecipes: [Recipe] = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loads favorite recipes
        loadFavoriteRecipes()
        
        // remove extra tableview cells
        tableView.tableFooterView = UIView()
        
        // Listens for when a meal is favorited
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.reloadFavorites), name: NSNotification.Name(rawValue: "reloadFavorites"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func reloadFavorites() {
        self.favoriteRecipes.removeAll()
        loadFavoriteRecipes()
    }
    
    func loadFavoriteRecipes() {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        getFavorites(headers: headers) { response in
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
                results = json["results"]
                
                for result in results {
                    let recipeId = result.1["recipe"].intValue
                    let favoriteId = result.1["id"].intValue
                    
                    self.getRecipes(recipeId: recipeId) { recipe in
                        recipe.favoriteId = favoriteId
                        self.favoriteRecipes.append(recipe)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
    
    func UIViewShadow(view: UIView) {
        view.layer.shadowColor = UIColor(red: 203.0 / 255.0, green: 24.0/255.0, blue: 75.0 / 255.0, alpha: 1.0).cgColor
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "favoritesToRecipe":
                let recipeVC = segue.destination as! RecipeViewController
                if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                    recipeVC.recipe = getRecipeAtIndexPath(indexPath: indexPath)
                    recipeVC.recipe?.recommenderServing = 1
                }
                
            default: break
            }
        }
    }
    
    func getRecipeAtIndexPath(indexPath: IndexPath) -> Recipe {
        let recipe = favoriteRecipes[indexPath.row]
        return recipe
    }
    
    func deleteFavorite(indexPath: IndexPath, completion: @escaping (_ response: Int) -> Void) {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        let recipe = getRecipeAtIndexPath(indexPath: indexPath)
        
        if let id = recipe.favoriteId {
            deleteFavoriteRecipe(id: id, headers: headers) { response in
                switch response.result {
                case .success:
                guard let code = response.response?.statusCode else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                completion(code)
                
                case .failure:
                let alert = UIAlertController(title: "", message: "Network error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! favoritesTableViewCell
        cell.recipeNameLabel.text = favoriteRecipes[indexPath.row].name
        UIViewShadow(view: cell.recipeBorderView)
        
        let imageUrl = favoriteRecipes[indexPath.row].imageUrl
        
        if (imageUrl != ""){
            // Get recipe image
            let url = URL(string: imageUrl)
            
            if url != nil {
                cell.recipeImageView.kf.setImage(with: url)
            }
        }
        
        if cell.recipeImageView.image == nil {
            cell.recipeImageView.image = UIImage(named: "dish")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.deleteFavorite(indexPath: indexPath) { response in
            
                if response == 204 {
                    self.favoriteRecipes.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.left)
                }
            }
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect cell when cell is selected
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
