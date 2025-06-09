# MyGainz

**MyGainz** is a comprehensive fitness tracking application designed to help you monitor your workout progress, log exercises, create custom routines, and visualize your fitness journey. Built with Flutter and powered by local data storage, it provides a seamless experience for fitness enthusiasts of all levels.

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
- [Contributing](#contributing)
- [About](#about)

---

## Overview

**MyGainz** is a Flutter-based fitness tracking application that uses local data storage with SharedPreferences for a fast, offline-first experience. It offers comprehensive workout logging, progress visualization, and personalized fitness insights with support for both metric and imperial units.

---

## Features

### 🔐 Authentication & User Management
- **Secure Authentication:** Email/password login with encrypted data storage
- **Dynamic Registration Flow:** Comprehensive user onboarding with personal and fitness metrics
- **Profile Management:** Editable user stats with real-time updates

### 📊 Units & Measurement System
- **Global Units Support:** Seamless switching between metric and imperial units
- **Automatic Conversion:** Data stored in metric, displayed in user's preferred units
- **Persistent Settings:** Unit preferences saved across app sessions
- **Smart Formatting:** Special handling for imperial height (feet-inches) display

### 🏋️‍♂️ Comprehensive Workout System
- **Exercise Database:** Extensive library of exercises with target muscles and equipment
- **Smart Exercise Search:** Real-time autocomplete with muscle group filtering
- **Custom Exercise Creation:** Add personalized exercises on-the-fly
- **Detailed Logging:** Track sets, reps, weight, and equipment for each exercise

### 🎯 Routine Management
- **Custom Routine Creator:** Build personalized workout routines
- **Order Enforcement:** Optional exercise sequencing with visual progress indicators
- **Smart Muscle Targeting:** Auto-calculated target muscles based on included exercises
- **Flexible Execution:** Support for both ordered and random exercise selection

### 📈 Progress Visualization
- **Real-Time Charts:** Dynamic progress tracking with multiple chart types
- **Time-Based Filtering:** View progress over different time periods
- **Muscle Group Analysis:** Detailed breakdown of training focus
- **Equipment Performance:** Track improvements across different equipment types
- **Empty State Handling:** Encouraging messaging for new users

### 👤 Profile & Data Management
- **Comprehensive Profile:** Display personal stats, fitness metrics, and achievements
- **Muscle Group Focus:** Visual analysis of training distribution
- **Data Export:** Full personal data export in CSV format
- **Statistics Overview:** Real-time workout counts and progress indicators

### ⚙️ Settings & Customization
- **Units Configuration:** Easy switching between measurement systems
- **App Information:** Comprehensive about section with developer details
- **GitHub Integration:** Direct browser linking to repository

---

## User Flows

### Authentication & Registration

- **Login Options:**
  - **Email & Password:** Secure credential-based authentication
  - **First-Time Setup:** Comprehensive registration with validation
- **Registration Process:**
  - **Personal Information:** Name, email, birthday with date picker
  - **Physical Metrics:** Height and weight with unit conversion
  - **Body Composition:** Fat and muscle percentage tracking

### Main Home

The dashboard provides:
- **Recent Activity:** Last 5 logged exercises and routines
- **Quick Stats:** Current weight and height with unit display
- **Empty States:** Encouraging messages for new users
- **Real-Time Updates:** Instant reflection of new workout data

### Units & Settings

- **Global Units Management:**
  - Weight: Kilograms ↔ Pounds
  - Height: Centimeters ↔ Feet-Inches
  - Distance: Kilometers ↔ Miles
- **Persistent Configuration:** Settings saved across app sessions
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

### Logging Workouts

- **Comprehensive Logging:**
  - **Exercise Selection:** Search and select from exercise database
  - **Set Management:** Dynamic set addition with weight, reps tracking
  - **Equipment Configuration:** Detailed equipment selection and setup
  - **Form Validation:** Ensures complete and accurate data entry

- **Routine Execution:**
  - **Progress Tracking:** Visual indicators for exercise completion
  - **Order Enforcement:** Guided workout flow with locked/unlocked states
  - **Flexible Completion:** Mark exercises as complete at any time
  - **Real-Time Updates:** Instant progress reflection

### Progress Tracking

- **Advanced Analytics:**
  - **Time-Based Views:** All time, 6 months, 1 month filtering
  - **Multiple Chart Types:** Line graphs, bar charts, radar charts
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
- **Flutter 3.29.3:** Cross-platform mobile development
- **Dart 3.7.2:** Modern programming language
- **Provider Pattern:** State management with reactive UI updates
- **SharedPreferences:** Local data persistence
- **Platform Channels:** Native device integration

### 📊 Data & Analytics
- **FL Chart:** Beautiful, interactive charts and graphs
- **CSV Export:** Comprehensive data export functionality
- **Real-Time Calculations:** Dynamic progress and statistics computation
- **Local Storage:** Fast, offline-first data management

### 🔧 Additional Packages
- **url_launcher:** External browser integration
- **share_plus:** Cross-platform file sharing
- **path_provider:** File system access
- **provider:** State management solution

---

## Data Structure

The application uses local storage with SharedPreferences for fast, offline-first operation:

### User Data
```dart
{
  "currentUser": {
    "id": String,
    "email": String,
    "name": String,
    "lastName": String,
    "dateOfBirth": String,
    "height": double,        // stored in cm
    "weight": double,        // stored in kg
    "fatPercentage": double,
    "musclePercentage": double
  }
}
```

### Exercise Data
```dart
{
  "loggedExercises": [
    {
      "id": String,
      "exerciseId": String,
      "name": String,
      "targetMuscles": List<String>,
      "weight": double,      // stored in kg
      "reps": int,
      "equipment": String,
      "sets": int,
      "date": String
    }
  ]
}
```

### Routine Data
```dart
{
  "loggedRoutines": [
    {
      "id": String,
      "routineId": String,
      "name": String,
      "targetMuscles": List<String>,
      "date": String,
      "exercises": List<LoggedExercise>
    }
  ]
}
```

### Settings Data
```dart
{
  "weightUnit": String,    // "kg" or "lbs"
  "heightUnit": String,    // "cm" or "ft-in"
  "distanceUnit": String   // "km" or "miles"
}
```

---

## Installation & Setup

### Prerequisites
- Flutter SDK 3.29.3 or higher
- Dart 3.7.2 or higher
- iOS 12.0+ / Android API level 21+

### Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/MikeGonzaBar/MyGainz.git
   cd MyGainz/mygainz
   ```

2. **Install Dependencies:**
   ```bash
    flutter pub get
   ```

3. **Run the Application:**
    ```bash
    flutter run
    ```

4. **Build for Production:**
   ```bash
   # iOS
   flutter build ios
   
   # Android
   flutter build apk
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
# Trigger workflow
