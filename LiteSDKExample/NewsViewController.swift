import UIKit
import TaboolaLite

class NewsViewController: UIViewController, UITabBarControllerDelegate, OnTBLNewsListener {
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
        setupUI()
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

}
