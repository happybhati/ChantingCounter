# iOS + watchOS Starter

This repository will host a modern, production-quality Apple platform app built with Swift and SwiftUI, targeting iOS and watchOS (with an Apple Watch companion).

## Prerequisites

- Xcode (from the App Store)
- Xcode Command Line Tools (`xcode-select --install`) — you already have these
- Apple ID signed in to Xcode (for running on device)
- A physical iPhone and Apple Watch (optional but recommended)

## Setup

1. Install Xcode from the App Store.
2. Open Xcode and sign in: Xcode → Settings… → Accounts → Sign in with your Apple ID.
3. Connect your iPhone via USB (or enable Wi‑Fi debugging) and trust the computer.
4. On the iPhone: Settings → Privacy & Security → Developer Mode → enable (will require a restart) — only if prompted by Xcode.
5. Once Xcode is installed, we will create the project with iOS + watchOS targets using SwiftUI and the latest SDKs.

## Project Structure (planned)

```
.
├── App/
│   ├── iOS/
│   ├── watchOS/
│   ├── Shared/
│   └── Resources/
├── Tests/
│   ├── Unit/
│   └── UITests/
├── Packages/
├── fastlane/ (optional)
└── docs/
```

We will follow Apple’s recommended conventions for Swift packages, SwiftUI composition, and test organization.

## Development

See `docs/Development.md` for step‑by‑step guides on running on devices, watch pairing, and code signing.
