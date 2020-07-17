//
//  TargetsTableViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/2/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class TargetsTableViewController: UITableViewController {

    @IBOutlet weak var fatsTextField: UITextField!
    @IBOutlet weak var carbohydratesTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    
    // set inital target values
    var targetProtein = 20,
    targetCarbohydrates = 50,
    targetFats = 30
    
    // system of measure
    var measureType = "US"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get User settings
        getSettings()
        
        // remove extra tableview cells
        tableView.tableFooterView = UIView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fatsTextField.resignFirstResponder()
        carbohydratesTextField.resignFirstResponder()
        proteinTextField.resignFirstResponder()
    }

    func getSettings() {
        // Get api token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)"]
        
        getUserSettings(headers: headers){ response in
            switch response.result {
            case .success:
                guard let data = response.data else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                let json = JSON(data: data),
                results = json["results"]
                
                // set target values
                for result in results {
                    let name = result.1["name"],
                    value = result.1["value"]

                    if  name == "target_total_fat_percentage" {
                        self.targetFats = value.intValue
                    }
                    
                    if  name == "target_total_carbohydrate_percentage" {
                        self.targetCarbohydrates = value.intValue
                    }
                    
                    if  name == "target_protein_percentage" {
                        self.targetProtein = value.intValue
                    }
                }
                
                // Set textfield values
                self.fatsTextField.text = "\(self.targetFats)"
                self.carbohydratesTextField.text = "\(self.targetCarbohydrates)"
                self.proteinTextField.text = "\(self.targetProtein)"
                
            case .failure:
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func onSubmit(_ sender: UIBarButtonItem) {
        validateMacros()
    }
    
    func validateMacros () {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        guard  let fats = fatsTextField.text, let protein = proteinTextField.text, let carbohydrates = carbohydratesTextField.text  else {
            let alert = UIAlertController(title: "", message: "One or more macronutrients is missing", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // get total macro percentage
        let totalMacroPercentage = Int(fats)! + Int(protein)! + Int(carbohydrates)!
        
        if totalMacroPercentage != 100 {
            // Show error if total macros don't equal 100 %
            let alert = UIAlertController(title: "", message: "Macronutrients must equal 100 %.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let params = ["target_total_fat_percentage": fats, "target_total_carbohydrate_percentage": carbohydrates, "target_protein_percentage": protein]
            
            for (name, value) in params {
                let parameters: Parameters = ["name": name, "value": value]
                
                createUserSetting(parameters: parameters, headers: headers) { response in
                    
                }
            }
            
            // Sends notification to meal plan page to create a new plan
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createNewMealPlan"), object: nil)
            
            // Once finished perform segue
            performSegue(withIdentifier: "TargetsToSettings", sender: nil)
        }
    
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

}
