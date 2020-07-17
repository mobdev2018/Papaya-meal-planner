//
//  Settings.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/1/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func logoutUser(headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Any>) -> Void) {
    // Setup request
    let baseUrl = "\(Config.baseURL)/api/auth"
    
    Alamofire.request(baseUrl, method: .delete, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            completion(response)
    }
}

func getUserSettings (headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    // Get grocery items
    let baseUrl = "\(Config.baseURL)/me/settings"
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
