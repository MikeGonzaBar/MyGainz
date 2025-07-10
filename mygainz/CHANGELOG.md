# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.3] - 2024-12-29

### Fixed
- **Critical setState After Dispose Error** - Resolved crashes when switching tabs during async operations in LogPage
- **Bottom Navigation Icon Colors** - Fixed icon colors not matching selected/unselected text colors 
- **Memory Leaks** - Added proper mounted checks before all setState calls in async operations
- **Tab Switching Crashes** - Eliminated Flutter errors when rapidly navigating between screens
- **Animation Stuttering** - Replaced complex animation controller with optimized AnimatedScale widgets

### Added
- **Smooth Bottom Navigation Animations** - Professional scaling animations when switching between tabs (10% scale increase)
- **Page Transition Animations** - Fluid horizontal sliding transitions using PageView controller
- **Swipe Navigation** - Users can now swipe left/right between pages in addition to tapping bottom nav
- **Enhanced Visual Feedback** - Improved tab selection animations with proper easing curves
- **Async Safety Guards** - Comprehensive mounted checks protecting all BuildContext usage in callbacks

### Enhanced
- **Navigation Performance** - Faster 250ms transitions with Curves.easeOut for smoother feel
- **Icon Visual Consistency** - All bottom navigation icons now properly sync colors with text (light blue when selected, white when unselected)
- **Animation Optimization** - Removed conflicting animation controllers that caused stuttering
- **Code Modernization** - Updated all deprecated Firebase and Flutter method calls for future compatibility

### Technical Improvements
- **Deprecated Method Fixes** - Replaced `fetchSignInMethodsForEmail`, `updateEmail`, `onPopInvoked`, `withOpacity` with modern alternatives
- **String Interpolation** - Modernized string composition throughout codebase for better performance
- **Error Handling** - Enhanced async operation safety and error recovery mechanisms
- **Memory Management** - Proper widget lifecycle management preventing memory leaks

## [2.0.2] - 2024-12-29

### Fixed
- **Migration Script Removal** - Eliminated problematic weight migration script that was causing ANR crashes and app freezing on startup
- **Equipment Dropdown Error** - Resolved DropdownButton assertion error with "Cable" equipment value not found in dropdown items
- **Icon Alignment** - Fixed muscle group icons being top-left aligned instead of properly centered in exercise tiles
- **Data Synchronization** - Fixed issues where edited exercises and routines wouldn't immediately reflect changes across the app

### Added
- **Multi-Select Muscle Group Filtering** - Exercise filtering now supports selecting multiple muscle groups simultaneously
- **Comprehensive Muscle Group Options** - Added complete muscle group list: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Glutes, Calves, Abs, Lower Back, Obliques
- **Pull-to-Refresh Functionality** - Added refresh capability to Home, Exercise History, Routine History, and Log pages
- **Manual Refresh Button** - App bar refresh button with loading indicators for immediate data synchronization
- **Muscle Group Icons on Exercise Tiles** - Visual muscle group icons automatically displayed on routine exercise tiles
- **Clear Filters Button** - One-tap clear option for muscle group filters showing current selection count
- **Automatic Data Refresh** - Data automatically refreshes after editing or deleting exercises and routines

### Enhanced
- **Exercise Tile Design** - Enlarged routine exercise tiles from 70x100 to 85x110 pixels with improved typography
- **Filter Layout** - Selected muscle group filters appear first in the list for better accessibility
- **Equipment Options Consistency** - Centralized equipment options across all forms and filters to prevent dropdown errors
- **Typography Improvements** - Better font weights (FontWeight.w500), sizing (11px), and line height for exercise tiles
- **Visual Polish** - Added shadows, better spacing, and enhanced remove buttons on exercise tiles
- **Profile Spacing** - Reduced gap between "Overview" text and weight/height metrics from 16px to 8px

### Technical Improvements
- **Centralized Utilities** - Created `equipment_options.dart` and `muscle_group_options.dart` for consistency across the app
- **Smart Icon Mapping** - Automatic muscle group icon selection based on exercise target muscles using existing app assets
- **Enhanced Error Handling** - Better validation and error management for dropdown components
- **Improved State Management** - More reliable data refresh and synchronization patterns
- **Performance Optimization** - Faster app initialization without heavy background operations on the main thread

## [2.0.1] - 2024-12-23

### Fixed
- **Critical Unit Conversion Bug** - Resolved major issue where weights were incorrectly stored in user's input unit instead of being converted to kg (base unit)
- **Weight Display Inconsistencies** - Fixed weight values showing incorrectly when switching between kg and lbs units
- **Personal Records Display** - Fixed personal record displays to show correct weight values in user's preferred unit
- **Exercise Card Weight Display** - Updated all exercise cards to properly convert stored kg values to user's display unit
- **Routine Card Weight Display** - Fixed routine exercise displays to show accurate weight conversions
- **Cross-Component Unit Handling** - Standardized unit conversion logic across all weight-displaying components

### Added
- **Automatic Data Migration** - One-time migration script to fix existing incorrectly stored weight data
- **Heuristic Data Detection** - Smart detection system to identify weights that were stored in lbs vs kg
- **Migration Safety Checks** - Conservative approach to preserve data integrity during migration
- **Migration Logging** - Comprehensive logging to track migration progress and results
- **SharedPreferences Migration Flag** - Prevents migration from running multiple times

### Enhanced
- **Standardized Weight Storage** - All weights now consistently stored in kg regardless of user's input unit
- **Smart Display Conversion** - Automatic conversion of stored kg values to user's preferred display unit
- **Unit Switching Reliability** - Users can now confidently switch between kg and lbs without data corruption
- **Cross-Device Consistency** - Same weight values display correctly on all devices regardless of unit preference
- **Personal Records Accuracy** - PR calculations and displays now work correctly with proper unit conversions

