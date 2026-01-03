# iOS Developer QUAD Agent

**Version:** 1.0.0
**Type:** iOS/iPadOS Development Agent
**Created:** December 31, 2025
**Extends:** [agent-ui.md](agent-ui.md) → [agent-base.md](agent-base.md)

---

## Introduction

This is the **iOS developer agent** for building native iOS and iPadOS applications using SwiftUI, UIKit, and Apple's ecosystem.

**Inherits from UI Agent:**
- ✅ Figma design integration
- ✅ GitHub source control
- ✅ Jira project management
- ✅ Slack team communication

**Adds iOS-Specific Tools:**
- 🍎 Xcode integration
- 📱 TestFlight beta distribution
- 📊 Firebase Crashlytics
- ⚡ SwiftUI/UIKit development
- 📏 iOS Human Interface Guidelines compliance

---

{{> agent-ui}}  <!-- Inherits all UI agent functionality -->

---

## iOS-Specific Configuration

### Additional Tools (Beyond UI Agent)

**iOS Development:**
- **Xcode** (IDE) - Apple's official IDE for iOS development
- **Swift Package Manager** - Dependency management
- **CocoaPods** (legacy) - Dependency management
- **Fastlane** - Automation (build, test, deploy)

**Distribution:**
- **TestFlight** - Beta testing platform
- **App Store Connect** - App submission and management

**Analytics & Monitoring:**
- **Firebase** - Crashlytics, Analytics, Remote Config
- **Sentry** - Error tracking
- **Mixpanel** - User analytics

**CI/CD:**
- **Xcode Cloud** - Apple's CI/CD service
- **Bitrise** - Mobile CI/CD platform
- **Fastlane** - Automated builds and deployments

### Additional Environment Variables (iOS Agent)

```bash
# Inherited from UI Agent:
# - FIGMA_ACCESS_TOKEN
# - GITHUB_TOKEN
# - JIRA_API_TOKEN
# - SLACK_BOT_TOKEN

# iOS-Specific:
APPLE_ID={{APPLE_ID}}
APP_STORE_CONNECT_API_KEY_ID={{API_KEY_ID}}
APP_STORE_CONNECT_ISSUER_ID={{ISSUER_ID}}
APP_STORE_CONNECT_API_KEY_PATH={{KEY_PATH}}  # .p8 file

TEAM_ID={{TEAM_ID}}  # Apple Developer Team ID
BUNDLE_ID={{BUNDLE_ID}}  # com.company.appname

# TestFlight
TESTFLIGHT_GROUP={{TESTFLIGHT_GROUP:-Internal Testers}}

# Firebase (iOS)
GOOGLE_SERVICE_INFO_PLIST={{GOOGLE_SERVICE_INFO_PATH}}
FIREBASE_APP_ID={{FIREBASE_APP_ID}}
```

---

## iOS Development Workflow

### 1. Design to Code (Figma → SwiftUI)

**Agent reads Figma design and generates SwiftUI code:**

```
User: "Implement login screen from Figma"
Agent:
  1. Reads Figma file (inherited from UI agent)
  2. Identifies components:
     - Email TextField (SF Pro 14pt, 16px padding)
     - Password SecureField
     - Login Button (Blue #007AFF, height 50px)
     - Forgot Password Link

  3. Generates SwiftUI code:
```

```swift
// LoginView.swift (agent-generated)
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            // Email TextField
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .font(.system(size: 14, weight: .regular, design: .default))

            // Password SecureField
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14, weight: .regular, design: .default))

            // Login Button
            Button(action: login) {
                Text("Login")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#007AFF"))
                    .cornerRadius(8)
            }

            // Forgot Password Link
            Button("Forgot Password?") {
                // Navigate to reset password
            }
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(.blue)
        }
        .padding()
    }

    private func login() {
        // API call to login endpoint
    }
}
```

**Agent validates against iOS HIG:**
- ✅ Touch target size ≥44px (button height 50px)
- ✅ Font sizes readable (14pt minimum)
- ✅ Accessibility labels added
- ✅ Keyboard type matches input (`.emailAddress` for email)
- ✅ Auto-capitalization disabled for email

---

### 2. GitHub Workflow (Inherited + iOS-Specific)

