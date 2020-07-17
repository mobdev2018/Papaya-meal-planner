//
//  SettingsTableViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/29/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
    }
    
    func deleteSession() {
        // Get api token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)"]
        
        logoutUser(headers: headers) { response in
            
            if response.result.isFailure {
                let alert = UIAlertController(title: "Network Error", message: "Please check your network and try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add number of rows based on section
        var rows = 0
        
        switch section {
        case 0:
            rows = 2
        case 1:
            rows = 1
        default:
            rows = 0
        }
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselct tableview row
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            self.deleteSession()
            KeychainWrapper.standard.removeObject(forKey: "authToken")
            UserInfo.isLoggedIn = false
        }
    }

}
