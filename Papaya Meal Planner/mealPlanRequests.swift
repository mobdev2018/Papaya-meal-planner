//
//  mealPlan.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/2/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Alamofire

func getMealPlan(headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void){
    
    let baseUrl = "\(Config.baseURL)/api/meal_plans"
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}

func getMealPlanMeals(headers: HTTPHeaders, id: Int, completion: @escaping (_ result: DataResponse<Data>) -> Void){
    
    let baseUrl = "\(Config.baseURL)/api/meals/\(id)"
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
    
}

func getMealRecipes(headers: HTTPHeaders, id: Int, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    
    let baseUrl = "\(Config.baseURL)/api/recipes/\(id)"
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}

func getNutritionInfo(headers: HTTPHeaders, id: Int, type: String, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    var baseUrl: String!
    
    switch type {
    case "mealPlan":
        baseUrl = "\(Config.baseURL)/api/meal_plans/\(id)/nutrition_info"
    case "meal":
        baseUrl = "\(Config.baseURL)/api/meals/\(id)/nutrition_info"
    default:
        baseUrl = ""
    }
    
    Alamofire.request(baseUrl, method: .get, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}

func generateMealPlan(parameters: Parameters, headers: HTTPHeaders, completion: @escaping (_ result: DataResponse<Data>) -> Void) {
    
    let baseUrl = "\(Config.baseURL)/api/actions"
    
    Alamofire.request(baseUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: [200])
        .validate(contentType: ["application/json"])
        .responseData { response in
            completion(response)
    }
}
