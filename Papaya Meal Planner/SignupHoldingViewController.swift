//
//  SignupHoldingViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import EZLoadingActivity
import FBSDKLoginKit
import SwiftyJSON
import SwiftKeychainWrapper
import Alamofire

class SignupHoldingViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var data: [String: String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(data!)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar on the this view controller
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func loginFacebookButton(_ sender: UIButton) {
        // Facebook Login Manager
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) -> Void in
            // Check if facebook returns an error
            if (error == nil){
                if let response = result {
                    let fbLoginResult: FBSDKLoginManagerLoginResult = response
                    if (result?.isCancelled)! {
                        return
                    } else {
                        EZLoadingActivity.show("", disableUI: true)
                        if let permissions = fbLoginResult.grantedPermissions {
                            if(permissions.contains("email")){
                                // Get user's profile info
                                self.getFBProfile() { result in
                                    
                                    // Get json of Facebook data
                                    let json = JSON(result),
                                    email = json["email"].stringValue,
                                    accessToken = fbLoginResult.token.tokenString
                                    
                                    // authenticate the user
                                    socialAuth(email: email, socialToken: accessToken!) { response in
                                        
                                        // checks response and performs the necessary action
                                        self.checkResponse(response: response)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func getFBProfile(completion: @escaping (_ result: Any) -> Void) {
        let parameters = ["fields": "email, first_name, last_name"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { connection, result, error in
            
            if(error != nil){
                print(error!)
                return
            }
            
            completion(result!)
            
        })
    }
    
    func checkResponse(response: DataResponse<Data>) {
        switch response.result {
        case .success:
            guard let data = response.data else {
                // Show error if we don't have any data
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            // Set the auth token
            let json = JSON(data: data)
            let token = json["token"].stringValue
            KeychainWrapper.standard.set(token, forKey: "authToken")
            
            // Create User Settings
            createSettings() { response in
                self.createNewMealPlan()
            }
            
        case .failure:
            EZLoadingActivity.hide()
            let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func createSettings(completion: @escaping () -> ()){
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        for (name, value) in data! {
            let parameters: Parameters = ["name": name, "value": value]
            
            createUserSetting(parameters: parameters, headers: headers){ response in
                print(response.response!)
            }
        }
        completion()
    }
    
    func createNewMealPlan() {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        let parameters: Parameters = ["action_type": "create_meal_plan"]
        
        EZLoadingActivity.show("Cheffin' a new meal plan...", disableUI: true)
        
        generateMealPlan(parameters: parameters, headers: headers) { response in
            switch response.result {
            case .success:
                EZLoadingActivity.hide()
                
                // Go to meal plan page if successful
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                self.present(vc, animated: true, completion: nil)
                
            case .failure:
                EZLoadingActivity.hide()
                let alert = UIAlertController(title: "", message: "Network Error. Try Again. 6", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let signupEmailVC = segue.destination as! SignupEmailViewController
        signupEmailVC.data = data
    }
}