**Branching Strategy:**
```bash
# Agent creates feature branch (inherited from UI agent)
git checkout -b feature/login-screen

# Agent implements iOS code
[writes SwiftUI code]

# Agent runs SwiftLint (iOS-specific)
swiftlint lint --strict

# Agent runs unit tests (iOS-specific)
xcodebuild test \
  -scheme NutriNine \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Agent commits and pushes
git add .
git commit -m "feat(auth): Implement login screen (AUTH-123)"
git push origin feature/login-screen

# Agent creates PR (inherited from UI agent)
gh pr create --title "Add iOS login screen" --body "Implements AUTH-123"
```

**iOS-Specific PR Checks:**
- ✅ SwiftLint passed (no warnings)
- ✅ Unit tests passed (95% coverage)
- ✅ Build succeeded (Xcode 15+)
- ✅ No force unwraps (`!`) in production code
- ✅ Asset catalog updated (if new images)

---

### 3. TestFlight Distribution

**Agent automates beta builds:**

```bash
User: "Deploy to TestFlight"
Agent:
  1. Bumps build number (Fastlane increment_build_number)
  2. Builds app (xcodebuild archive)
  3. Exports IPA (xcodebuild -exportArchive)
  4. Uploads to TestFlight (altool --upload-app)
  5. Notifies testers in Slack (inherited from UI agent)

Output:
  ✅ Build 1.0 (42) uploaded to TestFlight
  ✅ Internal Testers notified
  🔗 TestFlight link: https://testflight.apple.com/join/abc123
```

**Fastlane Configuration (agent-generated):**
```ruby
# fastlane/Fastfile
lane :beta do
  increment_build_number
  build_app(scheme: "NutriNine")
  upload_to_testflight(
    skip_waiting_for_build_processing: true,
    groups: ["Internal Testers"]
  )

  # Notify Slack (inherited from UI agent)
  slack(
    message: "New TestFlight build available: 1.0 (42)",
    channel: "#ios-releases"
  )
end
```

---

### 4. Firebase Integration (Crashlytics)

**Agent sets up Firebase Crashlytics for crash reporting:**

**Setup Steps:**
```bash
User: "Setup Firebase Crashlytics"
Agent:
  1. Adds Firebase SDK via SPM or CocoaPods
     // SPM: https://github.com/firebase/firebase-ios-sdk

  2. Downloads GoogleService-Info.plist from Firebase Console
     (Agent provides instructions to get this file)

  3. Adds to Xcode project

  4. Initializes Firebase in AppDelegate:
```

```swift
// AppDelegate.swift (agent-updated)
import UIKit
import FirebaseCore
import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()

        // Enable Crashlytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

        return true
    }
}
```

**Testing Crashlytics:**
```swift
// Force a test crash (agent adds to debug menu)
Crashlytics.crashlytics().log("Test crash triggered")
fatalError("Test crash - ignore this")
```

**Agent monitors crashes:**
```bash
Agent: "🔥 New crash detected in Firebase Crashlytics"
  ↓
  Crash: Fatal error in LoginView.swift:42
  Affected users: 3 (0.5% of users)
  Stack trace:
    LoginView.login() line 42
    SwiftUI.View.body.getter line 123

  Suggestion:
    Add nil check before force unwrap on line 42:
    guard let user = user else { return }
```

---

### 5. iOS Human Interface Guidelines Compliance

**Agent validates designs against Apple HIG:**

**Spacing:**
- ✅ 8px grid system (matches Apple spacing)
- ✅ Safe area insets respected
- ✅ Padding: 16px (standard iOS)

**Typography:**
- ✅ SF Pro Text (system font)
- ✅ Font sizes: 14pt body, 17pt title (iOS standard)
- ✅ Dynamic Type support (scales with user preferences)

**Colors:**
- ✅ System colors used (`.blue`, `.red`, not hardcoded hex)
- ✅ Dark mode support (semantic colors)
- ✅ Contrast ratio ≥4.5:1 (WCAG AA)

**Accessibility:**
- ✅ VoiceOver labels (`accessibilityLabel`)
- ✅ Touch targets ≥44x44pt
- ✅ Keyboard navigation support

**Example Validation:**
```swift
// ❌ BAD - Hardcoded colors
Text("Hello")
    .foregroundColor(Color(hex: "#007AFF"))  // Breaks in dark mode

// ✅ GOOD - Semantic colors
Text("Hello")
    .foregroundColor(.blue)  // Adapts to dark mode automatically

// ❌ BAD - Small touch target
Button(action: {}) {
    Text("Tap")
        .frame(width: 30, height: 30)  // Too small!
}

// ✅ GOOD - Minimum 44x44pt
Button(action: {}) {
    Text("Tap")
        .frame(width: 44, height: 44)  // Accessible
}
```

