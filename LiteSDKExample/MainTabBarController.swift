import UIKit

class CustomNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return topViewController?.supportedInterfaceOrientations ?? .all
        }

        override var shouldAutorotate: Bool {
            return topViewController?.shouldAutorotate ?? true
        }

        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
        }
}


class MainTabBarController: UITabBarController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return selectedViewController?.supportedInterfaceOrientations ?? .all
        }

        override var shouldAutorotate: Bool {
            return selectedViewController?.shouldAutorotate ?? true
        }

        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            return selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        // Create view controllers
        let homeVC = HomeViewController()
        let messagesVC = MessagesViewController()
        let newsVC = NewsViewController()
        let gamesVC = GamesViewController()
        
        // Wrap in navigation controllers
        let homeNav = CustomNavigationController(rootViewController: homeVC)
        let messagesNav = CustomNavigationController(rootViewController: messagesVC)
        let newsNav = CustomNavigationController(rootViewController: newsVC)
        newsNav.setNavigationBarHidden(true, animated: false)
        let gamesNav = CustomNavigationController(rootViewController: gamesVC)
        
        // Set tab bar items
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        messagesNav.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message"), tag: 1)
        newsNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 2)
        gamesNav.tabBarItem = UITabBarItem(title: "Games", image: UIImage(systemName: "gamecontroller"), tag: 3)
        
        // Set view controllers
        viewControllers = [homeNav, messagesNav, newsNav, gamesNav]
        
        // Set initial tab
        selectedIndex = 0
    }
} 
