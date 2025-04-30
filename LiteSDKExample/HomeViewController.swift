import UIKit
import TaboolaLite

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var logLevelSegmentedControl: UISegmentedControl = {
        let items = ["Debug", "Info", "Warning", "Error"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0 // Debug by default
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var reloadTimeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter reload time (minutes)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var intervalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter interval"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Configuration", for: .normal)
        button.addTarget(self, action: #selector(applyConfiguration), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Set initial configuration
        TBLSDK.shared.setLogLevel(.debug)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add labels
        let logLevelLabel = UILabel()
        logLevelLabel.text = "Log Level"
        logLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let reloadTimeLabel = UILabel()
        reloadTimeLabel.text = "Reload Time (minutes)"
        reloadTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let intervalLabel = UILabel()
        intervalLabel.text = "Timer Repeat Interval"
        intervalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add components to stack view
        stackView.addArrangedSubview(logLevelLabel)
        stackView.addArrangedSubview(logLevelSegmentedControl)
        stackView.addArrangedSubview(reloadTimeLabel)
        stackView.addArrangedSubview(reloadTimeTextField)
        stackView.addArrangedSubview(intervalLabel)
        stackView.addArrangedSubview(intervalTextField)
        stackView.addArrangedSubview(applyButton)
        
        view.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func applyConfiguration() {
        // Get log level based on selected segment
        let logLevel: TBLLogLevel
        switch logLevelSegmentedControl.selectedSegmentIndex {
        case 0:
            logLevel = .debug
        case 1:
            logLevel = .info
        case 2:
            logLevel = .warn
        case 3:
            logLevel = .error
        default:
            logLevel = .debug
        }
        
        // Apply log level
        TBLSDK.shared.setLogLevel(logLevel)
        
        // Get and validate reload intervals
        let reloadTime = Int(reloadTimeTextField.text ?? "") ?? 1
        let interval = Int(intervalTextField.text ?? "") ?? 1
        
        // Update reload intervals
        TBLSDK.shared.updateReloadIntervals(reloadTime, interval)
        
        // Show success message
        let alert = UIAlertController(
            title: "Success",
            message: "Configuration applied",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        TBLSDK.shared.removeTaboolaNewsFromView()
        TBLSDK.shared.removeOnTaboolaNewsListener()
        TBLSDK.shared.deinitialize()
        let userData = TBLUserData(hashedEmail: "hashedEmail", gender: "gender", age: "age", userInterestAndIntent: "userInterestAndIntent")
        TBLSDK.shared.initialize(publisherId: "lineplus-us-ios", data: userData)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
