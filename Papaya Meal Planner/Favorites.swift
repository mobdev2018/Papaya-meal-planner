//
//  Favorites.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/19/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import Alamofire

func getFavorites (headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    // Get grocery items
    let baseUrl = "\(Config.baseURL)/me/favorite_recipes"
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}

func deleteFavoriteRecipe (id: Int, headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    // Get grocery items
    let baseUrl = "\(Config.baseURL)/me/favorite_recipes/\(id)"
    
    Alamofire.request(baseUrl, method: .delete, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: [204])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
