//
//  UserInfo.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/3/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import Foundation

final class UserInfo {
    static var pushToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "pushToken")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "pushToken")
            UserDefaults.standard.synchronize()
        }
    }
    static var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.string(forKey: "logInfo") == "login" ? true : false
        }
        set {
            if newValue {
                UserDefaults.standard.setValue("login", forKey: "logInfo")
                // for future use - will remove "logInfo" key
                UserDefaults.standard.set(newValue, forKey: "loggedIn")
            } else {
                UserDefaults.standard.setValue("logout", forKey: "logInfo")
                // for future use - will remove "logInfo" key
                UserDefaults.standard.set(newValue, forKey: "loggedIn")
            }
            
            UserDefaults.standard.synchronize()
        }
    }
}
