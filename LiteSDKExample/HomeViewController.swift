import UIKit
import TaboolaLite
import CoreLocation

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
        setupLocationManager()
        loadSavedConsentPreferences()
        
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
        let userData = TBLUserData(hashedEmail: "hashedEmail", gender: "gender", age: "age", userInterestAndIntent: "userInterestAndIntent")
        TBLSDK.shared.initialize(publisherId: finalPublisherId, data: userData, onTaboolaListener: TaboolaNewsListener())
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationPermission()
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
    
    @objc private func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationPermissionAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access is already granted!")
//            showLocationGrantedAlert()
        @unknown default:
            break
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Permission",
            message: "Location access is currently disabled. Please enable it in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showLocationGrantedAlert() {
        let alert = UIAlertController(
            title: "Location Permission",
            message: "Location access is already granted!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
            // You can start location updates here if needed
            // locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location permission denied")
        case .notDetermined:
            print("Location permission not determined")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates here if you start location updates
        if let location = locations.last {
            print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

