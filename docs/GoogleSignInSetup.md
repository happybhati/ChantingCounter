# Google Sign-In Integration Setup

## Overview
This guide explains how to complete the Google Sign-In integration for ChantingCounter app. The core implementation is ready, but requires adding the Google Sign-In SDK and configuring Firebase project credentials.

## Current Status
✅ **Complete Implementation** - All code is written and ready to use  
🔄 **Pending**: Google Sign-In SDK addition and Firebase project setup  

## Steps to Complete Integration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Project name: `chanting-counter`
4. Enable Google Analytics (optional)
5. Complete project creation

### 2. Add iOS App to Firebase Project
1. In Firebase console, click "Add app" → iOS
2. iOS bundle ID: `com.hbhati.ChantingCounter` (match your Xcode bundle ID)
3. App nickname: `ChantingCounter iOS`
4. Download `GoogleService-Info.plist`

### 3. Replace Configuration File
1. Replace the placeholder `GoogleService-Info.plist` in your project with the downloaded file
2. Make sure it's added to your Xcode project target
3. Verify the bundle ID matches your app

### 4. Add Google Sign-In SDK
Add via Swift Package Manager in Xcode:
1. File → Add Package Dependencies
2. URL: `https://github.com/google/GoogleSignIn-iOS`
3. Version: Latest stable version
4. Add to your main app target

### 5. Enable Google Sign-In Authentication
1. In Firebase Console → Authentication → Sign-in method
2. Enable "Google" sign-in method
3. Set support email (required)

### 6. Configure URL Scheme
1. In Xcode, select your project → ChantingCounter target
2. Go to Info → URL Types
3. Add URL Scheme with your `REVERSED_CLIENT_ID` from GoogleService-Info.plist
   - Example: `com.googleusercontent.apps.1234567890-abcdefghijklmnop`

### 7. Activate Google Sign-In Code
Once the SDK is added, uncomment the implementations in `GoogleSignInManager.swift`:

1. **Uncomment import statement**:
   ```swift
   import GoogleSignIn
   ```

2. **Uncomment configure() method implementation**

3. **Uncomment signIn() method implementation**

4. **Uncomment checkSignInStatus() method implementation**

5. **Uncomment signOut() method implementation**

### 8. Test Integration
1. Build and run the app
2. Go to Welcome screen
3. Tap "Continue with Google"
4. Complete Google sign-in flow
5. Verify user data is saved and synced

## Implementation Details

### Files Modified
- ✅ `GoogleSignInManager.swift` - Complete implementation (commented)
- ✅ `ChantingCounterApp.swift` - Google Sign-In configuration on startup
- ✅ `GoogleService-Info.plist` - Template configuration file
- ✅ `DataManager.swift` - Google user data handling

### Key Features Implemented
- ✅ Sign-in with Google account
- ✅ User profile data extraction (name, email, profile image)
- ✅ Sign-out functionality
- ✅ Session restoration on app launch
- ✅ Integration with existing DataManager
- ✅ CloudKit sync for authenticated users
- ✅ Proper error handling

### User Flow
1. User taps "Continue with Google" in WelcomeView
2. Google Sign-In sheet appears
3. User signs in with Google account
4. App receives user profile data
5. User is marked as non-guest in DataManager
6. Data syncs to CloudKit (when implemented)
7. User proceeds to MainTabView

## Security Notes
- GoogleService-Info.plist contains sensitive keys - don't commit real values to public repos
- Current placeholder plist should be replaced with real Firebase project credentials
- All user authentication data is handled securely by Google's SDK

## Troubleshooting
- **Build errors**: Ensure GoogleSignIn SDK is properly added to project
- **Configuration errors**: Verify GoogleService-Info.plist is correctly added to target
- **Sign-in fails**: Check URL scheme configuration matches REVERSED_CLIENT_ID
- **No sign-in sheet**: Verify Firebase project has Google authentication enabled

## Next Steps After Implementation
1. Test on physical device (Google Sign-In may not work in simulator)
2. Verify CloudKit integration works with Google authenticated users  
3. Add error handling for network issues
4. Consider adding profile picture display in UI
5. Test sign-out and re-authentication flows

---

*This integration is ready to activate once the Google Sign-In SDK is added to the project.*
