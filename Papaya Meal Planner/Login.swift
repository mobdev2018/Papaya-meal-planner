//
//  login.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/2/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func socialAuth(email: String, socialToken: String, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    
    let baseUrl = "\(Config.baseURL)/api/auth/social"
    let parameters: Parameters = ["access_token": "\(socialToken)", "email": "\(email)"]
    
    Alamofire.request(baseUrl, method: .post, parameters: parameters)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}

func authenticateUser(email: String, password: String, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    // Setup request
    let baseUrl = "\(Config.baseURL)/api/auth"
    let parameters: Parameters = ["email": email, "password": password]
    
    Alamofire.request(baseUrl, method: .post, parameters: parameters)
        .validate(statusCode: [201])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
