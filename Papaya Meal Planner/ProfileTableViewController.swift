//
//  ProfileTableViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 2/3/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var btnSun: UIButton!
    @IBOutlet weak var btnMon: UIButton!
    @IBOutlet weak var btnTue: UIButton!
    @IBOutlet weak var btnWed: UIButton!
    @IBOutlet weak var btnThu: UIButton!
    @IBOutlet weak var btnFri: UIButton!
    @IBOutlet weak var btnSat: UIButton!
    
    
    @IBOutlet weak var btnPlan: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        
        
        let screenSize = UIScreen.main.bounds.size
        
        //self.lblName =
        
        
        // Days buttons
        let daybuttonWidth = (screenSize.width - 48) / 7.0
        self.btnSun.layer.cornerRadius = daybuttonWidth / 2.0
        self.btnMon.layer.cornerRadius = daybuttonWidth / 2.0
        self.btnTue.layer.cornerRadius = daybuttonWidth / 2.0
        self.btnWed.layer.cornerRadius = daybuttonWidth / 2.0
        self.btnThu.layer.cornerRadius = daybuttonWidth / 2.0
        self.btnFri.layer.cornerRadius = daybuttonWidth / 2.0
        self.btnSat.layer.cornerRadius = daybuttonWidth / 2.0
        
        let pinkColor = UIColor.init(colorLiteralRed: 228/255.0, green: 63/255.0, blue: 108/255.0, alpha: 1)
        self.btnSun.backgroundColor = UIColor.clear
        self.btnMon.backgroundColor = UIColor.clear
        self.btnTue.backgroundColor = UIColor.clear
        self.btnWed.backgroundColor = UIColor.clear
        self.btnThu.backgroundColor = UIColor.clear
        self.btnFri.backgroundColor = UIColor.clear
        self.btnSat.backgroundColor = pinkColor
        
        self.btnPlan.layer.cornerRadius = 45 / 2.0
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.imgAvatar.layer.borderColor = UIColor.white.cgColor
        self.imgAvatar.layer.borderWidth = 2.0
        self.imgAvatar.layer.cornerRadius = CGFloat(95 * 0.5)
        self.imgAvatar.layoutIfNeeded()
        
        // blurred overlay
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = self.imgLogo.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.imgLogo.addSubview(blurEffectView)
        }
    }
    
   
    // Mark: - button events
    @IBAction func onSun(_ sender: Any) {
        self.onDay(selectedIndex: 0)
    }
    
    @IBAction func onMon(_ sender: Any) {
        self.onDay(selectedIndex: 1)
    }
    
    @IBAction func onTue(_ sender: Any) {
        self.onDay(selectedIndex: 2)
    }
    
    @IBAction func onWed(_ sender: Any) {
        self.onDay(selectedIndex: 3)
    }
    
    @IBAction func onThu(_ sender: Any) {
        self.onDay(selectedIndex: 4)
    }
    
    @IBAction func onFri(_ sender: Any) {
        self.onDay(selectedIndex: 5)
    }
    
    @IBAction func onSat(_ sender: Any) {
        self.onDay(selectedIndex: 6)
        
    }
    
    
    func onDay(selectedIndex: Int) {
        let pinkColor = UIColor.init(colorLiteralRed: 228/255.0, green: 63/255.0, blue: 108/255.0, alpha: 1)
        
        self.btnSun.backgroundColor = UIColor.clear
        self.btnMon.backgroundColor = UIColor.clear
        self.btnTue.backgroundColor = UIColor.clear
        self.btnWed.backgroundColor = UIColor.clear
        self.btnThu.backgroundColor = UIColor.clear
        self.btnFri.backgroundColor = UIColor.clear
        self.btnSat.backgroundColor = UIColor.clear
        
        self.btnSun.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.btnMon.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.btnTue.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.btnWed.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.btnThu.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.btnFri.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.btnSat.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        switch selectedIndex {
        case 0:
            self.btnSun.backgroundColor = pinkColor
            self.btnSun .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        case 1:
            self.btnMon.backgroundColor = pinkColor
            self.btnMon .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        case 2:
            self.btnTue.backgroundColor = pinkColor
            self.btnTue .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        case 3:
            self.btnWed.backgroundColor = pinkColor
            self.btnWed .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        case 4:
            self.btnThu.backgroundColor = pinkColor
            self.btnThu .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        case 5:
            self.btnFri.backgroundColor = pinkColor
            self.btnFri .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        case 6:
            self.btnSat.backgroundColor = pinkColor
            self.btnSat .setTitleColor(UIColor.white, for: UIControlState.normal)
            break
        default:
            break
        }
        
        
    }
    
    @IBAction func onPlan(_ sender: Any) {
        
        
    }
    
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 0.0
        if section == 0 || section == 1 {
            height = 0.0
        } else
        {
            height = 30.0
        }
        
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let section = indexPath.section
        
        switch section {
        case 1:
            switch row {
            case 0:
                break
            default:
                break
            }
            
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
        
    }

}
