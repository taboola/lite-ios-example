import UIKit
import TaboolaLite

class NewsViewController: UIViewController, UITabBarControllerDelegate, OnTBLNewsListener, OnTBLListener {
    func onTaboolaNewsRefreshComplete(statusCode: TaboolaLite.TBLStatusCode) {
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
    
    func onTaboolaNewsSetupComplete(statusCode: TaboolaLite.TBLStatusCode) {
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let finalPublisherId = "lineplus-us-ios"
        let userData = TBLUserData(hashedEmail: "hashedEmail", gender: "gender", age: "age", userInterestAndIntent: "userInterestAndIntent")
        TBLSDK.shared.initialize(publisherId: finalPublisherId, data: userData, onTaboolaListener: self)
        if let tabBarController = self.tabBarController {
            tabBarController.delegate = self
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }

    override var shouldAutorotate: Bool {
        return false
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        setupUI()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Check which tab was selected and if it's the same as current tab
        if let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController),
           selectedIndex == 2,
           tabBarController.selectedIndex == 2 {  // Check if we're already in this tab
            TBLSDK.shared.onScrollToTopTaboolaNews()
        }
    }
    
    deinit {
        TBLSDK.shared.removeTaboolaNewsFromView()
    }
    
    private func setupUI() {
        title = "News"
        TBLSDK.shared.setupTaboolaNews(view: view, onTBLNewsListener: self)
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
            setupUI()
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
            if let topVC = self {
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

}
