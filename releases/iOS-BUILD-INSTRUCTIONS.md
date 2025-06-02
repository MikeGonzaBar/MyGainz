# 🍎 MyGainz iOS Installation Guide

Due to Apple's iOS security restrictions, distributing iOS apps outside the App Store requires special setup. Here are your options:

## 📱 Option 1: Self-Build (Recommended)

### Prerequisites
- **macOS computer** (required for iOS development)
- **Xcode** (free from Mac App Store)
- **Flutter SDK** (free)
- **Free Apple Developer Account** (for device testing)

### Step-by-Step Instructions

1. **Install Flutter** (if not already installed):
   ```bash
   # Download Flutter from https://flutter.dev/docs/get-started/install/macos
   # Or use Homebrew:
   brew install flutter
   ```

2. **Install Xcode** from the Mac App Store (free)

3. **Clone the MyGainz repository**:
   ```bash
   git clone https://github.com/MikeGonzaBar/MyGainz.git
   cd MyGainz/mygainz
   ```

4. **Get Flutter dependencies**:
   ```bash
   flutter pub get
   ```

5. **Open iOS Simulator** (for testing):
   ```bash
   open -a Simulator
   flutter run
   ```

6. **Install on Physical Device**:
   ```bash
   # Connect your iPhone/iPad via USB
   # Trust the computer when prompted on device
   flutter run
   ```

### 🔓 Device Installation (Physical iPhone/iPad)

If you want to install on a real device:

1. **Sign up for free Apple Developer account** at [developer.apple.com](https://developer.apple.com)
2. **Open project in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. **Set your development team** in Xcode project settings
4. **Connect your device** and select it as target
5. **Build and run** from Xcode

## 🧪 Option 2: iOS Simulator Build

For developers who want to test in iOS Simulator:

### Download Pre-built Simulator App
- **File**: `MyGainz-v1.1.0-simulator.app` 
- **Size**: ~59MB
- **Requirements**: macOS with Xcode/iOS Simulator installed

### Installation:
1. Download the `.app` file
2. Drag to iOS Simulator
3. Or install via command line:
   ```bash
   xcrun simctl install booted MyGainz-v1.1.0-simulator.app
   ```

## 🚀 Option 3: TestFlight Beta (Coming Soon)

If there's enough interest, we may set up TestFlight distribution:
- **Pros**: Easy installation like App Store
- **Cons**: Requires Apple Developer Program membership ($99/year)
- **Capacity**: Up to 10,000 beta testers

*Watch this repository for TestFlight announcements!*

## ❓ Need Help?

- **Build Issues**: Check [Flutter iOS setup guide](https://flutter.dev/docs/get-started/install/macos#ios-setup)
- **Xcode Problems**: Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- **Device Trust Issues**: Go to iPhone Settings → General → VPN & Device Management → Developer App → Trust

## 🔐 Why is iOS Distribution Different?

Unlike Android, iOS requires:
- ✅ **Code signing** for device installation
- ✅ **Developer account** for physical devices  
- ✅ **Device registration** for ad-hoc distribution
- ✅ **App Store review** for public distribution

This ensures security but makes distribution more complex than Android APKs.

---

*For the easiest experience, we recommend starting with the iOS Simulator build, then moving to device installation if you want to use the app daily.* 