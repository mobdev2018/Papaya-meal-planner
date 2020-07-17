//
//  Signup4ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup4ViewController: UIViewController, UITextFieldDelegate {
    
    var data: [String: String]?
    
    @IBOutlet weak var headerNextButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cmTextField: UITextField!
    @IBOutlet weak var feetTextField: UITextField!
    @IBOutlet weak var inchesTextField: UITextField!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    
    var cmActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup the UI
//        setupUI()
        
        // Hide error label
        errorLabel.isHidden = true
        
        // Disable buttons
        nextButton.isEnabled = false
        headerNextButton.isEnabled = false
        
        cmTextField.isHidden = true
        
        // event for when text changes
        setupChangeEvents()
        
        feetTextField.becomeFirstResponder()
        print(data!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func setupChangeEvents() {
        cmTextField.addTarget(self, action: #selector(Signup4ViewController.cmTextFieldDidChange), for: UIControlEvents.editingChanged)
        feetTextField.addTarget(self, action: #selector(Signup4ViewController.feetTextFieldDidChange), for: UIControlEvents.editingChanged)
        inchesTextField.addTarget(self, action: #selector(Signup4ViewController.inchesTextFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func setupUI() {
        // Add underline to inputs
        inputUnderline(textField: cmTextField)
        inputUnderline(textField: feetTextField)
        inputUnderline(textField: inchesTextField)
    }
    
    func inputUnderline(textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }
    
    func cmTextFieldDidChange() {
        validateCentimeters()
    }
    
    func feetTextFieldDidChange() {
        validateFeet()
    }
    
    func inchesTextFieldDidChange() {
        validateInches()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cmTextField.resignFirstResponder()
        feetTextField.resignFirstResponder()
        inchesTextField.resignFirstResponder()
    }
    
    func calcCMHeight(heightFeet: Int, heightInches: Int) -> Double{
        let totalInches = (heightFeet * 12) + heightInches
        
        let cm = Double(totalInches) * 2.54
        return cm
    }
    
    func showErrorAndDisableButtons() {
        errorLabel.isHidden = false
        
        // Disable next button
        nextButton.alpha = 0.5
        nextButton.isEnabled = false
        
        // Disable header next button
        headerNextButton.tintColor = UIColor.lightGray
        headerNextButton.isEnabled = false
    }
    
    func hideErrorAndEnableButtons() {
        errorLabel.isHidden = true
        
        // Enable next button
        nextButton.alpha = 1
        nextButton.isEnabled = true
        
        // Enable header button
        headerNextButton.tintColor = UIColor.white
        headerNextButton.isEnabled = true
    }
    
    func validateFeet() {
        // Min is 4 feet and max it 8
        if let feet = feetTextField.text {
            guard let feetValue = Int(feet) else {
                showErrorAndDisableButtons()
                return
            }
            
            if feetValue < 4 || feetValue > 8 {
                showErrorAndDisableButtons()
            } else {
                if let inches = inchesTextField.text {
                    if let inchesValue = Int(inches){
                        
                        if inchesValue >= 0 || feetValue <= 11 {
                            if feetValue >= 4 && feetValue <= 8{
                                hideErrorAndEnableButtons()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func validateInches() {
        
        if let inches = inchesTextField.text {
            // Inches can't be less than 0 or greater than 11
            guard let inchesValue = Int(inches) else {
                showErrorAndDisableButtons()
                return
            }
            if inchesValue < 0 || inchesValue > 11 {
                showErrorAndDisableButtons()
            } else {
                if let feet = feetTextField.text {
                    if let feetValue = Int(feet){
                        
                        if feetValue >= 4 && feetValue <= 8 {
                            hideErrorAndEnableButtons()
                        }
                    }
                }
            }
        }
    }
    
    func validateCentimeters() {
        // Min is 121.92 and max is 271.78
        if let cm = cmTextField.text {
            guard let centimeterValue = Double(cm) else {
                showErrorAndDisableButtons()
                return
            }
            
            if centimeterValue < 121.92 || centimeterValue > 271.78 {
                showErrorAndDisableButtons()
            } else {
                hideErrorAndEnableButtons()
            }
        }
    }
    
    @IBAction func unitChange(_ sender: UISegmentedControl) {
        switch unitSegmentedControl.selectedSegmentIndex{
            case 0:
                // Hide cm
                cmTextField.isHidden = true
                
                cmActivated = false
                
                // Show feet and inches
                feetTextField.isHidden = false
                inchesTextField.isHidden = false
            
                // Convert cm to feet and inches
                if let cm = cmTextField.text {
                    if cm != "" {
                        let centimeters = Double(cm)
                        let totalInches = Int(centimeters! / 2.54)
                        
                        let inches = Int(totalInches) % 12
                        let feet = (totalInches - inches) / 12
                        
                        feetTextField.text = "\(feet)"
                        inchesTextField.text = "\(inches)"
                    }
                }
            
                // resign first responder
                cmTextField.resignFirstResponder()
                
                // set first responder
                feetTextField.becomeFirstResponder()
            
            case 1:
                // Enable cm text field
                cmTextField.isHidden = false
                
                cmActivated = true
                
                // Convert feet and inches to cm
                if feetTextField.text != nil && inchesTextField.text != nil {
                    let feet = feetTextField.text,
                    inches = inchesTextField.text
                    
                    if feet != "" && inches != "" {
                        cmTextField.text = String(calcCMHeight(heightFeet: Int(feet!)!, heightInches: Int(inches!)!))
                    }
                }
                
                // Hide feet and inches
                feetTextField.isHidden = true
                inchesTextField.isHidden = true
            
                // resign first responder
                feetTextField.resignFirstResponder()
                inchesTextField.resignFirstResponder()
            
                // set first responder
                cmTextField.becomeFirstResponder()
            default:
                break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "step4ToStep5":
                if cmActivated {
                    data?["system_of_measurement"] = "Metric"
                    data?["height"] = cmTextField.text
                } else {
                    let feet = Int(feetTextField.text!)
                    let inches = Int(inchesTextField.text!)
                    data?["height"] = String(calcCMHeight(heightFeet: feet!, heightInches: inches!))
                }
                let signup5VC = segue.destination as! Signup5ViewController
                signup5VC.data = data
            default: break
            }
        }
    }

}
