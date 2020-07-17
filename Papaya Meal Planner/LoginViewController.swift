//
//  ViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 9/29/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import EZLoadingActivity
import FBSDKLoginKit
import SwiftyJSON
import SwiftKeychainWrapper
import Alamofire


class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Makes the username input active
        usernameField.becomeFirstResponder()
        
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width / 2 - 50;
        drawLine(x: 20, y: view.center.y, width: width, height: 0.5)
        drawLine(x: screenSize.width / 2 + 30, y: view.center.y, width: width, height: 0.5)
        
        padTextField(textField: usernameField)
        padTextField(textField: passwordField)
        
        addTextFieldBorder(textField: usernameField)
        addTextFieldBorder(textField: passwordField)
    }
    
 
    // MARK: Design Additions
    
    func drawLine(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        // Add a grey line with thickness 0.5, width 140 at location (20, y.center)
        let line = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        line.backgroundColor = UIColor(red: 225.0 / 250.0, green: 225.0/255.0, blue: 225.0 / 255.0, alpha: 1.0)
        self.view.addSubview(line)
    }
    
    func addTextFieldBorder(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor(red: 220.0 / 250.0, green: 220.0/255.0, blue: 220.0 / 255.0, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: view.frame.size.width, height: 0.3)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func padTextField(textField: UITextField) {
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 20, height: 30))
        textField.leftView = paddingView;
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    // MARK: Facebook API
    
    @IBAction func loginFacebook(_ sender: UIButton) {
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
            
            // Go to meal plan page if successful
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            self.present(vc, animated: true, completion: nil)
            
            // indicate user is logged in
            UserInfo.isLoggedIn = true
            
            EZLoadingActivity.hide(true, animated: true)
            
        case .failure:
            EZLoadingActivity.hide(false, animated: true)
            let alert = UIAlertController(title: "", message: "Invalid username or password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Login Button
    
    @IBAction func loginBtn(_ sender: AnyObject) {
        EZLoadingActivity.show("", disableUI: true)
        // Get username and pass
        let email = usernameField.text
        let password = passwordField.text
//        let email = "test@test.com"
//        let password = "test"
        
        authenticateUser(email: email!, password: password!){
//        authenticateUser(email: email, password: password){
            response in
            // checks response and performs the necessary action
            self.checkResponse(response: response)
        }
        
        
        
        // for test
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
//        self.present(vc, animated: true, completion: nil)
        
        // indicate user is logged in
        UserInfo.isLoggedIn = true
        
        EZLoadingActivity.hide(true, animated: true)
    }

}

