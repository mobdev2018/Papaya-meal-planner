//
//  grocery.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/2/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func getGroceryItems (headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    // Get grocery items
    let baseUrl = "\(Config.baseURL)/api/shopping_items"
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
