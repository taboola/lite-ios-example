import UIKit

class MainTabBarController: UITabBarController {
    
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
        let homeNav = UINavigationController(rootViewController: homeVC)
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        let newsNav = UINavigationController(rootViewController: newsVC)
        newsNav.setNavigationBarHidden(true, animated: false)
        let gamesNav = UINavigationController(rootViewController: gamesVC)
        
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
