# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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