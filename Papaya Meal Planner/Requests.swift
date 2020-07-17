//
//  requests.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 2/1/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func savePushToken(parameters: Parameters, headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    
    let baseUrl = "\(Config.baseURL)/api/devices"
    
    Alamofire.request(baseUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: [201])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
