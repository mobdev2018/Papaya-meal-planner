//
//  AppDelegate.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 9/29/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import UserNotifications
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Flurry Analytics
        Flurry.startSession(Config.flurryAPIKey);
        
        // Setup Push Notifications
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        
        // Change status bar to light content
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Navigation Bar appearannce
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationBarAppearace.barTintColor = UIColor(red: 203.0 / 255.0, green: 24.0/255.0, blue: 75.0 / 255.0, alpha: 1.0)
        
        // Add page controller to home page
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.init(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.6)
        pageController.currentPageIndicatorTintColor = UIColor.init(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.2)
        pageController.backgroundColor = UIColor.clear
        
        // Auto login user
//        if UserInfo.isLoggedIn {
//            // user is logged in - go to Feed
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
//            window?.rootViewController = vc
//        } else {
//            // user is not logged in - show onboarding
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            window?.rootViewController = storyboard.instantiateInitialViewController()
//        }
        
         return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        
        // Add pushToken to user defaults
        UserInfo.pushToken = deviceTokenString
        print(deviceTokenString)
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Do something here when user gets an error
//        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Do something here when the notification is recieved
//        print("Push notification received: \(data)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

