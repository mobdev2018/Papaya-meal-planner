//
//  Signup7ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup7ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var numMealsTextField: UITextField!
    
    var data: [String: String]?
    var options = ["4", "5", "6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPicker()
        
        print(data!)
    }
    
    func createPicker() {
        let picker: UIPickerView
        picker = UIPickerView()
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
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
        
        numMealsTextField.inputView = picker
        numMealsTextField.inputAccessoryView = toolBar
    }
    
    func donePicker (sender:UIBarButtonItem) {
        numMealsTextField.resignFirstResponder()
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numMealsTextField.text = options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
//    @IBAction func goToNextPage(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "SignupHoldingController")
//        self.present(vc, animated: true, completion: nil)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let meals = numMealsTextField.text
        data?["number_of_meals"] = meals
        let signupHoldingVC = segue.destination as! SignupHoldingViewController
        signupHoldingVC.data = data
    }

}