---

## iOS-Specific Best Practices

### 1. Force Unwrap Safety

**Agent detects and fixes force unwraps:**
```swift
// ❌ BAD - Force unwrap (crashes if nil)
let user = userManager.currentUser!

// ✅ GOOD - Safe optional binding
guard let user = userManager.currentUser else {
    print("User not logged in")
    return
}
```

### 2. Memory Management (Retain Cycles)

**Agent detects retain cycles in closures:**
```swift
// ❌ BAD - Retain cycle (self captured strongly)
apiClient.fetchData { data in
    self.processData(data)  // Strong reference!
}

// ✅ GOOD - Weak self
apiClient.fetchData { [weak self] data in
    self?.processData(data)
}
```

### 3. SwiftUI State Management

**Agent suggests proper state management:**
```swift
// ❌ BAD - Direct mutation (won't trigger UI update)
var isLoggedIn = false
Button("Login") {
    isLoggedIn = true  // UI won't update!
}

// ✅ GOOD - @State property wrapper
@State private var isLoggedIn = false
Button("Login") {
    isLoggedIn = true  // UI updates automatically
}
```

### 4. API Calls with async/await

**Agent generates modern async/await code:**
```swift
// ✅ GOOD - Modern Swift concurrency
func login(email: String, password: String) async throws -> User {
    let url = URL(string: "https://api.example.com/auth/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = ["email": email, "password": password]
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw LoginError.invalidCredentials
    }

    return try JSONDecoder().decode(User.self, from: data)
}

// Usage in SwiftUI
Button("Login") {
    Task {
        do {
            let user = try await login(email: email, password: password)
            // Handle success
        } catch {
            // Handle error
        }
    }
}
```

---

## iOS Agent Commands

**Setup:**
```bash
ios-init                     # Initialize iOS project structure
ios-install-deps             # Install CocoaPods/SPM dependencies
ios-setup-firebase           # Setup Firebase (Crashlytics, Analytics)
```

**Development:**
```bash
ios-build                    # Build app (debug)
ios-build-release            # Build app (release)
ios-test                     # Run unit tests
ios-lint                     # Run SwiftLint
```

**Distribution:**
```bash
ios-testflight               # Upload to TestFlight
ios-increment-build          # Bump build number
ios-archive                  # Create IPA archive
```

**Monitoring:**
```bash
ios-crashes                  # Show recent crashes (Firebase)
ios-analytics                # Show app analytics
```

---

## Troubleshooting

### Issue 1: Provisioning Profile Error
**Error:** `No provisioning profiles matching the bundle identifier`

**Solution:**
```bash
# Agent guides you to fix:
1. Open Xcode → Signing & Capabilities
2. Select your Team: {{TEAM_ID}}
3. Enable "Automatically manage signing"
4. Or download manual profile from developer.apple.com
```

---

### Issue 2: SwiftLint Warnings
**Error:** `Identifier Name Violation: Variable name should be...`

**Solution:**
```bash
# Agent auto-fixes common SwiftLint issues
swiftlint autocorrect

# Or configure .swiftlint.yml to disable specific rules
disabled_rules:
  - identifier_name
```

---

### Issue 3: TestFlight Upload Failed
**Error:** `Invalid IPA: Missing compliance info`

**Solution:**
```bash
# Agent adds missing export compliance to Info.plist
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

### Issue 4: Firebase Crashlytics Not Reporting
**Error:** No crashes showing in Firebase Console

**Solution:**
```bash
# Agent checks:
1. GoogleService-Info.plist added to Xcode project
2. Firebase initialized in AppDelegate
3. Crashlytics enabled: Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
4. Build uploaded with dSYM files (for symbolication)
```

---

## Support

**Questions or Issues?**
- Documentation: https://quadframe.work/docs/agents/ios
- GitHub Issues: https://github.com/a2vibecreators/quadframework/issues
- Email: support@quadframe.work

**Apple Resources:**
- iOS Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/ios
- App Store Connect: https://appstoreconnect.apple.com
- TestFlight: https://developer.apple.com/testflight

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
