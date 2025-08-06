//
//  SceneDelegate.swift
//  LiteSDKExample
//
//  Created by Tzufit Chen Lifshitz on 13/03/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window with the correct scene
        let window = UIWindow(windowScene: windowScene)
        
        // Set the root view controller
        let tabBarController = MainTabBarController()
        window.rootViewController = tabBarController
        
        // Make the window visible
        window.makeKeyAndVisible()
        self.window = window
        
        print("Scene delegate configured window with TabBarController")
        
        // Handle deeplinks when app is launched from a URL
        if let urlContext = connectionOptions.urlContexts.first {
            handleDeeplink(url: urlContext.url)
        }
    }
    
    // MARK: URL Handling for iOS 13+ (scene-based apps)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            handleDeeplink(url: urlContext.url)
        }
    }
    
    private func handleDeeplink(url: URL) {
        print("Scene handling deeplink: \(url.absoluteString)")
        
        // Handle line:// URLs
        if url.scheme == "line" {
            switch url.host {
            case "nv":
                if url.path == "/newsRow" {
                    // Navigate to news tab and potentially scroll to a specific item
                    navigateToNewsTab()
                }
            default:
                print("Unhandled line deeplink: \(url.absoluteString)")
            }
        }
    }
    
    private func navigateToNewsTab() {
        DispatchQueue.main.async { [weak self] in
            // Navigate to the news tab
            if let tabBarController = self?.window?.rootViewController as? UITabBarController {
                // Navigate to the news tab (index 2 based on the tab structure)
                tabBarController.selectedIndex = 2
                print("Navigated to news tab via deeplink")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

