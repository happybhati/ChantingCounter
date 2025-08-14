## Development Guide

This guide walks you from blank machine to running the app on iPhone and Apple Watch.

### 1) Install Xcode

- Install from the Mac App Store. After installation, open Xcode once to complete additional components.
- Confirm versions:
  - `xcodebuild -version`
  - `swift --version`

### 2) Sign in and Enable Device Deployment

1. Xcode → Settings… → Accounts → add your Apple ID.
2. Xcode will create a free signing certificate (or use your Team if you have a paid account).
3. Connect your iPhone with a cable. If prompted on device, tap Trust and enter passcode.
4. If Xcode asks, enable Developer Mode on the device (Settings → Privacy & Security → Developer Mode).

### 3) Create the Project (when Xcode is ready)

1. File → New → Project…
2. Choose “App”. Interface: SwiftUI. Language: Swift. Check “Include Tests”.
3. Name the project and set Organization Identifier (reverse-DNS, e.g., `com.example`).
4. Save inside this repository under `App/`.
5. With the iOS target selected, add a watchOS companion: File → New → Target… → watchOS → Watch App for iOS App.
   - Choose SwiftUI interface. Include notification scene only if needed.
6. Ensure targets share a single app group where appropriate and reuse shared Swift packages.

### 4) Code Signing

- For each target (iOS app, watch app, watch extension), set:
  - Team: your Apple ID team
  - Bundle Identifier: unique per target (e.g., `com.example.App`, `com.example.App.watchkitapp`, `com.example.App.watchkitapp.extension`)
  - Signing: “Automatically manage signing” enabled for early development

### 5) Running on Devices

- Select your iPhone in the Scheme device menu and press Run (⌘R).
- For the Watch app:
  - Ensure the iPhone is selected; Xcode will install the Watch app to the paired Apple Watch.
  - First run may require trusting the developer on the iPhone: Settings → General → VPN & Device Management → Developer App → Trust.

### 6) Source Control & Branching

- Main branch is protected. Use feature branches: `feature/<short-description>`.
- Use conventional commits: `feat:`, `fix:`, `chore:`, `test:`, `docs:`.

### 7) Dependencies

- Prefer Swift Package Manager (SPM): File → Add Packages…
- Avoid CocoaPods unless absolutely necessary.

### 8) Testing

- Unit tests under `Tests/Unit`. UI tests under `Tests/UITests`.
- Run tests: Product → Test (⌘U).

### 9) CI (optional later)

- GitHub Actions or Xcode Cloud for automated builds and tests.

### 10) Style

- Swift 6, SwiftUI, structured concurrency (`async/await`).
- Lint with SwiftFormat/SwiftLint via SPM plugin later in the setup.


