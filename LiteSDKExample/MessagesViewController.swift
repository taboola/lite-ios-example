import UIKit
import TaboolaLite

class MessagesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Messages"
        
        let label = UILabel()
        label.text = "Messages Screen"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let openCTBButton = UIButton(type: .system)
        openCTBButton.setTitle("Open CTB", for: .normal)
        openCTBButton.translatesAutoresizingMaskIntoConstraints = false
        openCTBButton.addTarget(self, action: #selector(openCTBButtonTapped), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(openCTBButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            openCTBButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openCTBButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }
    
    @objc private func openCTBButtonTapped() {
        TBLSDK.shared.onClickedTaboolaItem(url:"https://nova.taboolanews.com/new-summary-page/7208118686570174366?utm_source=taboola&utm_medium=taboola_news&dc_data=4384118_lineplus-us-android&origin_referral_type=gam",viewController: self)
    }
} 