### Technical Improvements
- **WorkoutSetData.fromWorkoutSet()** - Added currentWeightUnit parameter for proper input conversion
- **Enhanced UnitsProvider** - Improved formatWeight() method for consistent display formatting
- **Exercise Edit Dialogs** - Updated to convert weights properly when editing existing exercises
- **Routine Edit Dialogs** - Fixed weight initialization and conversion in routine exercise editing
- **Personal Records Service** - Updated to handle weight conversions for PR calculations
- **Firestore Service** - Added updatePersonalRecord() method for migration support

### Migration Details
- **Automatic Execution** - Migration runs once on app startup after data loading
- **Threshold Detection** - Uses >10kg threshold to identify weights likely stored in lbs
- **Comprehensive Coverage** - Migrates logged exercises, routine exercises, and personal records
- **Firestore Synchronization** - Updates both local cache and cloud database
- **Backup Safety** - Migration preserves original data structure while fixing weight values

## [2.0.0] - 2024-12-22

### Added
- **Firebase Integration** - Complete migration from local storage to Firestore cloud database
- **Individual Set Tracking** - Log each workout set separately with detailed metrics (weight, reps, equipment per set)
- **Real-time Data Synchronization** - Workout data synchronized across all devices instantly
- **Cloud Backup & Restore** - Automatic backup and restoration of all user data
- **Cross-device Access** - Access your workout data from any device with your account
- **Firebase Authentication** - Secure user authentication and profile management

### Enhanced
- **Enhanced State Management** - Updated providers for cloud synchronization
- **Improved Data Structure** - Hierarchical Firestore collections for better performance
- **Set-Level Analytics** - Progress tracking based on individual workout sets
- **Real-time UI Updates** - Live data updates without app refresh
- **Robust Error Handling** - Comprehensive offline/online handling with retry mechanisms

### Technical Improvements
- **Firestore Service Layer** - Comprehensive service architecture for all data operations
- **Firebase Core Integration** - Added firebase_core, cloud_firestore, and firebase_auth packages
- **Sub-collection Architecture** - Individual sets stored as sub-collections for optimal performance
- **Timestamp Management** - Proper timestamp handling for all data operations
- **Security Rules** - Implemented Firestore security rules for user data protection

### Migration Benefits
- **Data Security** - Cloud backup prevents data loss
- **Performance** - Optimized queries and real-time updates
- **Scalability** - Database structure designed for future feature expansion
- **Future Ready** - Foundation for social features and data sharing

### Breaking Changes
- **Data Migration** - Users will need to re-enter data due to new cloud architecture
- **Authentication Required** - All users must create accounts for cloud sync

## [1.1.3] - 2024-12-21

### Fixed
- **Exercise Page UI Overflow** - Fixed RenderFlex overflow (1.5px) in category filter by making it horizontally scrollable
- **Progress Tracker UI Overflow** - Fixed RenderFlex overflow (4.9px) in time period filter by making it horizontally scrollable
- **Layout Stability** - Eliminated yellow and black striped overflow warnings on Samsung Galaxy S23 Ultra and other devices

### Enhanced
- **Responsive Design** - Category and time period filters now scroll horizontally when content exceeds screen width
- **User Experience** - Improved filter navigation with smooth horizontal scrolling
- **Cross-Device Compatibility** - Better layout handling across different screen sizes

### Technical
- Updated `android/app/build.gradle.kts` with explicit NDK version specification
- Enhanced `time_period_filter.dart` with SingleChildScrollView wrapper
- Enhanced exercise page category filters with horizontal scrolling capability

## [1.1.2] - 2024-12-21

### Fixed
- **About Section Version** - Fixed hardcoded version display to automatically read from pubspec.yaml
- **Dynamic Version Updates** - App version now updates automatically with each release without manual code changes

### Technical
- Added `package_info_plus` dependency for runtime version detection
- Enhanced About dialog to fetch version information dynamically

## [1.1.1] - 2024-12-21

### Fixed
- **Workout Mode Toggle** - Fixed UI bug where selected button didn't properly cover full available space
- **Visual Consistency** - Improved toggle button appearance and selection behavior

## [1.1.0] - 2024-12-21

### Added
- **Exercise History Page** - Complete view of all logged exercises with chronological sorting
- **Routine History Page** - Complete view of all logged routines with chronological sorting
- **View All buttons** on Home Page for easy navigation to full exercise and routine history
- **Exercise Edit Functionality** - Edit weight, reps, sets, and equipment for individual logged exercises
- **Routine Edit Functionality** - Edit exercises within logged routines using expandable cards
- **Enhanced UI/UX** - Edit buttons on exercise and routine cards when viewing history
- **Real-time Updates** - All edits are immediately reflected across the app
- **Data Persistence** - All edits are permanently saved to device storage

### Enhanced
- **Home Page** - Added navigation buttons for viewing complete workout history
- **WorkoutProvider** - Added `updateLoggedExercise()` and `updateLoggedRoutineExercise()` methods
- **Exercise Cards** - Added optional edit button with comprehensive edit dialog
- **Routine Cards** - Added optional edit button with multi-exercise edit capability
- **User Experience** - Improved navigation flow and data management

### Technical
- Enhanced data models for better exercise and routine editing
- Added form validation for edit dialogs
- Improved error handling and user feedback
- Maintained backwards compatibility with existing data

## [1.0.0] - 2024-12-20

### Added
- Initial release of MyGainz fitness tracking application
- Basic exercise logging functionality
- Routine creation and management
- User profile and settings
- Workout tracking with sets, reps, and weight
- Data persistence using SharedPreferences
- Clean and intuitive user interface 