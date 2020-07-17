//
//  Signup.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/19/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func signupUser(parameters: Parameters, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    // Setup request
    let baseUrl = "\(Config.baseURL)/api/users"
    
    Alamofire.request(baseUrl, method: .post, parameters: parameters)
        .validate(statusCode: [201])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}

func createUserSetting(parameters: Parameters, headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Any>) -> Void) {
    let urlString = "\(Config.baseURL)/me/settings"
    
    Alamofire.request(urlString, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: [201])
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            completion(response)
    }
}
