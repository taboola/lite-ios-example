import UIKit
import TaboolaLite
import CoreLocation
import AppTrackingTransparency
import AdSupport

class HomeViewController: UIViewController {
    
    // MARK: - Constants
    private let APP_PREFS_NAME = "com.taboola.lite.sdk.prefs"
    private let APP_COLLECT_USER_DATA = "collect_user_data"
    private let APP_PUBLISHER_ID = "app_publisher_id"
    private let DEFAULT_PUBLISHER_ID = "lineplus-us-ios"
    
    // MARK: - Location Manager
    private let locationManager = CLLocationManager()
    
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
    
    private lazy var publisherIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter publisher ID"
        textField.borderStyle = .roundedRect
        textField.text = DEFAULT_PUBLISHER_ID
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
//    private lazy var applyButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Initialize", for: .normal)
//        button.addTarget(self, action: #selector(applyConfiguration), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    private lazy var collectUserDataSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.isOn = true // Default to true
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedConsentPreferences()
        disableInputs()
        
        // Set initial configuration
        TBLSDK.shared.setLogLevel(.debug)
        
        // Add target for collect user data switch
        collectUserDataSwitch.addTarget(self, action: #selector(collectUserDataSwitchChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request App Tracking Transparency permission
        requestTrackingPermission()
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
        
        let publisherIdLabel = UILabel()
        publisherIdLabel.text = "Publisher ID"
        publisherIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // User data collection section
        let collectUserDataLabel = UILabel()
        collectUserDataLabel.text = "Collect User Data"
        collectUserDataLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let collectUserDataContainer = UIStackView()
        collectUserDataContainer.axis = .horizontal
        collectUserDataContainer.distribution = .fill
        collectUserDataContainer.alignment = .center
        collectUserDataContainer.spacing = 10
        collectUserDataContainer.translatesAutoresizingMaskIntoConstraints = false
        collectUserDataContainer.addArrangedSubview(collectUserDataLabel)
        collectUserDataContainer.addArrangedSubview(collectUserDataSwitch)
        
        // Add components to stack view
        stackView.addArrangedSubview(logLevelLabel)
        stackView.addArrangedSubview(logLevelSegmentedControl)
        stackView.addArrangedSubview(reloadTimeLabel)
        stackView.addArrangedSubview(reloadTimeTextField)
        stackView.addArrangedSubview(intervalLabel)
        stackView.addArrangedSubview(intervalTextField)
        stackView.addArrangedSubview(publisherIdLabel)
        stackView.addArrangedSubview(publisherIdTextField)
        stackView.addArrangedSubview(collectUserDataContainer)
//        stackView.addArrangedSubview(applyButton)
        
        view.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
//            applyButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func disableInputs() {
        // Disable all inputs except the collect user data switch
        logLevelSegmentedControl.isEnabled = false
        reloadTimeTextField.isEnabled = false
        intervalTextField.isEnabled = false
        publisherIdTextField.isEnabled = false
        
        // Optional: Make disabled inputs visually appear disabled
        logLevelSegmentedControl.alpha = 0.5
        reloadTimeTextField.alpha = 0.5
        intervalTextField.alpha = 0.5
        publisherIdTextField.alpha = 0.5
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
        let reloadTime = reloadTimeTextField.text != nil ? Int(reloadTimeTextField.text!) : nil
        let interval = intervalTextField.text != nil ? Int(intervalTextField.text!) : nil
        
        // Update reload intervals
        TBLSDK.shared.updateReloadIntervals(reloadTime, interval)
        
        // Get publisher ID from text field
        let publisherId = publisherIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? DEFAULT_PUBLISHER_ID
        let finalPublisherId = publisherId.isEmpty ? DEFAULT_PUBLISHER_ID : publisherId
        
        // Save consent preferences to app UserDefaults
        let collectUserData = collectUserDataSwitch.isOn
        saveConsentPreferences(collectUserData: collectUserData, publisherId: finalPublisherId)
        
        // Apply consent settings to SDK
        TBLSDK.shared.setCollectUserData(granted: collectUserData)
        
        TBLSDK.shared.removeTaboolaNewsFromView()
        TBLSDK.shared.deinitialize()
        let userData = TBLUserData(hashedEmail: "hashedEmail")
        TBLSDK.shared.initialize(publisherId: finalPublisherId, data: userData, onTaboolaListener: TaboolaNewsListener(parentView: self.view))
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func collectUserDataSwitchChanged() {
        let collectUserData = collectUserDataSwitch.isOn
        TBLSDK.shared.setCollectUserData(granted: collectUserData)
        
        // Optionally save the preference immediately
        let publisherId = publisherIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? DEFAULT_PUBLISHER_ID
        let finalPublisherId = publisherId.isEmpty ? DEFAULT_PUBLISHER_ID : publisherId
        saveConsentPreferences(collectUserData: collectUserData, publisherId: finalPublisherId)
    }
    
    // MARK: - App Tracking Transparency
    private func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async { [weak self] in
                    switch status {
                    case .authorized:
                        print("✅ Tracking permission granted")
                        self?.logIDFAStatus()
                    case .denied:
                        print("❌ Tracking permission denied")
                        self?.logIDFAStatus()
                    case .restricted:
                        print("⚠️ Tracking permission restricted")
                        self?.logIDFAStatus()
                    case .notDetermined:
                        print("🤷 Tracking permission not determined")
                        self?.logIDFAStatus()
                    @unknown default:
                        print("🤔 Unknown tracking permission status")
                        self?.logIDFAStatus()
                    }
                }
            }
        } else {
            // iOS 13 and below - IDFA is available without explicit permission
            print("📱 iOS 13 or below - IDFA available")
            logIDFAStatus()
        }
    }
    
    private func logIDFAStatus() {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        print("🆔 IDFA: \(idfa)")
        
        if idfa == "00000000-0000-0000-0000-000000000000" {
            print("⚠️ IDFA is all zeros - tracking not permitted or app needs to request permission")
        } else {
            print("✅ Valid IDFA obtained")
        }
    }
    
    // MARK: - User Data Consent Methods
    private func loadSavedConsentPreferences() {
        let userDefaults = UserDefaults.standard
        
        // Load saved values (default to true if not found)
        let collectUserData = userDefaults.object(forKey: APP_COLLECT_USER_DATA) as? Bool ?? true
        let publisherId = userDefaults.string(forKey: APP_PUBLISHER_ID) ?? DEFAULT_PUBLISHER_ID
        
        // Set UI states based on saved values
        collectUserDataSwitch.isOn = collectUserData
        publisherIdTextField.text = publisherId
    }
    
    private func saveConsentPreferences(collectUserData: Bool, publisherId: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(collectUserData, forKey: APP_COLLECT_USER_DATA)
        userDefaults.set(publisherId, forKey: APP_PUBLISHER_ID)
        userDefaults.synchronize()
    }
    
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
