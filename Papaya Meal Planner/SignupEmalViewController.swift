//
//  SignupEmailViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/19/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON
import EZLoadingActivity

class SignupEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var data: [String: String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show navigation bar on this page
        self.navigationController?.isNavigationBarHidden = false
        
        // change navigation colors
        self.navigationController?.navigationBar.tintColor = UIColor.lightGray
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // Hide navigation bar underline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // add action to signup button
        signUpButton.addTarget(self, action: #selector(onSignUpButton), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        retypePasswordTextField.resignFirstResponder()
    }
    
    func onSignUpButton() {
        // Disable when user clicks on to it
        signUpButton.isEnabled = false
        
        guard let emailText = emailTextField.text, let passwordText = passwordTextField.text, let retypedPasswordText = retypePasswordTextField.text else {
            
            let alert = UIAlertController(title: "", message: "One or more of the following fields is missing. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // enable signup button
            signUpButton.isEnabled = true
            
            return
        }
        
        if passwordText != retypedPasswordText {
            let alert = UIAlertController(title: "", message: "The passwords you entered don't match. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // enable signup button
            signUpButton.isEnabled = true
            
            return
        }
        
        let validatedEmail = isValidEmail(email: emailText)
        
        if !validatedEmail {
            let alert = UIAlertController(title: "", message: "please enter a valid email.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // enable signup button
            signUpButton.isEnabled = true
            
            return
        }
        
        let email = emailText
        let password = passwordText
        
        let parameters: Parameters = ["email": email, "password": password]
        
        signupUser(parameters: parameters) { response in
            switch response.result {
            case .success:
                
                self.loginUser()
                
            case .failure:
                if let response = response.response {
                    let code = response.statusCode
                    
                    switch code {
                    case 409:
                        let alert = UIAlertController(title: "", message: "A user with this email already exists.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        let alert = UIAlertController(title: "", message: "Network Error 1. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
                // enable signup button
                self.signUpButton.isEnabled = true
                
                EZLoadingActivity.hide()
            }
        }
    }
    
    func isValidEmail(email :String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
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
                print("I got here")
                self.createNewMealPlan()
            }
            
        case .failure:
            EZLoadingActivity.hide()
            let alert = UIAlertController(title: "Invalid Login Information", message: "Please check your email or password", preferredStyle: UIAlertControllerStyle.alert)
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
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loginUser() {
        // Get username and pass
        let email = emailTextField.text
        let password = passwordTextField.text
        
        authenticateUser(email: email!, password: password!){
            response in
            // checks response and performs the necessary action
            self.checkResponse(response: response)
        }
    }
}

