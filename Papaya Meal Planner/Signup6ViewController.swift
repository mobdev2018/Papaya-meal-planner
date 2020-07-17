//
//  Signup6ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup6ViewController: UIViewController {

    var data: [String: String]?
    
    let activity = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extra Active"]
    let activityValue = ["Sendentary": "1.2", "Lightly Active": "1.375", "Moderately Active": "1.55", "Very Active": "1.725", "Extra Active": "1.9"]
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedActivity = Int(slider.value)
        activityLabel.text = activity[selectedActivity]
        print(data!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    @IBAction func activitySliderChanged(_ sender: UISlider) {
        let step: Float = 1.0
        let roundedValue = round(sender.value / step) * step

        sender.value = roundedValue
        let selectedActivity = Int(sender.value)
        activityLabel.text = activity[selectedActivity]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "step6ToStep7":
                let activityLevel = activityValue[activityLabel.text!]
                data?["activity_level"] = activityLevel
                let signup7VC = segue.destination as! Signup7ViewController
                signup7VC.data = data
            default: break
            }
        }
    }

}
