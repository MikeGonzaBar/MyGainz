# MyGainz

**MyGainz** is a comprehensive fitness tracking application designed to help you monitor your workout progress, log exercises, create custom routines, and visualize your fitness journey. Built with Flutter and powered by Firebase Firestore, it provides a seamless, cloud-synchronized experience for fitness enthusiasts of all levels.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [User Flows](#user-flows)
  - [Authentication & Registration](#authentication--registration)
  - [Main Home](#main-home)
  - [Units & Settings](#units--settings)
  - [Exercises & Routines](#exercises--routines)
  - [Logging Workouts](#logging-workouts)
  - [Progress Tracking](#progress-tracking)
  - [Profile & Data Management](#profile--data-management)
- [Technologies](#technologies)
- [Data Structure](#data-structure)
- [Installation & Setup](#installation--setup)
- [Recent Updates](#recent-updates)
- [Contributing](#contributing)
- [About](#about)

---

## Overview

**MyGainz** is a Flutter-based fitness tracking application that uses Firebase Firestore for real-time cloud synchronization. It offers comprehensive workout logging with individual set tracking, progress visualization, and personalized fitness insights with support for both metric and imperial units.

---

## Features

### 🔐 Authentication & User Management
- **Secure Authentication:** Email/password login with Firebase Authentication
- **Dynamic Registration Flow:** Comprehensive user onboarding with personal and fitness metrics
- **Profile Management:** Editable user stats with real-time cloud synchronization

### 📊 Units & Measurement System
- **Global Units Support:** Seamless switching between metric and imperial units
- **Standardized Storage:** All weights stored in kg (base unit) for consistency and accuracy
- **Smart Display Conversion:** Automatic conversion to user's preferred units for display
- **Persistent Settings:** Unit preferences saved in the cloud and synchronized across devices
- **Smart Formatting:** Special handling for imperial height (feet-inches) display
- **Data Migration:** Automatic one-time migration to fix legacy data with incorrect unit storage
- **Cross-Platform Consistency:** Same weight values displayed correctly on all devices regardless of unit preference

### 🏋️‍♂️ Comprehensive Workout System
- **Exercise Database:** Extensive library of exercises with target muscles and equipment
- **Smart Exercise Search:** Real-time autocomplete with advanced multi-select muscle group filtering
- **Enhanced Filtering:** Select multiple muscle groups simultaneously with visual indicators and smart layout
- **Custom Exercise Creation:** Add personalized exercises on-the-fly
- **Individual Set Tracking:** Log each set separately with weight, reps, and equipment
- **Real-time Data Sync:** Workout data synchronized across devices with automatic refresh

### 🎯 Routine Management
- **Custom Routine Creator:** Build personalized workout routines
- **Enhanced Exercise Tiles:** Larger tiles with muscle group icons and improved typography
- **Order Enforcement:** Optional exercise sequencing with visual progress indicators
- **Smart Muscle Targeting:** Auto-calculated target muscles based on included exercises
- **Visual Muscle Icons:** Automatic muscle group icon display based on exercise targets
- **Flexible Execution:** Support for both ordered and random exercise selection
- **Cloud Synchronization:** Routines saved and synced across devices

### 📈 Progress Visualization
- **Real-Time Charts:** Dynamic progress tracking with multiple chart types
- **Time-Based Filtering:** View progress over different time periods
- **Muscle Group Analysis:** Detailed breakdown of training focus
- **Equipment Performance:** Track improvements across different equipment types
- **Set-Level Analytics:** Progress tracking based on individual sets
- **Empty State Handling:** Encouraging messaging for new users

### 👤 Profile & Data Management
- **Comprehensive Profile:** Display personal stats, fitness metrics, and achievements
- **Muscle Group Focus:** Visual analysis of training distribution
- **Data Export:** Full personal data export in CSV format
- **Cloud Backup:** Automatic data backup and restoration
- **Statistics Overview:** Real-time workout counts and progress indicators

### ⚙️ Settings & Customization
- **Units Configuration:** Easy switching between measurement systems
- **App Information:** Comprehensive about section with developer details
- **GitHub Integration:** Direct browser linking to repository

---

## User Flows

### Authentication & Registration

- **Login Options:**
  - **Email & Password:** Secure Firebase Authentication
  - **First-Time Setup:** Comprehensive registration with validation
- **Registration Process:**
  - **Personal Information:** Name, email, birthday with date picker
  - **Physical Metrics:** Height and weight with unit conversion
  - **Body Composition:** Fat and muscle percentage tracking
  - **Cloud Profile Creation:** Automatic Firestore user document creation

### Main Home

The dashboard provides:
- **Recent Activity:** Last 5 logged exercises and routines
- **Quick Stats:** Current weight and height with unit display
- **Pull-to-Refresh:** Instant data refresh with downward swipe gesture
- **Manual Refresh:** App bar refresh button with loading indicators
- **Smooth Navigation:** Animated bottom navigation with scaling icons and page transitions
- **Gesture Support:** Swipe between pages or tap navigation tabs
- **Real-time Sync:** Live updates from cloud data
- **Empty States:** Encouraging messages for new users
- **Cross-device Consistency:** Same data across all devices

### Units & Settings

- **Global Units Management:**
  - Weight: Kilograms ↔ Pounds
  - Height: Centimeters ↔ Feet-Inches
  - Distance: Kilometers ↔ Miles
- **Cloud Configuration:** Settings synchronized across devices
- **Real-Time Conversion:** Instant unit switching without data loss

### Exercises & Routines

- **Exercise Management:**
  - **Search & Filter:** Real-time autocomplete with muscle group filtering
  - **Detailed Information:** Target muscles, equipment, and exercise descriptions
  - **Custom Creation:** Add new exercises with comprehensive details
  - **Smart Suggestions:** Equipment auto-selection based on exercise choice

- **Routine Creation:**
  - **Drag & Drop Interface:** Easy exercise ordering and management
  - **Order Enforcement:** Optional strict exercise sequencing
  - **Target Muscle Calculation:** Automatic muscle group analysis
  - **Flexible Execution:** Support for various workout styles
  - **Cloud Storage:** Routines saved to Firestore for cross-device access

### Logging Workouts

- **Individual Set Tracking:**
  - **Exercise Selection:** Search and select from exercise database
  - **Set-by-Set Logging:** Track each set individually with weight and reps
  - **Equipment Per Set:** Different equipment for each set if needed
  - **Real-time Validation:** Ensures complete and accurate data entry
  - **Cloud Synchronization:** Each set automatically saved to Firestore

- **Routine Execution:**
  - **Progress Tracking:** Visual indicators for exercise completion
  - **Order Enforcement:** Guided workout flow with locked/unlocked states
  - **Flexible Completion:** Mark exercises as complete at any time
  - **Live Updates:** Instant progress reflection across devices

### Progress Tracking

- **Advanced Analytics:**
  - **Time-Based Views:** All time, 6 months, 1 month filtering
  - **Multiple Chart Types:** Line graphs, bar charts, radar charts
  - **Set-Level Analysis:** Progress tracking based on individual sets
  - **Muscle Group Analysis:** Spider graphs for training balance
  - **Equipment Breakdown:** Performance tracking by equipment type
  - **Smart Fallbacks:** Automatic chart type switching based on data availability

### Profile & Data Management

- **Comprehensive Profile:**
  - **Personal Information:** Name, email, age calculation
  - **Editable Metrics:** Tap-to-edit weight and height with validation
  - **Muscle Focus Analysis:** Real-time calculation from workout data
  - **Visual Progress Indicators:** Color-coded muscle group distribution

- **Data Management:**
  - **Complete Export:** CSV generation with all user data
  - **Cloud Backup:** Automatic Firestore backup
  - **Secure Sharing:** File sharing via device's share functionality
  - **Error Handling:** Robust export process with retry mechanisms
  - **Progress Feedback:** Loading states and success confirmations

---

## Technologies

### 🎨 Design & UI
- **Figma:** [Complete UI/UX Design System](https://www.figma.com/design/y15owMIsmAJmE2iHz4hMHr/My-Gainz?node-id=4-2&t=QQyG22n5uUXpoAJl-1)
- **Flaticon:** High-quality exercise and UI icons
- **Material Design:** Flutter's Material Design system
- **Custom Themes:** Consistent color schemes and typography

### 📱 Development
- **Flutter 3.29.3:** Cross-platform mobile development with smooth animations
- **Dart 3.7.2:** Modern programming language with optimized string interpolation
- **Provider Pattern:** State management with reactive UI updates
- **PageView Controller:** Smooth page transitions and gesture navigation
- **AnimatedScale Widgets:** Optimized scaling animations for enhanced UX
- **Firebase Firestore:** Cloud database with real-time synchronization
- **Firebase Authentication:** Secure user authentication with modern API compliance
- **Platform Channels:** Native device integration

### 📊 Data & Analytics
- **FL Chart:** Beautiful, interactive charts and graphs
- **CSV Export:** Comprehensive data export functionality
- **Real-Time Calculations:** Dynamic progress and statistics computation
- **Cloud Storage:** Firestore for scalable, real-time data management

### 🔧 Additional Packages
- **cloud_firestore:** Firebase Firestore integration
- **firebase_auth:** Firebase Authentication
- **firebase_core:** Firebase Core SDK
- **url_launcher:** External browser integration
- **share_plus:** Cross-platform file sharing
- **path_provider:** File system access
- **provider:** State management solution

---

## Data Structure

The application uses Firebase Firestore for cloud storage with real-time synchronization. **Note:** All weight values are stored in kg (kilograms) as the base unit for consistency, regardless of the user's preferred display unit:

### User Collection (`users/{userId}`)
```dart
{
  "id": String,
  "email": String,
  "name": String,
  "lastName": String,
  "dateOfBirth": String,
  "height": double,        // stored in cm
  "weight": double,        // stored in kg
  "fatPercentage": double,
  "musclePercentage": double,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Exercise Collection (`users/{userId}/exercises/{exerciseId}`)
```dart
{
  "id": String,
  "exerciseId": String,
  "exerciseName": String,
  "targetMuscles": List<String>,
  "equipment": String,
  "date": Timestamp,
  "createdAt": Timestamp,
  // Individual sets stored as sub-collection
}
```

### Workout Sets Sub-collection (`users/{userId}/exercises/{exerciseId}/sets/{setId}`)
```dart
{
  "id": String,
  "setNumber": int,
  "weight": double?,      // stored in kg
  "reps": int?,
  "equipment": String?,
  "createdAt": Timestamp,
  // Cardio-specific
  "distance": double?,    // stored in km
  "duration": int?,       // stored in minutes
  "calories": int?,
  "pace": double?,
  "speed": double?,
  "heartRate": int?
}
```

### Routine Collection (`users/{userId}/routines/{routineId}`)
```dart
{
  "id": String,
  "routineId": String,
  "name": String,
  "targetMuscles": List<String>,
  "date": Timestamp,
  "createdAt": Timestamp,
  "exercises": List<LoggedExercise>
}
```

### Personal Records Collection (`users/{userId}/personalRecords/{recordId}`)
```dart
{
  "id": String,
  "exerciseId": String,
  "exerciseName": String,
  "date": Timestamp,
  "equipment": String,
  "type": String, // "weight", "distance", "duration", "pace"
  // Strength-specific
  "weight": double?,
  "reps": int?,
  "sets": int?,
  "oneRepMax": double?,
  // Cardio-specific
  "distance": double?,
  "duration": int?, // stored in minutes
  "pace": double?,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Settings Collection (`users/{userId}/settings/preferences`)
```dart
{
  "weightUnit": String,    // "kg" or "lbs"
  "heightUnit": String,    // "cm" or "ft-in"
  "distanceUnit": String,  // "km" or "miles"
  "updatedAt": Timestamp
}
```

---

## Installation & Setup

### Prerequisites
- Flutter SDK 3.29.3 or higher
- Dart 3.7.2 or higher
- iOS 12.0+ / Android API level 21+
- Firebase project with Firestore enabled

### Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/MikeGonzaBar/MyGainz.git
   cd MyGainz/mygainz
   ```

2. **Firebase Setup:**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firestore Database and Authentication
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
     - `GoogleService-Info.plist` for macOS (place in `macos/Runner/`)

3. **Install Dependencies:**
   ```bash
    flutter pub get
   ```

4. **Run the Application:**
    ```bash
    flutter run
    ```

5. **Build for Production:**
   ```bash
   # iOS
   flutter build ios
   
   # Android
   flutter build apk
   ```

### Firebase Security Rules

Configure Firestore security rules to protect user data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Development Setup

1. **Enable Developer Mode:**
   ```bash
   flutter doctor
   ```

2. **Run Tests:**
   ```bash
   flutter test
   ```

3. **Code Analysis:**
   ```bash
   flutter analyze
   ```

---

## Recent Updates

### 🔧 Version 2.0.3 - Navigation Animations & Stability Fixes

**Smooth Navigation Animations:**
- **Animated Bottom Navigation:** Added smooth scaling animations when switching between tabs
- **Page Transitions:** Implemented fluid page sliding transitions with PageView controller
- **Icon Color Synchronization:** Fixed icon colors to properly match selected/unselected text colors
- **Enhanced Visual Feedback:** Professional-looking tab switching with subtle scale effects (10% larger when selected)
- **Gesture Support:** Added swipe navigation between pages alongside tap navigation

**Critical Stability Fixes:**
- **setState After Dispose Fix:** Resolved crashes when switching tabs during async operations in LogPage
- **Memory Leak Prevention:** Added proper mounted checks before all setState calls
- **Async Safety:** Protected all BuildContext usage in async callbacks with mounted guards
- **Tab Switching Stability:** Eliminated Flutter errors when rapidly navigating between screens

**Code Quality & Future-Proofing:**
- **Deprecated Method Updates:** Replaced all deprecated Firebase and Flutter methods
- **String Interpolation:** Modernized string composition throughout the codebase  
- **Animation Performance:** Optimized animations using Flutter's built-in AnimatedScale widget
- **Error Handling:** Enhanced async operation safety and error recovery

### 🔧 Version 2.0.2 - Enhanced UI & User Experience

**Performance Improvements:**
- **Migration Script Removal:** Eliminated problematic weight migration script that was causing ANR crashes and app freezing
- **Optimized Startup:** Faster app initialization without heavy background operations on the main thread

**Enhanced Filtering & Search:**
- **Multi-Select Muscle Groups:** Exercise filtering now supports multiple muscle group selection with visual indicators
- **Comprehensive Muscle Groups:** Added complete muscle group options including Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Glutes, Calves, Abs, Lower Back, and Obliques
- **Smart Filter Layout:** Selected filters appear first in the list for better accessibility
- **Clear Filters Button:** One-tap clear option showing current selection count
- **Horizontal Scroll Design:** Improved filter navigation with smooth scrolling

**Improved Exercise Tiles & Visual Design:**
- **Enhanced Routine Exercise Tiles:** Larger tiles (85x110px) with better text layout and readability
- **Muscle Group Icons:** Added visual muscle group icons to exercise tiles using app assets
- **Smart Icon Mapping:** Automatic icon selection based on exercise target muscles
- **Modern Typography:** Improved font weights, sizing, and line height for better readability
- **Visual Polish:** Added shadows, better spacing, and enhanced remove buttons

**Data Refresh & Synchronization:**
- **Automatic Refresh:** Data automatically refreshes after editing or deleting exercises and routines
- **Pull-to-Refresh:** Added refresh functionality to Home, Exercise History, Routine History, and Log pages
- **Manual Refresh Button:** App bar refresh button with loading indicators for immediate data sync
- **Real-time Updates:** Improved data consistency across all app screens

**UI & UX Improvements:**
- **Equipment Dropdown Fix:** Resolved dropdown assertion errors with centralized equipment options
- **Icon Alignment Fix:** Fixed muscle group icons to be properly centered instead of top-left aligned
- **Reduced Profile Spacing:** Smaller gap between "Overview" text and weight/height metrics (16px → 8px)
- **Consistent Equipment Options:** Standardized equipment choices across all forms and filters

**Technical Architecture:**
- **Centralized Utilities:** Created `equipment_options.dart` and `muscle_group_options.dart` for consistency
- **Enhanced Error Handling:** Better validation and error management for dropdown components
- **Improved State Management:** More reliable data refresh and synchronization patterns

### 🔧 Version 2.0.1 - Unit Conversion Bug Fixes & Data Migration

**Critical Bug Fixes:**
- **Unit Conversion Fix:** Resolved major bug where weights were stored in user's input unit instead of being converted to kg (base unit)
- **Display Consistency:** Fixed weight display inconsistencies when switching between kg and lbs
- **Data Migration Script:** Automatic one-time migration to fix existing incorrectly stored weight data
- **Personal Records Fix:** Updated personal record displays to show correct units

**Technical Improvements:**
- **Standardized Storage:** All weights now stored in kg regardless of user's input unit
- **Smart Display Logic:** Weights automatically converted to user's preferred unit for display
- **Migration Safety:** One-time migration script with heuristic detection to preserve data integrity
- **Cross-Component Fixes:** Updated all exercise cards, routine displays, and personal record components

**User Experience Enhancements:**
- **Seamless Unit Switching:** Users can now confidently switch between kg and lbs without data corruption
- **Accurate Progress Tracking:** Personal records and progress charts now display correct values in both units
- **Legacy Data Support:** Existing workouts automatically corrected without data loss

### 🚀 Version 2.0.0 - Cloud Migration & Individual Set Tracking

**Major Features:**
- **Firebase Integration:** Complete migration from local storage to Firestore
- **Individual Set Tracking:** Log each workout set separately with detailed metrics
- **Real-time Sync:** Data synchronized across all devices in real-time
- **Cloud Backup:** Automatic backup and restoration of all user data

**Technical Improvements:**
- **Firestore Services:** Comprehensive service layer for all data operations
- **Authentication Integration:** Firebase Auth for secure user management
- **Provider Updates:** Enhanced state management with cloud synchronization
- **Error Handling:** Robust offline/online handling with retry mechanisms

**Data Structure Changes:**
- **Hierarchical Collections:** User data organized in Firestore collections
- **Sub-collections:** Individual sets stored as sub-collections for better performance
- **Timestamps:** Proper timestamp handling for all data operations
- **Scalability:** Database structure designed for future feature expansion

**Migration Benefits:**
- **Cross-device Sync:** Access your data on any device
- **Data Security:** Cloud backup prevents data loss
- **Performance:** Optimized queries and real-time updates
- **Scalability:** Ready for future social features and sharing

---

## Contributing

We welcome contributions to MyGainz! Here's how you can help:

### 🐛 Bug Reports
- Use the GitHub Issues tab
- Include detailed reproduction steps
- Provide device and OS information

### 🚀 Feature Requests
- Submit detailed feature proposals
- Include use cases and benefits
- Consider backward compatibility

### 💻 Code Contributions
1. Fork the repository
2. Create a feature branch
3. Follow Flutter best practices
4. Submit a pull request with detailed description

### 📝 Documentation
- Improve README and code comments
- Add examples and tutorials
- Update API documentation

---

## About

### 👨‍💻 Developer
**MyGainz** is developed by [MikeGonzaBar](https://github.com/MikeGonzaBar) with ❤️ for the fitness community.

### 📞 Support & Feedback
- **GitHub Issues:** [Report bugs and request features](https://github.com/MikeGonzaBar/MyGainz/issues)
- **Repository:** [View source code and contribute](https://github.com/MikeGonzaBar/MyGainz)

### 📄 License
This project is open source. See the repository for license details.

---

## Screenshots

*Coming soon - Screenshots of the application in action*

---

**Ready to start your fitness journey? Download MyGainz and take control of your workouts today!** 💪
