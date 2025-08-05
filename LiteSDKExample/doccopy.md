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

        TBLSDK.initialize(this, publisherId, userData, object : OnTBLListener {
            override fun onTaboolaInitializationComplete(statusCode: TBLStatusCode) {
                if (statusCode == TBLStatusCode.SUCCESS) {
                    // SDK is ready
                }
            }

            override fun onTaboolaSharePressed(context: Context, url: String) {
                Log.d("TAG", "User shared: $url")
            }

            override fun onTaboolaLoadComplete(statusCode: TBLStatusCode) {
                Log.d("TAG", "Load complete with status: ${statusCode.message}")
            }
        })
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
    TBLSDK.setupTaboolaNews(view, object : OnTBLNewsListener {
        override fun onTaboolaNewsSetupComplete(statusCode: TBLStatusCode) {
            Log.d("TAG", "Setup status: ${statusCode.message}")
        }

        override fun onTaboolaNewsRefreshComplete(statusCode: TBLStatusCode) {
            Log.d("TAG", "Refresh status: ${statusCode.message}")
        }
    })
}
```

### 3. **Removing Taboola Content**

To ensure clean deallocation of resources and prevent memory leaks, especially when the containing view or fragment is destroyed, make sure to call `cleanupTaboolaNewsFromView()`:

```kotlin
override fun onDestroyView() {
    super.onDestroyView()
    TBLSDK.cleanupTaboolaNewsFromView()
}
```

This will remove the WebView and all internal listeners, and ensure the SDK no longer holds references to the view.

### 4. **Set User Data (Optional)**

Allows you to update or provide user data after initialization.

```kotlin
val userData = TBLUserData(
    "hashedEmail1",
    "gender",
    "age",
    "userInterestAndIntent")
TBLSDK.setUserData(userData)
```

### 5. **Handling Clicks**

If you want to manually handle clicks (e.g., open with a specific TWA or Custom Tab implementation), use the following:

```kotlin
TBLSDK.onClickedTaboolaItem(newsUrl, this) { success ->
    if (!success) {
        Toast.makeText(this, "Failed to open URL with customTab, publisher will handle the click", Toast.LENGTH_SHORT).show()
    }
}
```

---

### Set User Data Collection Preference

Use this method to enable or disable user data collection based on user consent. It can be called before or after `initialize()`:

```kotlin
TBLSDK.setCollectUserData(granted = true, context = this)
```

* **Parameters**:

  * `granted`: Boolean indicating user consent.
  * `context`: Application context.

---

## Listener Interfaces

### Taboola Event Listeners

#### OnTBLNewsListener

The `OnTBLNewsListener` interface allows you to listen for news-related events from Taboola:

```kotlin
interface OnTBLNewsListener {
    fun onTaboolaNewsSetupComplete(statusCode: TBLStatusCode)
    fun onTaboolaNewsRefreshComplete(statusCode: TBLStatusCode)
}
```

* **onTaboolaNewsSetupComplete**: Called when the Taboola WebView is successfully added to the fragment.
* **onTaboolaNewsRefreshComplete**: Called when the Taboola WebView finishes refreshing content.

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

#### OnTBLTWAListener

Handles share events in Trusted Web Activities:

```kotlin
interface OnTBLTWAListener {
    fun onTaboolaSharePressed(context: Context, url: String)
}
```

```kotlin
override fun onTaboolaSharePressed(context: Context, url: String) {
    Log.d("TAG", "User shared: $url")
}
```

---

## Lifecycle Management

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

---

## Scroll to Top

```kotlin
TBLSDK.onScrollToTopTaboolaNews()
```

---

## Deinitialization

```kotlin
override fun onTerminate() {
    super.onTerminate()
    TBLSDK.deinitialize()
}
```

---

## TBLStatusCode Enum

```kotlin
enum class TBLStatusCode(val code: Int) {
    SUCCESS(200),
    BAD_REQUEST(400),
    SERVICE_UNAVAILABLE(503),
    PUBLISHER_INVALID(-1),
    WEB_VIEW_NOT_FOUND(-2),
    SDK_DISABLED(-3),
    SDK_NOT_INITIALIZED(-4),
    INVALID_VIEW_GROUP(-5);

    val message: String
        get() = when (this) {
            SUCCESS -> "Success"
            BAD_REQUEST -> "Bad Request - Please check your input."
            SERVICE_UNAVAILABLE -> "Service Unavailable - Try again later."
            PUBLISHER_INVALID -> "Publisher Invalid - Please contact support."
            WEB_VIEW_NOT_FOUND -> "WebView Not Found - Please check if you deinitialized the SDK."
            SDK_DISABLED -> "SDK Disabled - SDK functionality has been disabled."
            SDK_NOT_INITIALIZED -> "SDK Not Initialized - Please call initialize() first."
            INVALID_VIEW_GROUP -> "Invalid View - View must be a ViewGroup and not null."
        }
}
```

---

## Changelog

### Version 1.0.10

* Added lifecycle-safe listener interfaces: `OnTBLListener`, `OnTBLNewsListener`, `OnTBLTWAListener`
* Restored detailed listener documentation and usage examples
* Expanded `TBLStatusCode` with full error message support
* Added mandatory success-check requirement before calling `setupTaboolaNews`
* Improved click handling with fallback support
* Added opt-in/opt-out user data collection with `setCollectUserData`
* Added `cleanupTaboolaNewsFromView()` to prevent memory leaks
* Documented callback timing and responsibilities for all listeners
