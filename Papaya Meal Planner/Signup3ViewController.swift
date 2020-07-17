//
//  Signup3ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup3ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var headerNextButton: UIBarButtonItem!
    
    var data: [String: String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTextField.delegate = self
        dateTextField.becomeFirstResponder()
        
        // Hide error label
        errorLabel.isHidden = true
        
        // Disable buttons
        nextButton.isEnabled = false
        headerNextButton.isEnabled = false
        
        print(data!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Create datepicker
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.backgroundColor = .white
        
        // add toolbar to datepicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        // Show date picker when text input is active
        textField.inputView = datePickerView
        textField.inputAccessoryView = toolBar
        datePickerView.addTarget(self, action: #selector(Signup3ViewController.datePickerChanged(sender:)), for: .valueChanged)
        
    }
    
    func donePicker (sender:UIBarButtonItem) {
        
        dateTextField.resignFirstResponder()
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: sender.date)
        
        if ((dateTextField.text) != nil) {
            data?["date_of_birth"] = dateTextField.text
        }
        
        validateFields(sender: sender)
    }
    
    func doneButton(sender:UIButton) {
        // resigns the inputView on clicking done.
        dateTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func validateFields(sender: UIDatePicker){
        // Get the current year
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        // Get the datepicker year
        let chosenDate = sender.date
        let chosenYear = calendar.component(.year, from: chosenDate)
        
        // Get selected age
        let age = year - chosenYear
        
        if age < 12 {
            errorLabel.isHidden = false
            
            // Disable next button
            nextButton.alpha = 0.5
            nextButton.isEnabled = false
            
            // Disable header next button
            headerNextButton.tintColor = UIColor.lightGray
            headerNextButton.isEnabled = false
        } else {
            errorLabel.isHidden = true
            
            // Enable next button
            nextButton.alpha = 1
            nextButton.isEnabled = true
            
            // Enable header button
            headerNextButton.tintColor = UIColor.white
            headerNextButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "step3ToStep4":
                let signup4VC = segue.destination as! Signup4ViewController
                signup4VC.data = data
            default: break
            }
        }
    }
    
}
