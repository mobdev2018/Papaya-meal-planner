//
//  Config.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/8/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import Foundation

func env<T>(dev development: T, stg staging: T, prod production:T) -> T {
    var v: T!
    
    #if ENVIRONMENT_DEVELOPMENT
        v = development
    #elseif ENVIRONMENT_STAGING
        v = staging
    #else // Live
        v = production
    #endif
    
    return v
}


struct Config {
    static let flurryAPIKey = env(dev: "",
                                  stg: "",
                                  prod: "S56XSD96JHSJHZFJKHN4")
    static let baseURL = env(dev: "http://localhost:8080/api",
                             stg: "https://staging.mypapaya.io/api",
                             prod: "https://data.mypapaya.io/api")
    
}
