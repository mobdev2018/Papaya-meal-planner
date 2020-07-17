//
//  UserActions.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/29/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func contentAction(contentId: Int, parameters: Parameters, headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    
    let baseUrl = "\(Config.baseURL)/api/contents/\(contentId)/actions"
    
    Alamofire.request(baseUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
