# Taboola Android Lite SDK Documentation

The Taboola Lite SDK allows developers to easily integrate Taboola's personalized content recommendations into their Android applications. This documentation provides all the necessary steps and details to set up and use the SDK.

---

## Prerequisites

Before you begin, ensure your project meets the following requirements:

* **Minimum Android SDK**: 29 (Q)
* **Permissions**: Add the following permissions to your `AndroidManifest.xml`:

  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  ```

### Adding Support for TWA in Your Android Manifest

**1. Custom Tabs Query**: Add this to your `AndroidManifest.xml` to enable Custom Tabs:

```xml
<queries>
    <intent>
        <action android:name="android.support.customtabs.action.CustomTabsService" />
    </intent>
</queries>
```

**2. Enable Share button in TWA**
This ensures that your application is properly linked to the specified website, allowing it to handle all URLs securely through Trusted Web Activities.

Additionally, add the following service declaration to support custom tabs:

```xml
<service
    android:name="androidx.browser.customtabs.PostMessageService"
    android:exported="true" />
```

**3. Creating Asset Statements**

To enable Trusted Web Activity (TWA) support, you need to add metadata to your `AndroidManifest.xml` file inside the `<application>` tag:

```xml
<meta-data
    android:name="asset_statements"
    android:resource="@string/asset_statements" />
```

Next, create a `res/values/strings.xml` file (or modify it if it already exists) and add the following:

```xml
<resources>
    <string name="app_name">LineTestApp</string>
    <string name="asset_statements">
        [{
            \"relation\": [\"delegate_permission/common.handle_all_urls\"],
            \"target\": {
                \"namespace\": \"web\",
                \"site\": \"https://taboolanews.com\"}
        }]
    </string>
</resources>
```

---

## Installation

To include the Taboola Lite SDK in your project, follow these steps:

1. Add the Taboola repository to your `repositories`:

   ```kotlin
   repositories {
       google()
       mavenCentral()
       maven {
           url = uri("https://taboolapublic.jfrog.io/artifactory/mobile-release")
           name = "Taboola"
       }
   }
   ```

2. Add the Taboola Lite SDK dependency to your app-level `build.gradle` file:

   ```kotlin
   dependencies {
       implementation("com.taboola:litesdk:1.0.10")
   }
   ```

3. Sync your project with Gradle files to complete the installation.

---

## Getting Started

### 1. **Initialize the SDK**

The `TBLSDK.initialize` method must be called before using any other SDK functionality. It's recommended to initialize the SDK in your `Application` class, but it can also be called from an Activity.

> **Important:** You must wait for `onTaboolaInitializationComplete` with status `SUCCESS` before calling `setupTaboolaNews`. Calling it earlier will result in `SDK_NOT_INITIALIZED` error.

#### Example (in Application class):

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        val publisherId = "Taboola_sdk-tester-demo-line"
        val userData = TBLUserData(
            "hashedEmail",
            "gender",
            "age",
            "userInterestAndIntent")
        
        TBLSDK.initialize(this, publisherId, userData, OnTBLListener())
    }
}
```

* **Parameters**:

  * `context`: Application or Activity context.
  * `publisherId`: A valid Taboola PublisherId (e.g., `publisherId`).
  * `userData`: An instance of `TBLUserData` containing user-specific data.
  * `onTaboolaListener`: An implementation of `OnTBLListener` for lifecycle callbacks.

---

### 2. **Add Taboola to a Fragment View**

Once SDK is initialized (after receiving SUCCESS from `onTaboolaInitializationComplete`), add Taboola content using `TBLSDK.setupTaboolaNews`:

```kotlin
override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    TBLSDK.setupTaboolaNews(view, OnTBLNewsListener())
}
```

### 3. **Removing Taboola Content:**

The `cleanupTaboolaNewsFromView` method ensures that Taboola content is properly detached from the view when the fragment is destroyed, preventing memory leaks and improving performance.

#### Example (in `NewsFragment`):
```kotlin
override fun onDestroyView() {
    super.onDestroyView()
    TBLSDK.cleanupTaboolaNewsFromView()
}
```

---

### 4. **Set User Data (Optional)**

After initialization, you can optionally update user data using `TBLSDK.setUserData`.

