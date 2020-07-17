//
//  Signup1ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class Signup1ViewController: UIViewController {
    
    var data: [String: String]?
    
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var femalView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        data = [String: String]()
        data?["shopping_list_days"] = "7"
        data?["system_of_measurement"] = "US"
        
        UIViewShadow(view: maleView)
        UIViewShadow(view: femalView)
        
        // Change view background color
        view.backgroundColor = UIColor(red: 254.0 / 255, green: 250.0 / 255, blue: 252.0 / 255, alpha: 1)
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
    
    @IBAction func maleSelectButton(_ sender: UIButton) {
        data?["gender"] = "M"
    }
    
    @IBAction func femaleSelectButton(_ sender: AnyObject) {
        data?["gender"] = "F"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "step1ToStep2":
                let signup2VC = segue.destination as! Signup2ViewController
                signup2VC.data = data
            case "step1ToSetp2Female":
                let signup2VC = segue.destination as! Signup2ViewController
                signup2VC.data = data
            default: break
            }
        }
    }

}
