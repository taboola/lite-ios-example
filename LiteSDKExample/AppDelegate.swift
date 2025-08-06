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
        
        return true
    }
    
    // Called when app is about to terminate
    func applicationWillTerminate(_ application: UIApplication) {
        TBLSDK.shared.deinitialize()
    }
    
    // MARK: URL Handling for iOS versions before 13.0 (when app doesn't support scenes)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return handleDeeplink(url: url)
    }
    
    private func handleDeeplink(url: URL) -> Bool {
        print("Handling deeplink: \(url.absoluteString)")
        
        // Handle line:// URLs
        if url.scheme == "line" {
            switch url.host {
            case "nv":
                if url.path == "/newsRow" {
                    // Navigate to news tab and potentially scroll to a specific item
                    navigateToNewsTab()
                    return true
                }
            default:
                print("Unhandled line deeplink: \(url.absoluteString)")
            }
        }
        
        return false
    }
    
    private func navigateToNewsTab() {
        DispatchQueue.main.async {
            // Get the main window and navigate to news tab
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                // Navigate to the news tab (index 2 based on the tab structure)
                tabBarController.selectedIndex = 2
                print("Navigated to news tab via deeplink")
                print("testttt")
            }
        }
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