```kotlin
val userData = TBLUserData(
    "hashedEmail1",
    "gender",
    "age",
    "userInterestAndIntent")
TBLSDK.setUserData(userData)
```

---

### 5. **Handling clicks on Taboola items with provided URL**

The `onClickedTaboolaItem` function is used to handle user clicks on Taboola items. It attempts to open the provided URL using TWA. If the attempt fails (e.g., the required browser is unavailable), the SDK returns a failure, and the publisher is responsible for handling the fallback behavior (such as opening the link in a WebView or default browser).

```kotlin
TBLSDK.onClickedTaboolaItem(newsUrl, this) { success ->
  if (!success) {
    Toast.makeText(this, "Failed to open URL with customTab, publisher will handle the click", Toast.LENGTH_SHORT).show()
  }
}
```

---

### Set User Data Collection Preference

Use this method to enable or disable user data collection based on user consent.
This method helps control whether the SDK collects user data, adhering to user privacy preferences.
The function can be called **before or after** `TBLSDK.initialize`

```kotlin
TBLSDK.setCollectUserData(granted: Boolean, context: Context)
```
- **Parameters**:
  - `granted`: A boolean indicating whether the user has granted permission (true) or not (false).
  - `context`: application context.

---

## Listener Interfaces

### Taboola Event Listeners

#### OnTBLListener

The `OnTBLListener` interface listens to global SDK events:

```kotlin
interface OnTBLListener {
    fun onTaboolaSharePressed(context: Context, url: String)
    fun onTaboolaInitializationComplete(statusCode: TBLStatusCode)
    fun onTaboolaLoadComplete(statusCode: TBLStatusCode)
}
```

* **onTaboolaInitializationComplete**: Called when the SDK initialization finishes.
* **onTaboolaLoadComplete**: Called when the creation of the Taboola WebView completes.
* **onTaboolaSharePressed**: Triggered when a user presses the share button.

#### OnTBLNewsListener

The `OnTBLNewsListener` interface allows you to listen for news-fragment events from Taboola:

```kotlin
interface OnTBLNewsListener {
    fun onTaboolaNewsSetupComplete(statusCode: TBLStatusCode)
    fun onTaboolaNewsRefreshComplete(statusCode: TBLStatusCode)
}
```

* **onTaboolaNewsSetupComplete**: Called when the Taboola WebView is successfully added to the fragment.
* **onTaboolaNewsRefreshComplete**: Called when the Taboola WebView finishes refreshing content.

The `TBLStatusCode` enum includes the following statuses
Each status also includes a `message` property that provides a user-friendly description, which can be used for logging or displaying error messages in the UI:

- SUCCESS (200): "Success"
- BAD_REQUEST (400): "Bad Request - Please check your input."
- SERVICE_UNAVAILABLE (503): "Service Unavailable - Try again later."
- PUBLISHER_INVALID (-1): "Publisher Invalid - Please contact support."
- WEB_VIEW_NOT_FOUND(-2): "WebView Not Found - Please check if you deinitialized the SDK."
- SDK_DISABLED(-3): "SDK Disabled - SDK functionality has been disabled."
- SDK_NOT_INITIALIZED(-4): "SDK Not Initialized - Please call initialize() first."
- INVALID_VIEW_GROUP(-5): "Invalid View - View must be a ViewGroup and not null."

---

### Taboola Lifecycle Management

Properly managing the Taboola lifecycle ensures smooth performance and prevents resource leaks. Use the following methods within your activity or fragment lifecycle:

```kotlin
override fun onPause() {
    super.onPause()
    TBLSDK.onPauseTaboolaNews()
}

override fun onResume() {
    super.onResume()
    TBLSDK.onResumeTaboolaNews()
}
```

These functions pause and resume Taboola content as needed, improving app performance.

---

### Scroll to Top Function

The `onScrollToTopTaboolaNews` function allows users to quickly return to the top of the Taboola feed.

```kotlin
TBLSDK.onScrollToTopTaboolaNews()
```

This can be linked to a UI button for better navigation.

---

### Set User Data Collection Preference

Use this method to enable or disable user data collection based on user consent.
This method helps control whether the SDK collects user data, adhering to user privacy preferences.
The function can be called **before or after** `TBLSDK.initialize`

