import UIKit
import TaboolaLite

class NewsViewController: UIViewController, OnTaboolaNewsListener, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabBarController = self.tabBarController {
                    tabBarController.delegate = self
                }
        setupUI()
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            // Check which tab was selected
            if let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) ,selectedIndex == 2 {
                    TBLSDK.shared.onScrollToTopTaboolaNews()
            }
        }
    
    deinit {
        TBLSDK.shared.removeTaboolaNewsFromView()
        TBLSDK.shared.removeOnTaboolaNewsListener()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
                title = "News"
        TBLSDK.shared.addTaboolaNewsToView(view)
        TBLSDK.shared.setOnTaboolaNewsListener(self)
    }
    
    func onTaboolaNewsFailed(statusCode: TBLStatusCode) {
        // Create and configure alert controller
        let alertController = UIAlertController(
            title: statusCode.message,
            message: "Unable to load content. Error code: \(statusCode)",
            preferredStyle: .alert
        )
        
        // Add action button
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        // Present the alert
        DispatchQueue.main.async {
            self.presentFromTopViewController(alertController)
        }
    }

    func onTaboolaNewsSharePressed(url: String) {
        // Create activity view controller with the URL to share
        guard let urlToShare = URL(string: url) else {
            print("Invalid URL for sharing")
            return
        }
        
        let activityItems: [Any] = [urlToShare]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Exclude certain activity types if needed
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks
        ]
        
        // Present the activity view controller
        DispatchQueue.main.async {
            if let topVC = self.getTopViewController() {
                // For iPad, set the popover presentation controller
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = topVC.view
                    popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                topVC.present(activityViewController, animated: true)
            }
        }
    }

    // Helper method to get the top view controller
    private func getTopViewController() -> UIViewController? {
        // Get the active window using the appropriate API based on iOS version
        let keyWindow = getKeyWindow()
        
        if let rootViewController = keyWindow?.rootViewController {
            var topController = rootViewController
            while let presentedVC = topController.presentedViewController {
                topController = presentedVC
            }
            return topController
        }
        
        return nil
    }

    // Helper method to get the key window using the appropriate API based on iOS version
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            // iOS 15+ approach
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first(where: { $0.isKeyWindow })
        } else {
            let scenes = UIApplication.shared.connectedScenes
            let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
            
            for windowScene in windowScenes {
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        return window
                    }
                }
            }
            
            // Fallback to first window in first scene
            if let windowScene = windowScenes.first {
                return windowScene.windows.first
            }
        }
        
        return nil
    }

    // Helper method to present a view controller from the top view controller
    private func presentFromTopViewController(_ viewControllerToPresent: UIViewController) {
        if let topVC = getTopViewController() {
            topVC.present(viewControllerToPresent, animated: true)
        }
    }
}
