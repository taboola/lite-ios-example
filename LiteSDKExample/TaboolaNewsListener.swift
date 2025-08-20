import Foundation
import UIKit
import TaboolaLite

/**
 * Default implementation of OnTaboolaNewsListener that provides common UI behaviors
 * for error handling and sharing functionality.
 */
public class TaboolaNewsListener: OnTBLListener, OnTBLNewsListener {
    
    private let parentView: UIView
    
    public init(parentView: UIView) {
        self.parentView = parentView
    }
    
    public func onTaboolaLoadComplete(statusCode: TBLStatusCode) {
        if statusCode == TBLStatusCode.success {
            self.showAlert(
                title: "Success",
                message: "Taboola content loaded successfully"
            )
        } else {
            self.showAlert(
                title: "Load Failed",
                message: "Taboola content load failed: \(statusCode.message)"
            )
        }
    }
    
    
    
    public func onTaboolaInitializationComplete(statusCode: TBLStatusCode) {
        if statusCode == TBLStatusCode.success {
            TBLSDK.shared.setupTaboolaNews(view: self.parentView, onTBLNewsListener: self)
            self.showAlert(
                title: "Success",
                message: "Taboola initialization completed successfully"
            )
        } else {
            self.showAlert(
                title: "Initialization Failed",
                message: "Taboola initialization failed: \(statusCode.message)"
            )
        }
    }

    public func onTaboolaSharePressed(url: String) {
        // Create activity view controller with the URL to share
        guard let urlToShare = URL(string: url) else {
            print("Invalid URL for sharing: \(url)")
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
        DispatchQueue.main.async { [weak self] in
            if let topVC = self?.getTopViewController() {
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
    
    public func onTaboolaNewsRefreshComplete(statusCode: TaboolaLite.TBLStatusCode) {
        if statusCode == TBLStatusCode.success {
            self.showAlert(
                title: "Success",
                message: "Taboola news refresh completed successfully"
            )
        } else {
            self.showAlert(
                title: "Setup Failed",
                message: "Taboola news refresh failed: \(statusCode.message)"
            )
        }
    }
    
    public func onTaboolaNewsSetupComplete(statusCode: TaboolaLite.TBLStatusCode) {
        DispatchQueue.main.async { [weak self] in
            if statusCode == TBLStatusCode.success {
                self?.showAlert(
                    title: "Success",
                    message: "Taboola news setup completed successfully"
                )
            } else {
                self?.showAlert(
                    title: "Setup Failed",
                    message: "Taboola news setup failed: \(statusCode.message)"
                )
            }
        }
    }
    
    public func onTaboolaNewsClickComplete(statusCode: TBLStatusCode) {
        if statusCode == TBLStatusCode.success {
//            self.showAlert(
//                title: "Success",
//                message: "Taboola news click completed successfully"
//            )
        } else {
            self.showAlert(
                title: "Click Failed",
                message: "Taboola news click failed: \(statusCode.message)"
                )
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presentFromTopViewController(alert)
    }
    
    private func presentFromTopViewController(_ viewController: UIViewController) {
        if let topVC = getTopViewController() {
            topVC.present(viewController, animated: true)
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topViewController = window.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        if let navigationController = topViewController as? UINavigationController {
            topViewController = navigationController.visibleViewController
        }
        
        if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        
        return topViewController
    }
} 
