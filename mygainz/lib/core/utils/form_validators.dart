/// Utility class containing common form validation patterns
/// This eliminates repeated validation logic across forms
class FormValidators {
  // Email validation regex pattern
  static final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  /// Validates email format
  /// @param email: Email string to validate
  /// @return: Error message or null if valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password requirements
  /// @param password: Password string to validate
  /// @param minLength: Minimum required length (default: 6)
  /// @return: Error message or null if valid
  static String? validatePassword(String? password, {int minLength = 6}) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates password confirmation matches original password
  /// @param password: Original password
  /// @param confirmPassword: Confirmation password
  /// @return: Error message or null if valid
  static String? validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates required text fields
  /// @param value: Text field value
  /// @param fieldName: Name of the field for error message
  /// @return: Error message or null if valid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates numeric input (weight, reps, etc.)
  /// @param value: String value to validate
  /// @param fieldName: Name of the field for error message
  /// @param min: Minimum allowed value (optional)
  /// @param max: Maximum allowed value (optional)
  /// @param allowZero: Whether zero is allowed (default: false)
  /// @return: Error message or null if valid
  static String? validateNumeric(
    String? value,
    String fieldName, {
    double? min,
    double? max,
    bool allowZero = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number for $fieldName';
    }

    if (!allowZero && numValue <= 0) {
      return '$fieldName must be greater than 0';
    }

    if (min != null && numValue < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && numValue > max) {
      return '$fieldName cannot exceed $max';
    }

    return null;
  }

  /// Validates integer input (reps, sets, etc.)
  /// @param value: String value to validate
  /// @param fieldName: Name of the field for error message
  /// @param min: Minimum allowed value (optional)
  /// @param max: Maximum allowed value (optional)
  /// @return: Error message or null if valid
  static String? validateInteger(
    String? value,
    String fieldName, {
    int? min,
    int? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final intValue = int.tryParse(value.trim());
    if (intValue == null) {
      return 'Please enter a valid number for $fieldName';
    }

    if (intValue <= 0) {
      return '$fieldName must be greater than 0';
    }

    if (min != null && intValue < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && intValue > max) {
      return '$fieldName cannot exceed $max';
    }

    return null;
  }

  /// Validates weight input with unit consideration
  /// @param value: Weight string to validate
  /// @param unit: Weight unit ('kg' or 'lbs')
  /// @return: Error message or null if valid
  static String? validateWeight(String? value, String unit) {
    // Set reasonable limits based on unit
    final double minWeight = unit.toLowerCase() == 'lbs' ? 0.5 : 0.1;
    final double maxWeight = unit.toLowerCase() == 'lbs' ? 2000.0 : 1000.0;

    return validateNumeric(
      value,
      'Weight',
      min: minWeight,
      max: maxWeight,
    );
  }

  /// Validates percentage input (fat%, muscle%, etc.)
  /// @param value: Percentage string to validate
  /// @param fieldName: Name of the field for error message
  /// @return: Error message or null if valid
  static String? validatePercentage(String? value, String fieldName) {
    return validateNumeric(
      value,
      fieldName,
      min: 0.0,
      max: 100.0,
      allowZero: true,
    );
  }

  /// Validates that at least one item is selected from a list
  /// @param selectedItems: List of selected items
  /// @param fieldName: Name of the field for error message
  /// @return: Error message or null if valid
  static String? validateAtLeastOneSelected(
      List<dynamic> selectedItems, String fieldName) {
    if (selectedItems.isEmpty) {
      return 'Please select at least one $fieldName';
    }
    return null;
  }

  /// Validates date input is not in the future
  /// @param date: Date to validate
  /// @param fieldName: Name of the field for error message
  /// @return: Error message or null if valid
  static String? validatePastDate(DateTime? date, String fieldName) {
    if (date == null) {
      return '$fieldName is required';
    }
    if (date.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future';
    }
    return null;
  }

  /// Validates age based on date of birth
  /// @param dateOfBirth: Date of birth
  /// @param minAge: Minimum age requirement (default: 13)
  /// @param maxAge: Maximum age limit (default: 120)
  /// @return: Error message or null if valid
  static String? validateAge(DateTime? dateOfBirth,
      {int minAge = 13, int maxAge = 120}) {
    if (dateOfBirth == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    final hasHadBirthdayThisYear = now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    if (actualAge < minAge) {
      return 'You must be at least $minAge years old';
    }
    if (actualAge > maxAge) {
      return 'Age cannot exceed $maxAge years';
    }

    return null;
  }

  /// Validates exercise name (no special characters, reasonable length)
  /// @param name: Exercise name to validate
  /// @return: Error message or null if valid
  static String? validateExerciseName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Exercise name is required';
    }

    final trimmedName = name.trim();
    if (trimmedName.length < 2) {
      return 'Exercise name must be at least 2 characters';
    }
    if (trimmedName.length > 50) {
      return 'Exercise name cannot exceed 50 characters';
    }

    // Allow letters, numbers, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z0-9\s\-']+$").hasMatch(trimmedName)) {
      return 'Exercise name can only contain letters, numbers, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validates routine name
  /// @param name: Routine name to validate
  /// @return: Error message or null if valid
  static String? validateRoutineName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Routine name is required';
    }

    final trimmedName = name.trim();
    if (trimmedName.length < 2) {
      return 'Routine name must be at least 2 characters';
    }
    if (trimmedName.length > 50) {
      return 'Routine name cannot exceed 50 characters';
    }

    return null;
  }
}