```kotlin
TBLSDK.setCollectUserData(granted: Boolean, context: Context)
```
- **Parameters**:
  - `context`: Application context.
  - `granted`: A boolean indicating whether the user has granted permission (true) or not (false).

---

### Deinitialization

When your application is terminating, you can call `TBLSDK.deinitialize()` to clean up resources:

```kotlin
override fun onTerminate() {
    super.onTerminate()
    TBLSDK.deinitialize()
}
```

---

## Advanced Configuration

### Set Log Level

To control the log verbosity of the SDK, you can set the log level as follows:

```kotlin
TBLSDK.setLogLevel(TBLLogLevel.DEBUG) // Options: NONE, ERROR, WARN, INFO, DEBUG
```

### Update Reload Intervals (Testing Only)

For testing purposes, you can configure the reload intervals for the WebView content:

```kotlin
TBLSDK.updateReloadIntervals(
    reloadWebViewTimeMinute = 1, // Set WebView reload interval to 1 minutes
    timerRepeatInterval = 1  // Set timer repeat interval to 1 minutes
)
```

---


## Changelog

### Version 1.0.10

* Added lifecycle-safe listener interfaces: `OnTBLListener`, `OnTBLNewsListener`
* Expanded `TBLStatusCode` with full error message support
* Added mandatory success-check requirement before calling `setupTaboolaNews`

### Version 1.0.9
- New function `setCollectUserData` to enable/disable collecting user data.

### Version 1.0.8
- Remove handle crash and error events.
- Support gam integration with Taboola unit.

### Version 1.0.7
- Send an error event if pull to refresh failes.
- Handle click events in web pages.
- Remove javascript bridge in non taboola pages.
- Handle crash and error events.
- Fix Share button when chrome is disabled.

### Version 1.0.6
- Bug fix.

### Version 1.0.5
- Added updateReloadIntervals method for testing WebView reload behavior
- Added setLogLevel method for controlling SDK log verbosity
- Retry calling `addTaboolaNewsToView` if a network connection error occurs.

### Version 1.0.4
- Renamed `TaboolaLiteSDK` to `TBLSDK` for better consistency
- Added support for initialization in Application class
- Added `deinitialize()` method for application termination
- Split listeners into two separate interfaces:
  - `OnTBLNewsListener` for news-related events
  - `OnTBLTWAListener` for TWA share events
- Changed initialization to include TWA listener
- Consolidated `addTaboolaNewsToView` and `setOnTaboolaListener` into `setupTaboolaNews`
- Renamed `removeOnTaboolaListener` to `cleanupTaboolaNewsFromView`
- Introduced `TBLStatusCode` enum with a `message` property for easier debugging
- Changed `onPauseTaboolaView` to `onPauseTaboolaNews` for better naming consistency
- Changed `onResumeTaboolaView` to `onResumeTaboolaNews` for better naming consistency
- Added `onScrollToTopTaboolaNews` function

### Version 1.0.3
- Send onTaboolaFailed(statusCode: Int) with status code -1 If the publisherId invalid.
- Fix dark mode
- Fix build settings

### Version 1.0.2
- Changed `addTaboolaToView` to `addTaboolaNewsToView` for better naming consistency and clarity.
- Added `removeOnTaboolaListener` to allow developers to detach the event listener when it is no longer needed, preventing memory leaks.
- Added `removeTaboolaNewsFromView`, which ensures that Taboola content is properly removed from the view hierarchy when the fragment is destroyed.
- Updated `OnTaboolaListener` interface to include:
  - `fun onTaboolaFailed(statusCode: Int)`, providing detailed error handling based on HTTP status codes.
  - `fun onTaboolaSharePressed(url: String)`, allowing developers to catch and show share dialog when users pressed on share button.
- Added support for **dark mode**, making the SDK adapt seamlessly to the user's system-wide theme preferences.

### Version 1.0.1
- Added event listener with `setOnTaboolaListener` to listen to the function `onTaboolaFailed`.
- Added the function `setUserData`, to set after initialization.
- Added `onPauseTaboolaView` and `onResumeTaboolaView` to manage Taboola lifecycle.

### Version 1.0.0
- Initial release of the Taboola Lite SDK.
- Includes user data configuration and publisher-specific settings.

---

