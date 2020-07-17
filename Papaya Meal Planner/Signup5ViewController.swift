//
//  Signup5ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup5ViewController: UIViewController, UITextFieldDelegate {
    
    var data: [String: String]?
    
    @IBOutlet weak var headerNextButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var kgTextField: UITextField!
    @IBOutlet weak var poundTextField: UITextField!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    
    var kgActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide Error Lsbel
        errorLabel.isHidden = true
        
        kgTextField.isHidden = true
        
        // Disable buttons
        nextButton.isEnabled = false
        headerNextButton.isEnabled = false
        
        // event for when text changes
        setupChangeEvents()
        
        poundTextField.becomeFirstResponder()
        print(data!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func setupChangeEvents() {
        kgTextField.addTarget(self, action: #selector(Signup5ViewController.kgTextFieldDidChange), for: UIControlEvents.editingChanged)
        poundTextField.addTarget(self, action: #selector(Signup5ViewController.poundTextFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func kgTextFieldDidChange() {
        validateKg()
    }
    
    func poundTextFieldDidChange() {
        validatePounds()
    }
    
    func calcKgWeight(weight: Int) -> Double{
        
        let kg = Double(weight) * 0.4536
        return kg
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
    
    func validatePounds() {
        if let pound = poundTextField.text {
            if let poundValue = Int(pound) {
                // pound can't be less than 45 or greater than 660
                if poundValue < 45 || poundValue > 660 {
                    showErrorAndDisableButtons()
                } else {
                    hideErrorAndEnableButtons()
                }
            }
        }
        
    }
    
    func validateKg() {
        // Min is 20 kg and max it 299
        if let kg = kgTextField.text {
            guard let kgValue = Int(kg) else {
                showErrorAndDisableButtons()
                return
            }
            
            if kgValue < 20 || kgValue > 299 {
                showErrorAndDisableButtons()
            } else {
                hideErrorAndEnableButtons()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        poundTextField.resignFirstResponder()
        kgTextField.resignFirstResponder()
    }
    
    @IBAction func unitChanged(_ sender: UISegmentedControl) {
        switch unitSegmentedControl.selectedSegmentIndex{
        case 0:
            kgTextField.isHidden = true
            
            kgActivated = false
            
            // Convert kg to lbs
            if let kg = kgTextField.text {
                if kg != "" {
                    let kilograms = Double(kg)
                    let weight = Int(kilograms! / 0.4536)
                    poundTextField.text = "\(weight)"
                }
            }
            
            poundTextField.isHidden = false
            
            // resign first responder
            kgTextField.resignFirstResponder()
            
            // set first responder
            poundTextField.becomeFirstResponder()
        case 1:
            kgTextField.isHidden = false
            
            kgActivated = true
            
            // Convert lbs to kg
            if let pounds = poundTextField.text {
                if pounds != "" {
                    let kilograms = calcKgWeight(weight: Int(pounds)!)
                    kgTextField.text = "\(kilograms)"
                }
            }
            
            poundTextField.isHidden = true
            
            // resign first responder
            poundTextField.resignFirstResponder()
            
            // set first responder
            kgTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "step5ToStep6":
                if kgActivated {
                    data?["weight"] = kgTextField.text
                } else {
                    let pound = Int(poundTextField.text!)
                    data?["weight"] = String(calcKgWeight(weight: pound!))
                }
                let signup6VC = segue.destination as! Signup6ViewController
                signup6VC.data = data
            default: break
            }
        }
    }

}
