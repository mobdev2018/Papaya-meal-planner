//
//  Signup2ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup2ViewController: UIViewController {
    
    var data: [String: String]?
    
    @IBOutlet weak var loseWeightView: UIView!
    @IBOutlet weak var gainMuscleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIViewShadow(view: loseWeightView)
        UIViewShadow(view: gainMuscleView)
        
        // Change view background color
        view.backgroundColor = UIColor(red: 254.0 / 255, green: 250.0 / 255, blue: 252.0 / 255, alpha: 1)
        print(data!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func UIViewShadow(view: UIView){
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2
    }
    
    @IBAction func loseWeightSelect(_ sender: AnyObject) {
        data?["weekly_weight_goal"] = "-1"
    }
    
    @IBAction func maintainWeightSelect(_ sender: UIButton) {
        data?["weekly_weight_goal"] = "0"
    }
    
    @IBAction func gainMuscleSelect(_ sender: UIButton) {
        data?["weekly_weight_goal"] = "1"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "loseWeightToStep3":
                let signup3VC = segue.destination as! Signup3ViewController
                signup3VC.data = data
            case "gainMuscleToStep3":
                let signup3VC = segue.destination as! Signup3ViewController
                signup3VC.data = data
            default: break
            }
        }
    }

}
