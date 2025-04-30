//
//  AppDelegate.swift
//  LiteSDKExample
//
//  Created by Tzufit Chen Lifshitz on 13/03/2025.
//

import UIKit
import TaboolaLite

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let userData = TBLUserData(hashedEmail: "hashedEmail", gender: "gender", age: "age", userInterestAndIntent: "userInterestAndIntent")
        TBLSDK.shared.initialize(publisherId: "lineplus-us-ios", data: userData)
        return true
    }
    
    // Called when app is about to terminate
    func applicationWillTerminate(_ application: UIApplication) {
        TBLSDK.shared.deinitialize()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

