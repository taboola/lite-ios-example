import UIKit
import TaboolaLite

class NewsViewController: UIViewController, UITabBarControllerDelegate {
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let finalPublisherId = "lineplus-us-ios"
        let userData = TBLUserData(hashedEmail: "hashedEmail")
        TBLSDK.shared.initialize(publisherId: finalPublisherId, data: userData, onTaboolaListener: TaboolaNewsListener(parentView: view))
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

}
