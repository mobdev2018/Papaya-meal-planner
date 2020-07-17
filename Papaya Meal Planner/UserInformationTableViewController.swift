//
//  UserInformationTableViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/2/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

import ActionSheetPicker_3_0

class UserInformationTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var activityLevelTextField: UITextField!
    @IBOutlet weak var numMealsTextField: UITextField!
    @IBOutlet weak var feetTextField: UITextField!
    @IBOutlet weak var inchesTextField: UITextField!
    
    // Create pickers
    let mealPicker: UIPickerView = UIPickerView(),
    activityLevelPicker: UIPickerView = UIPickerView(),
    weightGoalPicker: UIPickerView = UIPickerView()
    
    let mealOptions = ["4", "5", "6"],
    activityLevels = ["Sendentary" , "Lightly Active" , "Moderately Active" , "Very Active" , "Extra Active"],
    weightGoals = ["Lose Weight", "Gain Muscle Mass"]
    
    var measureType = "US"
    
    // feet and inches
    var feet = 0
    var inches = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get user settings
        getSettings()
        
        // Create Pickers
        createMealsPicker()
        createActivityLevelPicker()
        createWeightGoalPicker()
        
        // remove extra tableview cells
        tableView.tableFooterView = UIView()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        goalTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        activityLevelTextField.resignFirstResponder()
        numMealsTextField.resignFirstResponder()
        feetTextField.resignFirstResponder()
        inchesTextField.resignFirstResponder()
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
                    
                    if  name == "weekly_weight_goal" {
                        if value.intValue == -1 {
                            self.goalTextField.text = "Lose weight"
                        }
                        
                        if value.intValue == 1 {
                            self.goalTextField.text = "Gain Muscle Mass"
                        }
                    }
                    
                    if  name == "weight" {
                        self.weightTextField.text = "\(value.floatValue)"
                    }
                    
                    if  name == "height" {
                        self.heightTextField.text = "\(value.floatValue)"
                    }
                    
                    if  name == "activity_level" {
                        let activity = ["1.2": "Sendentary" , "1.375": "Lightly Active" , "1.55": "Moderately Active" , "1.725": "Very Active" , "1.9": "Extra Active"]
                        self.activityLevelTextField.text = activity[value.stringValue]
                    }
                    
                    if  name == "number_of_meals" {
                        self.numMealsTextField.text = "\(value.intValue)"
                    }
                    
                    if  name == "system_of_measurement" {
                        self.measureType = value.stringValue
                    }
                }
                
                if self.measureType == "US" {
                    // convert weight to pounds
                    self.weightConversion()
                    
                    // Hide the textfield
                    self.heightTextField.isHidden = true
                    
                    // convert height to feet and inches
                    self.heightConversion()
                } else {
                    self.feetTextField.isHidden = true
                    self.inchesTextField.isHidden = true
                    
                }
                
            case .failure:
                let alert = UIAlertController(title: "", message: "Network Error. Try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func weightConversion() {
        if let weight = weightTextField.text {
            if weight != "" {
                let kilograms = Double(weight)
                let pounds = Int(kilograms! / 0.4536)
                weightTextField.text = "\(pounds)"
            }
        }
    }
    
    func heightConversion() {
        // Convert cm to feet and inches
        if let cm = heightTextField.text {
            if cm != "" {
                let centimeters = Double(cm)
                let totalInches = Int(centimeters! / 2.54)
                
                let inchesValue = Int(totalInches) % 12
                let feetValue = (totalInches - inches) / 12
                
                feet = feetValue
                inches = inchesValue
                
                feetTextField.text = "\(feet)"
                inchesTextField.text = "\(inches)"
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        validateAndSubmit()
    }
    
    func validateAndSubmit () {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        guard  let meals = numMealsTextField.text, let goal = goalTextField.text, var weight = weightTextField.text, var height = heightTextField.text, let activityLevel = activityLevelTextField.text  else {
            let alert = UIAlertController(title: "", message: "One or more of the fields is missing", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if measureType == "US" {
            guard let feetValue = feetTextField.text, let inchesValue = inchesTextField.text else {
                let alert = UIAlertController(title: "", message: "One or more of the fields is missing", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // convert weight to kg
            let weightValue = Double(weight)
            weight = String(weightValue! * 0.4536)
            
            // convert height to cm
            let inches = (Int(feetValue)! * 12) + Int(inchesValue)!
            height = String(Double(inches) * 2.54)
            
        }
        
        let activityConversions = ["Sendentary": "1.2" , "Lightly Active": "1.375" , "Moderately Active": "1.55" , "Very Active": "1.725" , "Extra Active": "1.9"]
        
        let goalConversions = ["Lose Weight": "-1", "Gain Muscle Mass": "1"]
        
        let params = ["activity_level": activityLevel, "weekly_weight_goal": goal, "height": height, "number_of_meals": meals, "weight": weight, "shopping_list_days": "\(7)"]
        
        for (name, value) in params {
            var paramValue = value
            
            if name == "activity_level" {
                paramValue = activityConversions[value]!
            }
            
            if name == "weekly_weight_goal" {
                if let goal = goalConversions[value] {
                    paramValue = goal
                } else {
                    paramValue = goalConversions["Lose Weight"]!
                }
                
            }
            
            let parameters: Parameters = ["name": name, "value": paramValue]
            
            createUserSetting(parameters: parameters, headers: headers) { response in
                
            }
        }
        
        // Sends notification to meal plan page to create a new plan
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createNewMealPlan"), object: nil)
        
        // Once finished perform segue
        performSegue(withIdentifier: "UserInfoToSettings", sender: nil)
        
    }
    
    
    func createPicker(picker: UIPickerView) -> UIPickerView {
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        return picker
    }
    
    func createPickerToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    func createMealsPicker() {
        let picker = createPicker(picker: mealPicker)
        
        let toolBar = createPickerToolbar()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(mealsDonePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(mealsDonePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        numMealsTextField.inputView = picker
        numMealsTextField.inputAccessoryView = toolBar
    }
    
    func mealsDonePicker (sender:UIBarButtonItem) {
        numMealsTextField.resignFirstResponder()
    }
    
    func createActivityLevelPicker() {
        let picker = createPicker(picker: activityLevelPicker)
        
        let toolBar = createPickerToolbar()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(activityLevelDonePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(activityLevelDonePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        activityLevelTextField.inputView = picker
        activityLevelTextField.inputAccessoryView = toolBar
    }
    
    func activityLevelDonePicker (sender:UIBarButtonItem) {
        activityLevelTextField.resignFirstResponder()
    }
    
    func createWeightGoalPicker() {
        let picker = createPicker(picker: weightGoalPicker)
        
        let toolBar = createPickerToolbar()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(weightGoalDonePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(weightGoalDonePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        goalTextField.inputView = picker
        goalTextField.inputAccessoryView = toolBar
    }
    
    func weightGoalDonePicker (sender:UIBarButtonItem) {
        goalTextField.resignFirstResponder()
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case mealPicker:
            return mealOptions.count
        case activityLevelPicker:
            return activityLevels.count
        case weightGoalPicker:
            return weightGoals.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView {
        case mealPicker:
            numMealsTextField.text = mealOptions[row]
        case activityLevelPicker:
            activityLevelTextField.text = activityLevels[row]
        case weightGoalPicker:
            goalTextField.text = weightGoals[row]
        default:
            activityLevelTextField.text = ""
            numMealsTextField.text = ""
            goalTextField.text = ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case mealPicker:
            return mealOptions[row]
        case activityLevelPicker:
            return activityLevels[row]
        case weightGoalPicker:
            return weightGoals[row]
        default:
            return ""
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func showHeightCmPicker() {
        var arrNumbers = [String]()
        for i: Int in 122 ..< 272 {
            arrNumbers.append(NSString(format: "%i", i) as String)
        }
        
        let stringPicker =  ActionSheetStringPicker(title: nil, rows: arrNumbers, initialSelection: 100, doneBlock: { (picker, selectedIndex, values) in
            self.feetTextField.isHidden = true
            self.inchesTextField.isHidden = true
            self.heightTextField.isHidden = false
            self.heightTextField.text = arrNumbers[selectedIndex]
        }, cancel: { (picker) in
            
        }, origin: self.heightTextField)
        
        
//        stringPicker?.addCustomButton(withTitle: "Use US", actionBlock: {
//            self.showHeightFeetandInchPicker()
//        })
//        stringPicker?.setCancelButton(nil)
        
        stringPicker?.show()
    }
    
    func showHeightFeetandInchPicker() {
        var arrFeet = [String]()
        var arrInch = [String]()
        for i: Int in 4 ..< 9 {
            arrFeet.append(NSString(format: "%d", i) as String)
        }
        
        for i: Int in 0 ..< 12 {
            arrInch.append(NSString(format: "%d", i) as String)
        }
        
        let stringPicker =  ActionSheetMultipleStringPicker(title: nil, rows: [arrFeet, arrInch], initialSelection: [0, 0], doneBlock: { (picker, indexes, values) in
            self.heightTextField.isHidden = true
            self.feetTextField.isHidden = false
            self.inchesTextField.isHidden = false
            
            var selectedIndexes = indexes as! [Int]?
            self.feetTextField.text = arrFeet[(selectedIndexes?[0])!]
            self.inchesTextField.text = arrInch[(selectedIndexes?[1])!]
            
        }, cancel: { (picker) in
            
        }, origin: self.heightTextField)
        
//        stringPicker?.addCustomButton(withTitle: "Use Metric", actionBlock: {
//            self.showHeightCmPicker()
//        })
//        stringPicker?.setCancelButton(nil)
        stringPicker?.show()
    }
    
    @IBAction func onHeight(_ sender: AnyObject) {
        
        if measureType == "US" {
            self.showHeightFeetandInchPicker()
        } else {
            self.showHeightCmPicker()
        }
    }
    
}
